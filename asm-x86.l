;;; x86 and x86-64 rows: encode and decode by interpreting the Intel SDM
;;; opcode-table rows in x86.spec.  One file of rows serves two instruction
;;; sets, chosen by the rows' validity columns: x86 (32-bit protected mode) and
;;; x64 (64-bit mode).  Registers itself with asm-table.l as both.
;;;
;;; Operands: a register is its name (EAX, R12D, SIL, XMM3); an immediate or a
;;; branch target is a number (targets are absolute); memory is
;;; (mN disp base index scale), N the access size in bits (m for any size, as
;;; for LEA), () for no base or index; RIP as base is RIP-relative, disp then
;;; being the absolute target.  32-bit addresses in 64-bit mode (prefix 67)
;;; are not encoded.

(require "text-parser.l")
(load "x86.g.l")

(define x86-all-rows (parse-string <x86spec> $file (contents-of-file-named "x86.spec")))

;; Registers: (name kind size number flag).  Kind r is general purpose, x is
;; XMM; flag high marks AH CH DH BH (no REX allowed), rex marks SPL BPL SIL DIL
;; (REX required).
(define x86-registers ())
(define-function x86-add-registers (kind size names from flag)
  (let ((n from)) (list-do r names (set x86-registers (cons (list r kind size n flag) x86-registers)) (set n (+ n 1)))))
(x86-add-registers 'r 1 '(AL CL DL BL) 0 ())
(x86-add-registers 'r 1 '(AH CH DH BH) 4 'high)
(x86-add-registers 'r 1 '(SPL BPL SIL DIL) 4 'rex)
(x86-add-registers 'r 1 '(R8B R9B R10B R11B R12B R13B R14B R15B) 8 ())
(x86-add-registers 'r 2 '(AX CX DX BX SP BP SI DI R8W R9W R10W R11W R12W R13W R14W R15W) 0 ())
(x86-add-registers 'r 4 '(EAX ECX EDX EBX ESP EBP ESI EDI R8D R9D R10D R11D R12D R13D R14D R15D) 0 ())
(x86-add-registers 'r 8 '(RAX RCX RDX RBX RSP RBP RSI RDI R8 R9 R10 R11 R12 R13 R14 R15) 0 ())
(x86-add-registers 'x 16 '(XMM0 XMM1 XMM2 XMM3 XMM4 XMM5 XMM6 XMM7 XMM8 XMM9 XMM10 XMM11 XMM12 XMM13 XMM14 XMM15) 0 ())

(define-function x86-reg (r)	(and (symbol? r) (assq r x86-registers)))
(define-function x86-reg-num (r)	(cadddr (x86-reg r)))

;; Whether register r exists in mode (x86 or x64).
(define-function x86-reg-in-mode? (r mode)
  (let ((e (x86-reg r)))
    (and e (or (= mode 'x64) (and (< (cadddr e) 8) (!= 8 (caddr e)) (!= 'rex (car (cddddr e))))))))

(define-function x86-reg-named (kind size n high? mode)
  (car (list-detect e x86-registers
		    (and (= kind (cadr e)) (= size (caddr e)) (= n (cadddr e))
			 (if (and (= size 1) (<= 4 n) (< n 8)) (= (car (cddddr e)) (if high? 'high 'rex)) 1)))))

;; SDM operand notation (vol. 2, 3.1.1.3) as (class size).
(define x86-kinds
  '((r8 r 1) (r16 r 2) (r32 r 4) (r64 r 8) (r/m8 rm 1) (r/m16 rm 2) (r/m32 rm 4) (r/m64 rm 8)
    (m m 0) (m8 mem 1) (m16 mem 2) (m32 mem 4) (m64 mem 8) (m128 mem 16)
    (imm8 imm 1) (imm16 imm 2) (imm32 imm 4) (imm64 imm 8) (rel8 rel 1) (rel32 rel 4)
    (xmm x 16) (xmm/m32 xm 4) (xmm/m64 xm 8) (xmm/m128 xm 16)))

;; The SDM's literal operand 1 (SHL r/m32, 1) reads as a symbol from the rows.
(define x86-one (string->symbol "1"))
(define-function x86-kind (k)
  (cond ((= k x86-one)	'(one 1))
	(else		(or (cdr (assq k x86-kinds)) (list 'fixed k)))))

(define x86-mem-tags '((m . 0) (m8 . 1) (m16 . 2) (m32 . 4) (m64 . 8) (m128 . 16)))
(define-function x86-mem? (x)	(and (pair? x) (assq (car x) x86-mem-tags) (= 5 (list-length x))))
(define-function x86-mem-tag (size)	(car (list-detect e x86-mem-tags (= size (cdr e)))))

;; The operand size of a row in mode: its widest general-purpose or memory
;; operand (XMM operands don't count), or for o32 rows 4 in 32-bit mode and 8
;; in 64-bit mode, where they default to 64 bits.  DX beside another fixed
;; register is an I/O port, not an operand.
(define-function x86-row-size (row mode)
  (let ((s (if (memq 'o32 (caddr row)) (if (= mode 'x64) 8 4) 0)) (ks (cadr row)))
    (list-do k ks
      (let ((c (x86-kind k)))
	(cond ((memq (car c) '(r rm mem)) (set s (max s (cadr c))))
	      ((and (= 'fixed (car c)) (x86-reg k) (= 'r (cadr (x86-reg k)))
		    (not (and (= k 'DX) (list-detect j ks (and (!= j 'DX) (x86-reg j))))))
	       (set s (max s (caddr (x86-reg k))))))))
    s))

(define-function x86-unsigned? (row)	(memq 'u (caddr row)))

;; Whether v fits an n-byte immediate of a row with operand size size: signed,
;; or unsigned when the immediate is as wide as the operand (or the row is u).
;; Displacements and branch offsets pass size 8, so they are signed only.
(define-function x86-fits? (v n size unsigned)
  (let ((bits (* 8 n)))
    (cond ((= n 8)	(long? v))
	  (unsigned	(and (<= 0 v) (< v (<< 1 bits))))
	  (else		(or (and (<= (- 0 (<< 1 (- bits 1))) v) (< v (<< 1 (- bits 1))))
			    (and (<= size n) (<= 0 v) (< v (<< 1 bits))))))))

;; An immediate as the signed value of an operand of size bytes: 0xFFFFFFFF
;; with a 32-bit operand is -1, as the processor sees it.
(define-function x86-signed (v size)
  (let ((bits (* 8 size)))
    (if (and (long? v) (< 0 size) (< size 8) (<= (<< 1 (- bits 1)) v) (< v (<< 1 bits))) (- v (<< 1 bits)) v)))

(define-function x86-reloc? (op)	(and (pair? op) (= 'reloc (car op))))

(define-function x86-matches? (op k size mode unsigned)
  (let ((c (x86-kind k)))
    (cond
      ((memq (car c) '(r x))	(and (x86-reg-in-mode? op mode) (= (car c) (cadr (x86-reg op))) (= (cadr c) (caddr (x86-reg op)))))
      ((= 'rm (car c))		(if (x86-mem? op) (= (cadr c) (cdr (assq (car op) x86-mem-tags)))
				  (and (x86-reg-in-mode? op mode) (= 'r (cadr (x86-reg op))) (= (cadr c) (caddr (x86-reg op))))))
      ((= 'xm (car c))		(if (x86-mem? op) (= (cadr c) (cdr (assq (car op) x86-mem-tags)))
				  (and (x86-reg-in-mode? op mode) (= 'x (cadr (x86-reg op))))))
      ((= 'mem (car c))		(and (x86-mem? op) (= (cadr c) (cdr (assq (car op) x86-mem-tags)))))
      ((= 'm (car c))		(x86-mem? op))
      ((= 'imm (car c))		(if (x86-reloc? op) (or (not (cdr op)) (= (cadr op) (* 8 (cadr c))))
				  				  (and (long? op) (x86-fits? (if unsigned op (x86-signed op size)) (cadr c) size unsigned))))
            ((= 'rel (car c))		(or (long? op) (and (x86-reloc? op) (or (not (cdr op)) (= (cadr op) (* 8 (cadr c)))))))
      ((= 'one (car c))		(= op 1))
      (else			(= op k)))))

(define-function x86-le (v n)	(if (> n 0) (cons (& v 255) (x86-le (>> v 8) (- n 1)))))

(define-function x86-scale-bits (s)	(cond ((= s 1) 0) ((= s 2) 1) ((= s 4) 2) ((= s 8) 3)))

;; ModRM, SIB and displacement for register field reg and r/m operand m in
;; mode: (bytes rex-x rex-b rip-at), rip-at the index of a RIP displacement.
(define-function x86-modrm (reg m mode)
  (if (symbol? m)
      (list (list (| 0xC0 (| (<< (& reg 7) 3) (& 7 (x86-reg-num m))))) 0 (>> (x86-reg-num m) 3) ())
    (let* ((d (cadr m)) (b (caddr m)) (i (cadddr m)) (s (car (cddddr m)))
	   (asize (if (= mode 'x64) 8 4))
	   (mrm (lambda (mod rm) (| (<< mod 6) (| (<< (& reg 7) 3) rm)))))
      (cond
	((and b (!= b 'RIP) (not (and (x86-reg-in-mode? b mode) (= asize (caddr (x86-reg b)))))) ())
	((and i (not (and (x86-reg-in-mode? i mode) (= asize (caddr (x86-reg i))) (!= 4 (x86-reg-num i))))) ())
	((not (x86-scale-bits (or s 1))) ())
	((= b 'RIP)
	 (and (= mode 'x64) (not i) (list (list (mrm 0 5) 0 0 0 0) 0 0 1)))
	(else
	 (let* ((reloc (x86-reloc? d))
		(bn (and b (x86-reg-num b)))
		(mod (cond ((not b) 0) (reloc 2) ((and (= d 0) (!= 5 (& bn 7))) 0) ((x86-fits? d 1 4 ()) 1) (else 2)))
		(disp (cond (reloc (x86-le 0 4)) ((not b) (x86-le d 4)) ((= mod 1) (x86-le d 1)) ((= mod 2) (x86-le d 4)))))
	   (and (or reloc (and (long? d) (x86-fits? d 4 8 ())))
		(cond
		  ((and (not i) b (!= 4 (& bn 7)))		(list (cons (mrm mod (& bn 7)) disp) 0 (>> bn 3) ()))
		  ((and (not i) (not b) (= mode 'x86))		(list (cons (mrm 0 5) disp) 0 0 ()))
		  (else
		   (list (cons (mrm mod 4)
			       (cons (| (<< (x86-scale-bits (or s 1)) 6)
					(| (<< (if i (& 7 (x86-reg-num i)) 4) 3) (if b (& bn 7) 5)))
				     disp))
			 (if i (>> (x86-reg-num i) 3) 0) (if b (>> bn 3) 0) ()))))))))))

(define-function x86-prefix? (t)	(memq t '(0x66 0xF2 0xF3)))

(define-function x86-nth (l i)	(while (< 0 i) (set l (cdr l)) (set i (- i 1))) (car l))
(define-function x86-take (l n)	(if (> n 0) (cons (car l) (x86-take (cdr l) (- n 1)))))
(define-function x86-splice (l at new)	; l with new written over it from index at
  (let ((i 0)) (map (lambda (b) (let ((j (- i at))) (set i (+ i 1)) (if (and (<= 0 j) (< j (list-length new))) (x86-nth new j) b))) l)))

;; (bytes . positions) for insn under row at pc in mode, or ().
(define-function x86-encode-row (row insn pc mode)
  (let ((size (x86-row-size row mode)) (unsigned (x86-unsigned? row)) (kinds (cadr row)) (ops (cdr insn))
	(reg ()) (rm ()) (imm ()) (rel ()) (plus ()) (ok 1) (positions ()) (i 0) (needs-rex ()) (no-rex ()))
    (and (= (list-length kinds) (list-length ops))
	 (let ()
	   (list-do k kinds
	     (let ((op (car ops)) (c (car (x86-kind k))))
	       (or (x86-matches? op k size mode unsigned) (set ok ()))
	       (when ok
		 (and (x86-reg op)
		      (let ((flag (car (cddddr (x86-reg op)))))
			(and (= flag 'rex) (set needs-rex 1))
			(and (= flag 'high) (set no-rex 1))))
		 (cond ((memq c '(r x))		(if (list-detect t (caddr row) (and (pair? t) (= '+r (car t)))) (set plus op) (set reg op)))
		       ((memq c '(rm m mem xm))	(set rm op))
		       ((= c 'imm)		(set imm op))
		       ((= c 'rel)		(set rel op)))
		 (and (or (= c 'rel) (x86-reloc? op) (and (x86-mem? op) (or (= 'RIP (caddr op)) (x86-reloc? (cadr op)))))
		      (set positions (cons i positions))))
	       (set ops (cdr ops))
	       (set i (+ i 1))))
	   (and ok
		(let* ((tokens (caddr row))
		       (modrm-token (list-detect t tokens (or (= t 'r) (and (pair? t) (= '/ (car t))))))
		       (m (and modrm-token (x86-modrm (if (= modrm-token 'r) (x86-reg-num reg) (cadr modrm-token)) rm mode)))
		       (rex-w (memq 'rexw tokens))
		       (rex-r (if (and reg (= modrm-token 'r)) (>> (x86-reg-num reg) 3) 0))
		       (rex-x (if m (cadr m) 0))
		       (rex-b (cond (m (caddr m)) (plus (>> (x86-reg-num plus) 3)) (else 0)))
		       (rex (| 0x40 (| (if rex-w 8 0) (| (<< rex-r 2) (| (<< rex-x 1) rex-b)))))
		       (use-rex (or rex-w (memq 'rex tokens) needs-rex (!= rex 0x40)))
		       (out (if (= size 2) (list 0x66) ()))
		       (lead 1) (rip-at ()) (rel-size 0))
		  (and (not (and modrm-token (not m)))
		       (not (and use-rex (or no-rex (= mode 'x86))))
		       (let ()
			 (list-do t tokens
			   (when (and lead (not (x86-prefix? t)))
			     (set lead ())
			     (and use-rex (set out (concat-list out (list rex)))))
			   (set out (concat-list out
			     (cond
			       ((long? t)		(list t))
			       ((memq t '(rexw rex o32 u)) ())
			       ((= t 'r)		(and (caddr (cdr m)) (set rip-at (+ (list-length out) 1))) (car m))
			       ((= (car t) '+r)	(list (| (cadr t) (& 7 (x86-reg-num plus)))))
			       ((= (car t) '/)	(and (caddr (cdr m)) (set rip-at (+ (list-length out) 1))) (car m))
			       ((memq t '(ib iw id io))
				(let ((n (cdr (assq t '((ib . 1) (iw . 2) (id . 4) (io . 8))))))
				  				  (x86-le (if (x86-reloc? imm) 0 (if (x86-unsigned? row) imm (x86-signed imm size))) n)))
			       ((memq t '(cb cd))	(set rel-size (if (= t 'cb) 1 4)) (x86-le 0 rel-size))))))
			 (and lead use-rex (set out (concat-list out (list rex))))
			 ;; PC-relative fields count from the end of the instruction.
			 (let ((end (+ pc (list-length out))) (ok2 1))
			   (when (and rel (long? rel))
			     (let ((d (- rel end)))
			       (if (x86-fits? d rel-size 8 ())
				   (set out (concat-list (x86-take out (- (list-length out) rel-size)) (x86-le d rel-size)))
				 (set ok2 ()))))
			   (when rip-at
			     (let ((d (if (x86-reloc? (cadr rm)) 0 (- (cadr rm) end))))
			       (if (x86-fits? d 4 8 ())
				   (set out (x86-splice out rip-at (x86-le d 4)))
				 (set ok2 ()))))
			   (and ok2 (cons out (list-reverse! positions))))))))))))

;;; ---------------------------------------------------------------- decoding

(define-function x86-sext (v n)		(let ((sh (- 64 (* 8 n)))) (>> (<< v sh) sh)))
(define-function x86-getle (bs n)	(if (> n 0) (| (car bs) (<< (x86-getle (cdr bs) (- n 1)) 8)) 0))
(define-function x86-drop (l n)		(if (> n 0) (x86-drop (cdr l) (- n 1)) l))

;; The r/m operand at bs (the ModRM byte): (reg-field operand rip? . rest), with
;; rex-x and rex-b extending index and base.
(define-function x86-unmodrm (bs kind size tag rex-x rex-b rex mode)
  (let* ((b0 (car bs)) (mod (>> b0 6)) (reg (& 7 (>> b0 3))) (rm (& 7 b0)) (bs (cdr bs))
	 (asize (if (= mode 'x64) 8 4)) (base ()) (index ()) (scale 1) (d 0) (rip ()))
    (if (= mod 3)
	(cons reg (cons (x86-reg-named kind size (| rm (<< rex-b 3)) (not rex) mode) (cons () bs)))
      (if (= rm 4)
	  (let ((sib (car bs)) (bn ()))
	    (set bs (cdr bs))
	    (set scale (<< 1 (>> sib 6)))
	    (let ((ix (| (& 7 (>> sib 3)) (<< rex-x 3))))
	      (or (= ix 4) (set index (x86-reg-named 'r asize ix () mode))))
	    (set bn (& 7 sib))
	    (if (and (= mod 0) (= bn 5))
		(set base ())
	      (set base (x86-reg-named 'r asize (| bn (<< rex-b 3)) () mode))))
	(if (and (= mod 0) (= rm 5))
	    (if (= mode 'x64) (set rip 1) (set base ()))
	  (set base (x86-reg-named 'r asize (| rm (<< rex-b 3)) () mode))))
      (cond ((= mod 1)				(set d (x86-sext (car bs) 1)) (set bs (cdr bs)))
	    ((or (= mod 2) rip (not base))	(set d (x86-sext (x86-getle bs 4) 4)) (set bs (x86-drop bs 4))))
      (cons reg (cons (list tag d (if rip 'RIP base) index scale) (cons rip bs))))))

;; (insn . length) if bs (a list of bytes) at pc starts with row in mode, else ().
(define-function x86-decode-row (row bs pc mode)
  (let ((size (x86-row-size row mode)) (start (list-length bs)) (tokens (caddr row)) (ok 1)
	(rex ()) (lead 1) (reg ()) (rm ()) (imm ()) (rel ()) (plus ()) (rip ()))
    (if (= size 2)
	(if (and bs (= 0x66 (car bs))) (set bs (cdr bs)) (set ok ())))
    (list-do t tokens
      (and ok
	(let ()
	  (when (and lead (not (x86-prefix? t)) (not (memq t '(rexw rex))))
	    (set lead ())
	    (and (= mode 'x64) bs (= 0x40 (& 0xF0 (car bs))) (let () (set rex (car bs)) (set bs (cdr bs)))))
	  (cond
	    ((not bs)			(or (memq t '(rexw rex o32 u)) (set ok ())))
	    ((long? t)			(if (= t (car bs)) (set bs (cdr bs)) (set ok ())))
	    ((memq t '(rexw rex o32 u)))
	    ((or (= t 'r) (= (car t) '/))
	     (let ((rk 'r) (rsize 4) (tag 'm) (xk ()))
	       (list-do k (cadr row)
		 (let ((c (x86-kind k)))
		   (cond ((= 'rm (car c))	(set rsize (cadr c)) (set tag (x86-mem-tag (cadr c))))
			 ((= 'xm (car c))	(set rk 'x) (set rsize 16) (set tag (x86-mem-tag (cadr c))))
			 ((= 'mem (car c))	(set tag (x86-mem-tag (cadr c))))
			 ((= 'm (car c))	(set tag 'm)))))
	       (let ((x (x86-unmodrm bs rk rsize tag (if rex (& 1 (>> rex 1)) 0) (if rex (& 1 rex) 0) rex mode)))
		 (if (and (pair? t) (!= (cadr t) (car x)))
		     (set ok ())
		   (set reg (car x)) (set rm (cadr x)) (set rip (caddr x)) (set bs (cdddr x))))))
	    ((= (car t) '+r)		(if (= (cadr t) (& 0xF8 (car bs)))
					    (let () (set plus (| (& 7 (car bs)) (if rex (<< (& 1 rex) 3) 0))) (set bs (cdr bs)))
					  (set ok ())))
	    (else
	     (let ((n (cdr (assq t '((ib . 1) (iw . 2) (id . 4) (io . 8) (cb . 1) (cd . 4))))))
	       (if (< (list-length bs) n)
		   (set ok ())
		 (if (memq t '(cb cd))
		     (set rel (x86-sext (x86-getle bs n) n))
		   (set imm (if (x86-unsigned? row) (x86-getle bs n) (x86-sext (x86-getle bs n) n))))
		 (set bs (x86-drop bs n)))))))))
    ;; REX.W must be present exactly when the row asks for it.
    (and ok rex (if (memq 'rexw tokens) (= 0 (& 8 rex)) (!= 0 (& 8 rex))) (set ok ()))
    (and ok (not rex) (memq 'rexw tokens) (set ok ()))
    (and ok
	 (let* ((length (- start (list-length bs))) (end (+ pc length))
		(rex-r (if rex (& 1 (>> rex 2)) 0))
		(ops (map (lambda (k)
			    (let ((c (x86-kind k)))
			      (cond ((memq (car c) '(r x))
				     (x86-reg-named (car c) (cadr c) (if plus plus (| reg (<< rex-r 3))) (not rex) mode))
				    ((memq (car c) '(rm m mem xm))
				     (if (and rip (pair? rm)) (list (car rm) (+ end (cadr rm)) 'RIP () 1) rm))
				    ((= 'imm (car c))	imm)
				    				    ((= 'rel (car c))	(+ end rel))
				    ((= 'one (car c))	1)
				    (else		k))))
			  (cadr row))))
	   (and (not (memq () ops)) (cons (cons (car row) ops) length))))))

(define-function x86-decode (rows bytes pc mode)
  (let ((bs (array->list bytes)) (r ()))
    (while (and rows (not r))
      (set r (x86-decode-row (car rows) bs pc mode))
      (set rows (cdr rows)))
    r))

;; (lo hi step) of the values operand position of row can take at pc, or ().
(define-function x86-field-range (row position pc insn mode)
  (let* ((k (x86-nth (cadr row) position)) (c (x86-kind k)) (op (and insn (x86-nth (cdr insn) position)))
	 (enc (and insn (x86-encode-row row insn pc mode)))
	 (end (and enc (+ pc (list-length (car enc))))))
    (cond
      ((= 'imm (car c))
       (let ((bits (* 8 (cadr c))) (size (x86-row-size row mode)))
	 	 (cond ((= bits 64)		(list (<< 1 63) (- (<< 1 63) 1) 1))
	       ((x86-unsigned? row)	(list 0 (- (<< 1 bits) 1) 1))
	       ((<= size (cadr c))	(list (- 0 (<< 1 (- bits 1))) (- (<< 1 bits) 1) 1))
	       (else			(list (- 0 (<< 1 (- bits 1))) (- (<< 1 (- bits 1)) 1) 1)))))
      ((and (= 'rel (car c)) end)
       (let ((bits (* 8 (cadr c)))) (list (- end (<< 1 (- bits 1))) (+ end (- (<< 1 (- bits 1)) 1)) 1)))
      ((and end (x86-mem? op) (= 'RIP (caddr op)))
       (list (- end (<< 1 31)) (+ end (- (<< 1 31) 1)) 1))
      (else ()))))

;;; ---------------------------------------------------------------- registration

(define x64-rows (list-reverse! (let ((out ())) (list-do r x86-all-rows (and (= 'V (cadddr r)) (set out (cons r out)))) out)))
(define x86-rows (list-reverse! (let ((out ())) (list-do r x86-all-rows (and (= 'V (car (cddddr r))) (set out (cons r out)))) out)))

(define-function x86-parse-form (text)
  (let ((p (text-parser-for-on <x86spec> text)))
    (and ($form p) (<text-parser>-result p))))

(asm-register-isa 'x64 x64-rows
		  (lambda (row insn pc) (x86-encode-row row insn pc 'x64))
		  (lambda (bytes pc) (x86-decode x64-rows bytes pc 'x64))
		  (lambda (row position pc . insn) (x86-field-range row position pc (car insn) 'x64))
		  x86-parse-form)
(asm-register-isa 'x86 x86-rows
		  (lambda (row insn pc) (x86-encode-row row insn pc 'x86))
		  (lambda (bytes pc) (x86-decode x86-rows bytes pc 'x86))
		  (lambda (row position pc . insn) (x86-field-range row position pc (car insn) 'x86))
		  x86-parse-form)
