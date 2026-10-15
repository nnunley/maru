;;; Encode and decode IA-32 by interpreting the SDM opcode-table rows in x86.spec.
;;; Operands: a register is its name (EAX), an immediate or branch target is a
;;; number, memory is (m32 disp base index scale), tagged m8, m16 or m32 by its
;;; size (or m, any size) as the SDM writes it, with () for no base or index.
;;; The caller supplies (_B X byte) and (_PC X), the address of the next byte.

(require "text-parser.l")
(load (concat-string *spike* "/x86.g.l"))

(define x86-rows (parse-string <x86spec> $file (contents-of-file-named (concat-string *spike* "/x86.spec"))))

(define x86-registers ())		;; (name size number)
(let ((size 1))
  (list-do names '((AL CL DL BL AH CH DH BH) (AX CX DX BX SP BP SI DI) (EAX ECX EDX EBX ESP EBP ESI EDI))
    (let ((n 0))
      (list-do r names (set x86-registers (cons (list r size n) x86-registers)) (set n (+ n 1))))
    (set size (* size 2))))

(define-function reg-size (r)		(cadr  (assq r x86-registers)))
(define-function reg-num  (r)		(caddr (assq r x86-registers)))
(define-function reg-named (size n)
  (let ((r ())) (list-do e x86-registers (and (= size (cadr e)) (= n (caddr e)) (set r (car e)))) r))

;; SDM vol. 2 section 3.1.1.3: the operand notation, as (class size).
(define x86-kinds '((r8 r 1) (r16 r 2) (r32 r 4) (r/m8 rm 1) (r/m16 rm 2) (r/m32 rm 4) (m m 0)
		    (imm8 imm 1) (imm16 imm 2) (imm32 imm 4) (rel8 rel 1) (rel32 rel 4)))

(define-function kind (k)		(or (cdr (assq k x86-kinds)) (list 'fixed k)))
(define mem-tags '((m . 0) (m8 . 1) (m16 . 2) (m32 . 4)))
(define-function mem? (x)		(and (pair? x) (assq (car x) mem-tags)))
(define-function mem-tag (size)	(car (list-detect e mem-tags (= size (cdr e)))))

;; The operand size: the widest register or memory operand, or 4 for o32.
;; DX beside another fixed register is an I/O port address, not an operand.
(define-function row-size (row)
  (let ((s (if (memq 'o32 (caddr row)) 4 0)) (ks (cadr row)))
    (list-do k ks
      (let ((c (kind k)))
	(cond ((memq (car c) '(r rm m)) (set s (max s (cadr c))))
	      ((and (= 'fixed (car c)) (not (and (= k 'DX) (list-detect j ks (and (!= j 'DX) (reg-size j))))))
	       (set s (max s (reg-size k)))))))
    s))

;; An immediate narrower than the operand size is sign-extended to it.
(define-function fits? (v n size)
  (let ((bits (* 8 n)))
    (or (and (<= (- (<< 1 (- bits 1))) v) (< v (<< 1 (- bits 1))))
	(and (<= size n) (<= 0 v) (< v (<< 1 bits))))))

(define-function matches? (op k size)
  (let ((c (kind k)))
    (cond
      ((= 'r     (car c))	(and (symbol? op) (= (cadr c) (reg-size op))))
      ((= 'rm    (car c))	(if (mem? op) (= (cadr c) (cdr (assq (car op) mem-tags))) (and (symbol? op) (= (cadr c) (reg-size op)))))
      ((= 'm     (car c))	(mem? op))
      ((= 'imm   (car c))	(and (long? op) (fits? op (cadr c) size)))
      ((= 'rel   (car c))	(long? op))
      (else			(= op k)))))

(define-function le (v n)		(if (> n 0) (cons (& v 255) (le (>> v 8) (- n 1)))))

(define-function scale-bits (s)		(cond ((= s 1) 0) ((= s 2) 1) ((= s 4) 2) ((= s 8) 3) (else (error "scale: "s))))

;; ModRM, SIB and displacement for register field reg and r/m operand m.
(define-function modrm (reg m)
  (if (symbol? m)
      (list (| 0xC0 (| (<< reg 3) (reg-num m))))
    (let* ((d (cadr m)) (b (caddr m)) (i (cadddr m)) (s (car (cddddr m)))
	   (mrm (lambda (mod rm) (| (<< mod 6) (| (<< reg 3) rm))))
	   (mod (cond ((not b) 0) ((and (= d 0) (!= b 'EBP)) 0) ((fits? d 1 4) 1) (else 2)))
	   (disp (cond ((not b) (le d 4)) ((= mod 1) (le d 1)) ((= mod 2) (le d 4)))))
      (and (= i 'ESP) (error "ESP cannot be an index"))
      (cond
	((and (not i) (not b))	(cons (mrm 0 5) disp))
	((and (not i) (!= b 'ESP)) (cons (mrm mod (reg-num b)) disp))
	(else			(cons (mrm mod 4)
				      (cons (| (<< (scale-bits (or s 1)) 6)
					       (| (<< (if i (reg-num i) 4) 3) (if b (reg-num b) 5)))
					    disp)))))))

;; The bytes for ops in this row at address pc, or () if they don't fit it.
(define-function encode-row (row ops pc)
  (let ((size (row-size row)) (kinds (cadr row)) (reg ()) (rm ()) (imm ()) (rel ()) (ok 1))
    (if (!= (list-length kinds) (list-length ops))
	()
      (list-do k kinds
	(let ((op (car ops)) (c (car (kind k))))
	  (or (matches? op k size) (set ok ()))
	  (cond ((= c 'r)	(set reg op))
		((memq c '(rm m)) (set rm op))
		((= c 'imm)	(set imm op))
		((= c 'rel)	(set rel op)))
	  (set ops (cdr ops))))
      (and ok
	   (let ((out (if (memq size '(2)) (list 0x66))) (relsize 0))
	     (list-do t (caddr row)
	       (set out (concat-list out
		 (cond
		   ((long? t)		(list t))
		   ((= t 'r)		(modrm (reg-num reg) rm))
		   ((= t 'o32)		())
		   ((= (car t) '+r)	(list (| (cadr t) (reg-num reg))))
		   ((= (car t) '/)	(modrm (cadr t) rm))
		   ((= t 'ib)		(le imm 1))
		   ((= t 'iw)		(le imm 2))
		   ((= t 'id)		(le imm 4))
		   ((= t 'cb)		(set relsize 1) ())
		   ((= t 'cd)		(set relsize 4) ())))))
	     (if (= 0 relsize)
		 out
	       (let ((d (- rel (+ pc (+ (list-length out) relsize)))))
		 (and (fits? d relsize 4) (concat-list out (le d relsize))))))))))

(define-function x86 (X mnemonic . ops)
  (let ((bytes ()) (rows x86-rows))
    (while (and rows (not bytes))
      (and (= mnemonic (caar rows)) (set bytes (encode-row (car rows) ops (_PC X))))
      (set rows (cdr rows)))
    (or bytes (error "no encoding for "mnemonic" "ops))
    (list-do b bytes (_B X b))))

;;; ---------------------------------------------------------------- decoding

(define-function sext (v n)		(let ((s (- 64 (* 8 n)))) (>> (<< v s) s)))
(define-function list-tail (l n)	(if (> n 0) (list-tail (cdr l) (- n 1)) l))
(define-function getle (bs n)		(if (> n 0) (| (car bs) (<< (getle (cdr bs) (- n 1)) 8)) 0))

;; Decode the r/m operand of size from bs (at the ModRM byte): (reg-field operand . rest).
(define-function unmodrm (bs size tag)
  (let* ((b0 (car bs)) (mod (>> b0 6)) (reg (& 7 (>> b0 3))) (rm (& 7 b0)) (bs (cdr bs))
	 (base ()) (index ()) (scale 1) (d 0))
    (if (= mod 3)
	(cons reg (cons (reg-named size rm) bs))
      (when (= rm 4)
	(let ((sib (car bs)))
	  (set bs (cdr bs))
	  (set scale (<< 1 (>> sib 6)))
	  (or (= 4 (& 7 (>> sib 3))) (set index (reg-named 4 (& 7 (>> sib 3)))))
	  (set rm (& 7 sib))
	  (and (= 0 mod) (= rm 5) (set rm ()))))
      (and rm (not (and (= mod 0) (= rm 5))) (set base (reg-named 4 rm)))
      (cond ((= mod 1)				(set d (sext (car bs) 1)) (set bs (cdr bs)))
	    ((or (= mod 2) (not base))		(set d (sext (getle bs 4) 4)) (set bs (cddddr bs))))
      (cons reg (cons (list tag d base index scale) bs)))))

;; (instruction . rest) if bs at address pc starts with this row, else ().
(define-function decode-row (row bs pc)
  (let ((size (row-size row)) (start (list-length bs)) (reg ()) (rm ()) (imm ()) (rel ()) (ok 1))
    (if (= size 2)
	(if (= 0x66 (car bs)) (set bs (cdr bs)) (set ok ()))
      (and (= 0x66 (car bs)) (set ok ())))
    (list-do t (caddr row)
      (and ok bs
	(cond
	  ((long? t)		(if (= t (car bs)) (set bs (cdr bs)) (set ok ())))
	  ((= t 'o32))
	  ((or (= t 'r) (= (car t) '/))
	   (let ((rmsize 4) (tag 'm))
	     (list-do k (cadr row) (and (= 'rm (car (kind k))) (set rmsize (cadr (kind k))) (set tag (mem-tag rmsize))))
	     (let ((x (unmodrm bs rmsize tag)))
	       (if (and (pair? t) (!= (cadr t) (car x)))
		   (set ok ())
		 (set reg (car x)) (set rm (cadr x)) (set bs (cddr x))))))
	  ((= (car t) '+r)	(if (= (cadr t) (& 0xF8 (car bs))) (let () (set reg (& 7 (car bs))) (set bs (cdr bs))) (set ok ())))
	  (else
	   (let ((n (cdr (assq t '((ib . 1) (iw . 2) (id . 4) (cb . 1) (cd . 4))))))
	     (if (memq t '(cb cd))
		 (set rel (sext (getle bs n) n))
	       (set imm (if (< size n) (getle bs n) (sext (getle bs n) n))))
	     (set bs (list-tail bs n)))))))
    (and ok
	 (cons (cons (car row)
		     (map (lambda (k)
			    (let ((c (kind k)))
			      (cond ((= 'r (car c))		(reg-named (cadr c) reg))
				    ((memq (car c) '(rm m))	rm)
				    ((= 'imm (car c))		imm)
				    ((= 'rel (car c))		(+ rel (+ pc (- start (list-length bs)))))
				    (else			k))))
			  (cadr row)))
	       bs))))

;; The first instruction in bs, at address pc: (instruction . rest).
(define-function x86-decode (bs pc)
  (let ((r ()) (rows x86-rows))
    (while (and rows (not r))
      (set r (decode-row (car rows) bs pc))
      (set rows (cdr rows)))
    (or r (cons (list 'BYTE (car bs)) (cdr bs)))))
