;;; arm64 (A64) rows: encode and decode by interpreting the Arm ARM encoding
;;; diagrams in arm64.spec.  Registers as the RFC names them (X0, W3, SP, XZR),
;;; immediates and branch targets as numbers (targets absolute), a shift as
;;; (LSL n), memory as (off X1 16), (pre SP -16) or (post SP 16).
;;; Registers itself with asm-table.l as the instruction set arm64.

(require "text-parser.l")
(load "arm64.g.l")

(define-function arm64-array-from (s i)	(let ((a (array))) (for (j i (string-length s)) (array-append a (string-at s j))) a))

(define-function arm64-field-width (f)
  (let ((s (symbol->string (car f))))
    (cond ((cdr f)				(cadr f))
	  ((= ?R (string-at s 0))		5)
	  (else					(string->number (array->string (arm64-array-from s 3)))))))

;; A row: (mnemonic operands fields mask value allowed), fields as strings of
;; bits or (name . width); allowed is the row's T=... arrangements, or ().
(define arm64-rows
  (map (lambda (row)
	 (let ((fields (map (lambda (f) (if (string? f) f (cons (car f) (arm64-field-width f)))) (caddr row)))
	       (mask 0) (value 0) (n 0))
	   (list-do f fields
	     (if (string? f)
		 (string-do c f (set mask (| (<< mask 1) 1)) (set value (| (<< value 1) (- c ?0))) (set n (+ n 1)))
	       (set mask (<< mask (cdr f))) (set value (<< value (cdr f))) (set n (+ n (cdr f)))))
	   (or (= n 32) (error (car row)" "(cadr row)": "n" bits, not 32"))
	   	   (list (car row) (cadr row) fields mask value (cadddr row))))
       (parse-string <arm64spec> $file (contents-of-file-named "arm64.spec"))))

;; Registers: (name class number kind).  The class is the letter of the operand
;; kinds that accept it (Xd takes X registers, Sd S registers); X and W number
;; 31 is SP or the zero register, kind sp or zr, as the row says.
(define-function arm64-reg-sym (p i)		(string->symbol (concat-string p (long->string i))))
(define arm64-registers ())
(for (i 0 32)
  (list-do c '("X" "W" "S" "D" "Q" "B" "H")
    (and (or (< i 31) (not (memq (string-at c 0) '(?X ?W))))
	 (set arm64-registers (cons (list (arm64-reg-sym c i) (string-at c 0) i ()) arm64-registers)))))
(set arm64-registers (concat-list '((SP ?X 31 sp) (XZR ?X 31 zr) (WSP ?W 31 sp) (WZR ?W 31 zr)) arm64-registers))

(define arm64-conditions '(EQ NE HS LO MI PL VS VC HI LS GE LT GT LE AL NV))

(define-function arm64-reg-field (r)		(let ((s (symbol->string r))) (string->symbol (concat-string "R" (array->string (arm64-array-from s 1))))))
(define-function arm64-reg-class (r)		(string-at (symbol->string r) 0))
(define-function arm64-reg-named (class n sp?)
  (car (list-detect e arm64-registers (and (= class (cadr e)) (= n (caddr e))
					 (or (< n 31) (not (memq class '(?X ?W))) (= (cadddr e) (if sp? 'sp 'zr)))))))

;; A field name may join several diagram fields (immhi:immlo, b5:b40): one value, high bits first.
(define-function arm64-parts (name)
  (let ((s (symbol->string name)) (out ()) (from 0))
    (for (i 0 (string-length s))
      (when (= ?: (string-at s i))
	(set out (cons (string->symbol (string-copy s from (- i from))) out))
	(set from (+ i 1))))
    (list-reverse! (cons (string->symbol (string-copy s from (- (string-length s) from))) out))))

(define-function arm64-width-of (row name)
  (let ((w 0))
    (list-do part (arm64-parts name)
      (set w (+ w (cdr (list-detect f (caddr row) (and (pair? f) (= part (car f))))))))
    w))

;; Bind q, a value of the joined field name, onto env part by part.
(define-function arm64-bind-field (row name q env)
  (list-do part (list-reverse! (arm64-parts name))
    (let ((w (arm64-width-of row part)))
      (set env (cons (cons part (& q (- (<< 1 w) 1))) env))
      (set q (>> q w))))
  env)

;;; Bit patterns: logical immediates (DecodeBitMasks) and FP immediates (VFPExpandImm).

(define-function arm64-ones (n)		(if (< n 64) (- (<< 1 n) 1) -1))
(define-function arm64-lsr (x r)	(if (= 0 r) x (& (>> x r) (arm64-ones (- 64 r)))))
(define-function arm64-ror (x r e)	(if (= 0 r) x (& (| (arm64-lsr x r) (<< x (- e r))) (arm64-ones e))))

;; (n immr imms) encoding v as a w-bit logical immediate, smallest element first, or ().
(define-function arm64-bitmask (v w)
  (let ((found ()) (e 2))
    (set v (& v (arm64-ones w)))
    (while (and (not found) (<= e w))
      (let ((elt (& v (arm64-ones e))) (rep 0) (i 0) (ones 0))
	(while (< i w) (set rep (| rep (<< elt i))) (set i (+ i e)))
	(for (b 0 e) (and (!= 0 (& (arm64-lsr elt b) 1)) (set ones (+ ones 1))))
	(and (= (& rep (arm64-ones w)) v) (< 0 ones) (< ones e)
	     (for (r 0 e)
	       (and (not found) (= elt (arm64-ror (arm64-ones ones) r e))
		    (set found (list (if (= e 64) 1 0) r (| (& (<< (- 0 e) 1) 63) (- ones 1))))))))
      (set e (* e 2)))
    found))

;; The w-bit value of logical-immediate fields n, immr, imms, or () if reserved.
(define-function arm64-bitmask-value (n immr imms w)
  (let ((len 6) (key (| (<< n 6) (& (- 63 imms) 63))))
    (while (and (<= 0 len) (= 0 (& key (<< 1 len)))) (set len (- len 1)))
    (and (< 0 len)
	 (let* ((e (<< 1 len)) (ones (+ 1 (& imms (- e 1)))) (elt ()) (v 0) (i 0))
	   (and (< ones e) (<= e w) (< immr e)
		(let ()
		  (set elt (arm64-ror (arm64-ones ones) immr e))
		  (while (< i w) (set v (| v (<< elt i))) (set i (+ i e)))
		  (if (= w 64) v (& v (arm64-ones w)))))))))

(define-function arm64-fp8-value (sign n m)
  (let ((v (/ (+ 16 m) 16.0)))
    (while (< 0 n) (set v (* v 2)) (set n (- n 1)))
    (while (< n 0) (set v (/ v 2)) (set n (+ n 1)))
    (if (= sign 1) (- 0 v) v)))

;; imm8 for x = +/-(16+m)/16 * 2^n, m in 0..15, n in -3..4, or ().
(define-function arm64-fp8 (x)
  (and (or (long? x) (double? x))
       (let ((found ()) (sign (if (< x 0) 1 0)) (a (if (< x 0) (- 0 x) x)))
	 (for (n -3 5)
	   (for (m 0 16)
	     (and (not found) (= a (arm64-fp8-value 0 n m))
		  (set found (| (<< sign 7) (| (<< (if (<= n 0) 1 0) 6) (| (<< (if (<= n 0) (+ n 3) (- n 1)) 4) m)))))))
	 found)))

(define-function arm64-fp8-decode (q)
  (let ((b (& 1 (>> q 6))) (cd (& 3 (>> q 4))))
    (arm64-fp8-value (& 1 (>> q 7)) (if (= b 1) (- cd 3) (+ cd 1)) (& q 15))))

;;; Vector arrangements: (name size-index q).  A row's arrangement variable T
;;; sets whichever of its fields q, size (2 bits) or sz (1 bit) it has.

;; Maru reads 4S as 4 and S, so arrangement names are made from strings, and
;; in data a vector register is (V n count size): (V 3 4 S) is V3.4S, which is
;; what (V 3 4S) reads as.  A lane is (V n size index): (V 3 S 1) is V3.S[1].
(define-function arm64-arr (name)	(string->symbol name))
(define arm64-arrangements
  (map (lambda (e) (cons (arm64-arr (car e)) (cdr e)))
       '(("8B" 0 0) ("16B" 0 1) ("4H" 1 0) ("8H" 1 1) ("2S" 2 0) ("4S" 2 1) ("1D" 3 0) ("2D" 3 1))))
(define arm64-arrangements-fp	(map arm64-arr '("2S" "4S" "2D")))
(define arm64-arrangements-int	(map arm64-arr '("8B" "16B" "4H" "8H" "2S" "4S" "2D")))

;; Data (V n count size) to its arrangement name, and back.
(define-function arm64-data-arr (op)
  (string->symbol (concat-string (long->string (caddr op)) (symbol->string (cadddr op)))))
(define-function arm64-arr-data (n arr)
  (let* ((s (symbol->string arr)) (i 0))
    (while (and (< i (string-length s)) (<= ?0 (string-at s i)) (<= (string-at s i) ?9)) (set i (+ i 1)))
    (list 'V n (string->number (string-copy s 0 i)) (string->symbol (string-copy s i (- (string-length s) i))))))

(define-function arm64-has-field? (row name)	(list-detect f (caddr row) (and (pair? f) (= name (car f)))))

(define-function arm64-allowed (row)
  (or (cadr (cddddr row))
            (if (arm64-has-field? row 'sz) arm64-arrangements-fp arm64-arrangements-int)))

(define-function arm64-esize (arr)	(<< 8 (cadr (assq arr arm64-arrangements))))	; bits per element

;; Bind arrangement arr for row onto env, consistently with any already bound.
(define-function arm64-bind-arrangement (row arr env)
  (let ((a (assq arr arm64-arrangements)) (bound (assq 'T env)))
    (and a (memq arr (arm64-allowed row)) (or (not bound) (= (cdr bound) arr))
	 (let ((sz (- (cadr a) 2)))
	   (and (or (not (arm64-has-field? row 'sz)) (<= 0 sz))
		(let ((e (cons (cons 'T arr) env)))
		  (and (arm64-has-field? row 'q) (set e (cons (cons 'q (caddr a)) e)))
		  (and (arm64-has-field? row 'size) (set e (cons (cons 'size (cadr a)) e)))
		  (and (arm64-has-field? row 'sz) (set e (cons (cons 'sz sz) e)))
		  e))))))

(define-function arm64-vector? (op)	; (V n count size) or a lane (V n size index)
  (and (pair? op) (= 'V (car op)) (= 4 (list-length op)) (long? (cadr op)) (<= 0 (cadr op)) (< (cadr op) 32)))

(define-function arm64-cond-code (c)
  (let ((i 0) (found ()))
    (list-do x arm64-conditions (and (= x c) (set found i)) (set i (+ i 1)))
    found))

(define-function arm64-reloc? (op)	(and (pair? op) (= 'reloc (car op))))
(define-function arm64-has-reloc? (op)	(and (pair? op) (or (arm64-reloc? op) (arm64-has-reloc? (car op)) (arm64-has-reloc? (cdr op)))))
(define-function arm64-page (pc)	(& pc -4096))

;; The field value for v under arm64-operand kind (imm|simm|pcrel f scale), or () if it doesn't fit.
(define-function arm64-scaled (row k v)
  (let* ((w (arm64-width-of row (cadr k))) (s (caddr k)) (q (and (long? v) (/ v s))))
    (and q (= v (* q s))
	 (if (= 'imm (car k))
	     (and (<= 0 q) (< q (<< 1 w)) q)
	   (and (<= (- (<< 1 (- w 1))) q) (< q (<< 1 (- w 1))) (& q (- (<< 1 w) 1)))))))

;; Bind the fields arm64-operand op fills under kind k, onto env; () if it doesn't match.
(define-function arm64-bind (row k op env pc)
  (let ((c (car k)))
    (cond
            ((= c 'reg)	(let ((r (assq op arm64-registers)))
			  (and r (= (cadr r) (arm64-reg-class (cadr k)))
			       (or (not (cadddr r)) (= (cadddr r) (if (caddr k) 'sp 'zr)))
			       (cons (cons (arm64-reg-field (cadr k)) (caddr r)) env))))
                  ((= c 'vreg)	(and (arm64-vector? op) (long? (caddr op))
			     (let* ((arr (arm64-data-arr op))
				    (e (if (= 'T (caddr k)) (arm64-bind-arrangement row arr env) (and (= (caddr k) arr) env))))
			       (and e (cons (cons (arm64-reg-field (cadr k)) (cadr op)) e)))))
      ((= c 'vbrace)	(arm64-bind row (cadr k) op env pc))
            ((= c 'vlane)	(and (arm64-vector? op) (symbol? (caddr op)) (= (string->symbol (caddr k)) (caddr op))
			     (let ((q (arm64-scaled row (cadddr k) (cadddr op))))
			       (and q (arm64-bind-field row (cadr (cadddr k)) q (cons (cons (arm64-reg-field (cadr k)) (cadr op)) env))))))
      ((memq c '(vshl vshr))
			(let* ((bound (assq 'T env)) (e (and bound (arm64-esize (cdr bound)))))
			  (and e (long? op)
			       (if (= c 'vshl) (and (<= 0 op) (< op e)) (and (< 0 op) (<= op e)))
			       (arm64-bind-field row 'immh:immb (if (= c 'vshl) (+ e op) (- (* 2 e) op)) env))))
      ((= c 'bimm)	(let ((f (and (long? op) (arm64-bitmask op (cadr k)))))
			  (and f (cons (cons 'n (car f)) (cons (cons 'immr (cadr f)) (cons (cons 'imms (caddr f)) env))))))
      ((= c 'lslimm)	(let ((w (cadr k)))
			  (and (long? op) (<= 0 op) (< op w)
			       (cons (cons 'immr (& (- w op) (- w 1))) (cons (cons 'imms (- (- w 1) op)) env)))))
      ((= c 'fimm)	(let ((q (arm64-fp8 op))) (and q (cons (cons 'imm8 q) env))))
      ((= c 'cond)	(let ((q (arm64-cond-code op))) (and q (cons (cons 'cond q) env))))
      ((= c 'invcond)	(let ((q (arm64-cond-code op)))	; CSET encodes the inverted condition
			  (and q (< q 14) (cons (cons 'cond (if (= 0 (& q 1)) (+ q 1) (- q 1))) env))))
      ((= c 'mreg)	(and (pair? op) (= 'reg (car op)) (= (list-length op) (list-length k))
			     (equal (cdddr op) (cdddr k))
			     (let ((e (arm64-bind row (cadr k) (cadr op) env pc)))
			       (and e (arm64-bind row (caddr k) (caddr op) e pc)))))
            ((and (memq c '(imm simm pcrel pcpage)) (arm64-reloc? op))	; a placeholder: zero for now
			(and (not (= 'imm0 (cadr k)))
			     (or (not (cdr op)) (= (cadr op) (arm64-width-of row (cadr k))))
			     (arm64-bind-field row (cadr k) 0 env)))
            ((and (= c 'imm) (= 'imm0 (cadr k)))	(and (= op 0) env))
      ((memq c '(imm simm))
			(let ((q (arm64-scaled row k op))) (and q (arm64-bind-field row (cadr k) q env))))
      ((= c 'pcrel)	(let ((q (and (long? op) (arm64-scaled row k (- op pc))))) (and q (arm64-bind-field row (cadr k) q env))))
      ((= c 'pcpage)	(let ((q (and (long? op) (arm64-scaled row (cons 'simm (cdr k)) (- op (arm64-page pc))))))
			  (and q (arm64-bind-field row (cadr k) q env))))
      ((= c 'lsl)	(and (pair? op) (= 'LSL (car op))
			     (let ((q (arm64-scaled (list () () (caddr row)) (list 'imm (cadr k) (caddr k)) (cadr op))))
			       (and q (cons (cons (cadr k) q) env)))))
      (else		(and (pair? op) (= c (car op))
			     (let ((e (arm64-bind row (cadr k) (cadr op) env pc)))
			       (and e (arm64-bind row (caddr k) (caddr op) e pc))))))))

(define-function arm64-encode-row (row ops pc)
  (let ((env ()) (ok 1) (kinds (cadr row)))
    (and (= (list-length kinds) (list-length ops))
	 (let ()
	   (list-do k kinds
	     (and ok (or (set env (arm64-bind row k (car ops) env pc)) (set ok ())))
	     (set ops (cdr ops)))
	   (and ok
		(let ((word 0))
		  (list-do f (caddr row)
		    (if (string? f)
			(string-do c f (set word (| (<< word 1) (- c ?0))))
		      (let ((b (assq (car f) env)))
			(or b (error (car row)": field "(car f)" has no arm64-operand"))
			(set word (| (<< word (cdr f)) (cdr b))))))
		  word))))))

;;; ---------------------------------------------------------------- decoding

(define-function arm64-nth (l i)		(while (< 0 i) (set l (cdr l)) (set i (- i 1))) (car l))

(define-function arm64-sext (v n)		(let ((s (- 64 n))) (>> (<< v s) s)))

;; The value of field name in word.
(define-function arm64-part-of (row word name)
  (let ((shift 32) (v ()))
    (list-do f (caddr row)
      (let ((w (if (string? f) (string-length f) (cdr f))))
	(set shift (- shift w))
	(and (pair? f) (= name (car f)) (set v (& (>> word shift) (- (<< 1 w) 1))))))
    v))

(define-function arm64-field-of (row word name)
  (let ((v 0))
    (list-do part (arm64-parts name)
      (set v (| (<< v (arm64-width-of row part)) (arm64-part-of row word part))))
    v))

;; The arrangement word encodes for row: the one allowed arrangement its q,
;; size, sz or immh fields agree with, or ().
(define-function arm64-decode-arrangement (row word)
  (let ((found ()) (n 0))
    (list-do arr (arm64-allowed row)
      (let ((a (assq arr arm64-arrangements)))
	(when (and (or (not (arm64-has-field? row 'q)) (= (caddr a) (arm64-part-of row word 'q)))
		   (or (not (arm64-has-field? row 'size)) (= (cadr a) (arm64-part-of row word 'size)))
		   (or (not (arm64-has-field? row 'sz)) (= (- (cadr a) 2) (arm64-part-of row word 'sz)))
		   (or (not (arm64-has-field? row 'immh))
		       (let ((immh (arm64-part-of row word 'immh)) (top 3))
			 (while (and (<= 0 top) (= 0 (& immh (<< 1 top)))) (set top (- top 1)))
			 (= top (cadr a)))))
	  (set found arr)
	  (set n (+ n 1)))))
    (and (= n 1) found)))

;; The operand kind k reads from word, or 'invalid when this row does not
;; describe it (a reserved bit pattern, or an alias another row decodes).
(define-function arm64-operand (row k word pc)
  (let ((c (car k)))
    (cond
      ((= c 'reg)	(arm64-reg-named (arm64-reg-class (cadr k)) (arm64-field-of row word (arm64-reg-field (cadr k))) (caddr k)))
            ((= c 'vreg)	(let ((arr (if (= 'T (caddr k)) (arm64-decode-arrangement row word) (caddr k))))
			  			  (if arr (arm64-arr-data (arm64-field-of row word (arm64-reg-field (cadr k))) arr) 'invalid)))
      ((= c 'vbrace)	(arm64-operand row (cadr k) word pc))
      ((= c 'vlane)	(list 'V (arm64-field-of row word (arm64-reg-field (cadr k))) (string->symbol (caddr k))
			      (arm64-field-of row word (cadr (cadddr k)))))
      ((memq c '(vshl vshr))
			(let* ((arr (arm64-decode-arrangement row word)) (e (and arr (arm64-esize arr)))
			       (v (arm64-field-of row word 'immh:immb))
			       (s (and e (if (= c 'vshl) (- v e) (- (* 2 e) v)))))
			  (if (and s (if (= c 'vshl) (and (<= 0 s) (< s e)) (and (< 0 s) (<= s e)))) s 'invalid)))
      ((= c 'bimm)	(or (arm64-bitmask-value (or (arm64-part-of row word 'n) 0) (arm64-part-of row word 'immr)
						 (arm64-part-of row word 'imms) (cadr k))
			    'invalid))
      ((= c 'lslimm)	(let* ((w (cadr k)) (s (- (- w 1) (arm64-part-of row word 'imms))))
			  (if (and (<= 0 s) (= (arm64-part-of row word 'immr) (& (- w s) (- w 1)))) s 'invalid)))
      ((= c 'fimm)	(arm64-fp8-decode (arm64-part-of row word 'imm8)))
      ((= c 'cond)	(arm64-nth arm64-conditions (arm64-part-of row word 'cond)))
      ((= c 'invcond)	(let ((q (arm64-part-of row word 'cond)))
			  (if (< q 14) (arm64-nth arm64-conditions (if (= 0 (& q 1)) (+ q 1) (- q 1))) 'invalid)))
      ((= c 'mreg)	(concat-list (list 'reg (arm64-operand row (cadr k) word pc) (arm64-operand row (caddr k) word pc))
				     (cdddr k)))
      ((= c 'imm)	(if (= 'imm0 (cadr k)) 0 (* (caddr k) (arm64-field-of row word (cadr k)))))
      ((= c 'simm)	(* (caddr k) (arm64-sext (arm64-field-of row word (cadr k)) (arm64-width-of row (cadr k)))))
      ((= c 'pcrel)	(+ pc (* (caddr k) (arm64-sext (arm64-field-of row word (cadr k)) (arm64-width-of row (cadr k))))))
            ((= c 'pcpage)	(+ (arm64-page pc) (* (caddr k) (arm64-sext (arm64-field-of row word (cadr k)) (arm64-width-of row (cadr k))))))
      ((= c 'lsl)	(list 'LSL (* (caddr k) (arm64-field-of row word (cadr k)))))
      (else		(list c (arm64-operand row (cadr k) word pc) (arm64-operand row (caddr k) word pc))))))

;; The instruction encoded by word at address pc: the first row whose bits
;; match and whose operands all decode.
(define-function arm64-decode-word (word pc)
  (let ((rows arm64-rows) (insn ()))
    (while (and rows (not insn))
      (let ((r (car rows)))
	(when (= (cadddr (cdr r)) (& word (cadddr r)))
	  (let ((ops (map (lambda (k) (arm64-operand r k word pc)) (cadr r))))
	    (or (memq 'invalid ops) (set insn (cons (car r) ops))))))
      (set rows (cdr rows)))
    insn))

;;; ---------------------------------------------------------------- registration

(define-function arm64-encode (row insn pc)
  (let ((word (arm64-encode-row row (cdr insn) pc)))
    (and word
	 		 (let ((positions ()) (i 0) (ops (cdr insn)))
		   (list-do k (cadr row)
		     (and (or (memq (car k) '(pcrel pcpage)) (arm64-has-reloc? (car ops))) (set positions (cons i positions)))
		     (set ops (cdr ops))
		     (set i (+ i 1)))
	   (cons (list (& 255 word) (& 255 (>> word 8)) (& 255 (>> word 16)) (& 255 (>> word 24)))
		 (list-reverse! positions))))))

(define-function arm64-decode (bytes pc)
  (and (<= 4 (array-length bytes))
       (let ((insn (arm64-decode-word (| (| (array-at bytes 0) (<< (array-at bytes 1) 8))
					    (| (<< (array-at bytes 2) 16) (<< (array-at bytes 3) 24)))
				      pc)))
	 (and insn (cons insn 4)))))

;; (lo hi step) of the values operand position of row can take at pc, or () if
;; it has no field a placeholder can stand for.  A memory operand's range is
;; its offset's.
(define-function arm64-field-range (row position pc . insn)
  (let ((k (cadr row)))
    (while (< 0 position) (set k (cdr k)) (set position (- position 1)))
    (set k (car k))
    (and (memq (car k) '(off pre post)) (set k (caddr k)))
    (let ((c (car k)))
      (and (memq c '(imm simm pcrel pcpage)) (not (= 'imm0 (cadr k)))
	   (let* ((w (arm64-width-of row (cadr k))) (s (caddr k))
		  (half (<< 1 (- w 1)))
		  (base (cond ((= c 'pcrel) pc) ((= c 'pcpage) (arm64-page pc)) (else 0))))
	     (if (= c 'imm)
		 (list 0 (* s (- (<< 1 w) 1)) s)
	       (list (+ base (* s (- 0 half))) (+ base (* s (- half 1))) s)))))))

(define-function arm64-parse-form (text)
  (let ((p (text-parser-for-on <arm64spec> text)))
    (and ($form p) (<text-parser>-result p))))

(asm-register-isa 'arm64 arm64-rows arm64-encode arm64-decode arm64-field-range arm64-parse-form)
