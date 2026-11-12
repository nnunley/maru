;;; arm64 (A64) rows: encode and decode by interpreting the Arm ARM encoding
;;; diagrams in arm64.spec.  Registers as the RFC names them (X0, W3, SP, XZR),
;;; immediates and branch targets as numbers (targets absolute), a shift as
;;; (LSL n), memory as (off X1 16), (pre SP -16) or (post SP 16).
;;; Registers itself with asm-table.l as the instruction set arm64.

(require "text-parser.l")
(require "asm-table.l")
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

;;; Bit patterns: logical immediates (DecodeBitMasks) and FP immediates (VFPExpandImm).

(define-function arm64-ones (n)		(if (< n 64) (- (<< 1 n) 1) -1))
(define-function arm64-lsr (x r)	(if (= 0 r) x (& (>> x r) (arm64-ones (- 64 r)))))
(define-function arm64-ror (x r e)	(if (= 0 r) x (& (| (arm64-lsr x r) (<< x (- e r))) (arm64-ones e))))

;; (n immr imms) encoding v as a w-bit logical immediate, smallest element first, or ().
(define-function arm64-bitmask (v w)
    (let ((found ()) (e 2))
    (and (< w 64) (or (< v (- 0 (<< 1 (- w 1)))) (<= (<< 1 w) v)) (set e (+ w 1)))	; wider than w bits: refused
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

(define-function arm64-vector? (op)	; (V n count size) or a lane (V n size index)
  (and (pair? op) (= 'V (car op)) (= 4 (list-length op)) (long? (cadr op)) (<= 0 (cadr op)) (< (cadr op) 32)))

(define-function arm64-cond-code (c)
  (let ((i 0) (found ()))
    (list-do x arm64-conditions (and (= x c) (set found i)) (set i (+ i 1)))
    found))

(define-function arm64-reloc? (op)	(and (pair? op) (= 'reloc (car op))))
(define-function arm64-has-reloc? (op)	(and (pair? op) (or (arm64-reloc? op) (arm64-has-reloc? (car op)) (arm64-has-reloc? (cdr op)))))
(define-function arm64-page (pc)	(& pc -4096))

;;; ---------------------------------------------------------------- compiled rows
;;;
;;; A row's plan is made once, when the rows are read: each named field of its
;;; diagram is a slot, numbered in diagram order, with its shift in the word, and
;;; each operand kind is compiled against those slots.  Encoding binds the
;;; operands into a fresh array of slot values, one more slot holding the
;;; arrangement (T), then shifts each value into the row's fixed bits: no field
;;; is looked up by name.  A field reference is (width (slot . width) ...), its
;;; parts low first.

(define-structure <arm64-plan> (names shifts kinds t-slot allowed q size sz))

(define-function arm64-row-plan (row)	(cadr (cdr (cddddr row))))

(define-function arm64-slot (slots name)	(cadr (assq name slots)))	; slots: ((name slot shift width) ...)

(define-function arm64-field-ref (slots name)	; or () when the diagram lacks a part
  (let ((parts ()) (w 0) (ok 1))
    (list-do part (arm64-parts name)
      (let ((s (assq part slots)))
	(if s
	    (let () (set parts (cons (cons (cadr s) (cadddr s)) parts)) (set w (+ w (cadddr s))))
	  (set ok ()))))
    (and ok (cons w parts))))

;; The plan of operand kind k against slots: (tag info...), what arm64-bind-plan needs, names resolved.
(define-function arm64-plan-kind (slots k)
  (let ((c (car k)))
    (cond ((= c 'reg)		(list 'reg (arm64-slot slots (arm64-reg-field (cadr k))) (arm64-reg-class (cadr k))
				      (if (caddr k) 'sp 'zr)))
	  ((= c 'vreg)		(list 'vreg (arm64-slot slots (arm64-reg-field (cadr k))) (caddr k)))
	  ((= c 'vbrace)	(arm64-plan-kind slots (cadr k)))
	  ((= c 'vlane)		(list 'vlane (arm64-slot slots (arm64-reg-field (cadr k))) (string->symbol (caddr k))
				      (arm64-plan-kind slots (cadddr k))))
	  ((memq c '(vshl vshr))	(list c (arm64-field-ref slots 'immh:immb)))
	  ((= c 'bimm)		(list 'bimm (cadr k) (arm64-slot slots 'n) (arm64-slot slots 'immr) (arm64-slot slots 'imms)))
	  ((= c 'lslimm)	(list 'lslimm (cadr k) (arm64-slot slots 'immr) (arm64-slot slots 'imms)))
	  ((= c 'fimm)		(list 'fimm (arm64-slot slots 'imm8)))
	  ((memq c '(cond invcond))	(list c (arm64-slot slots 'cond)))
	  ((= c 'mreg)		(list 'mreg (list-length k) (cdddr k)
				      (arm64-plan-kind slots (cadr k)) (arm64-plan-kind slots (caddr k))))
	  ((and (= c 'imm) (= 'imm0 (cadr k)))	(list 'imm0))
	  ((memq c '(imm simm pcrel pcpage))	(list c (arm64-field-ref slots (cadr k)) (caddr k)))
	  ((= c 'lsl)		(list 'lsl (arm64-field-ref slots (cadr k)) (caddr k)))
	  (else			(list 'tag c (arm64-plan-kind slots (cadr k)) (arm64-plan-kind slots (caddr k)))))))

(define-function arm64-plan (row)
  (let ((slots ()) (shift 32) (n 0))
    (list-do f (caddr row)
      (let ((w (if (string? f) (string-length f) (cdr f))))
	(set shift (- shift w))
	(when (pair? f)
	  (and (assq (car f) slots) (error (car row)": field "(car f)" twice in its diagram"))
	  (set slots (cons (list (car f) n shift w) slots))
	  (set n (+ n 1)))))
    (let ((names (array n)) (shifts (array n)))
      (list-do s slots (set-array-at names (cadr s) (car s)) (set-array-at shifts (cadr s) (caddr s)))
      (new <arm64-plan> names shifts (map (lambda (k) (arm64-plan-kind slots k)) (cadr row)) n
	   (arm64-allowed row) (arm64-slot slots 'q) (arm64-slot slots 'size) (arm64-slot slots 'sz)))))

;; Field reference ref takes value q, part by part, low first.
(define-function arm64-put-ref (ref q vals)
  (list-do part (cdr ref)
    (set-array-at vals (car part) (& q (- (<< 1 (cdr part)) 1)))
    (set q (>> q (cdr part))))
  vals)

(define-function arm64-put (vals slot v)	(and slot (set-array-at vals slot v)) vals)

;; The field value for v, a multiple of s in a field w bits wide (signed unless tag is imm), or () if it doesn't fit.
(define-function arm64-scaled (tag w s v)
  (let ((q (and (long? v) (/ v s))))
    (and q (= v (* q s))
	 (if (= 'imm tag)
	     (and (<= 0 q) (< q (<< 1 w)) q)
	   (and (<= (- (<< 1 (- w 1))) q) (< q (<< 1 (- w 1))) (& q (- (<< 1 w) 1)))))))

;; Bind arrangement arr, consistently with any already bound.
(define-function arm64-bind-arrangement (plan arr vals)
  (let ((a (assq arr arm64-arrangements)) (bound (array-at vals (<arm64-plan>-t-slot plan))))
    (and a (memq arr (<arm64-plan>-allowed plan)) (or (not bound) (= bound arr))
	 (let ((sz (- (cadr a) 2)))
	   (and (or (not (<arm64-plan>-sz plan)) (<= 0 sz))
		(let ()
		  (set-array-at vals (<arm64-plan>-t-slot plan) arr)
		  (arm64-put vals (<arm64-plan>-q plan) (caddr a))
		  (arm64-put vals (<arm64-plan>-size plan) (cadr a))
		  (arm64-put vals (<arm64-plan>-sz plan) sz)))))))

;; A register's entry, (name class number kind), by its name.
(define arm64-register-table (identity-hash-table))
(list-do r arm64-registers (hash-at-put arm64-register-table (car r) r))

;; Bind op under the compiled kind p into vals; vals, or () if it doesn't match.
(define-function arm64-bind-plan (plan p op vals pc)
  (let ((c (car p)))
    (cond
      ((= c 'reg)	(let ((r (and (symbol? op) (hash-at arm64-register-table op))))
			  (and r (= (cadr r) (caddr p))
			       (or (not (cadddr r)) (= (cadddr r) (cadddr p)))
			       (arm64-put vals (cadr p) (caddr r)))))
      ((= c 'vreg)	(and (arm64-vector? op) (long? (caddr op))
			     (let ((arr (arm64-data-arr op)))
			       (and (if (= 'T (caddr p)) (arm64-bind-arrangement plan arr vals) (= (caddr p) arr))
				    (arm64-put vals (cadr p) (cadr op))))))
      ((= c 'vlane)	(and (arm64-vector? op) (symbol? (caddr op)) (= (caddr p) (caddr op))
			     (let* ((lane (cadddr p)) (ref (cadr lane))
				    (q (and ref (arm64-scaled (car lane) (car ref) (caddr lane) (cadddr op)))))
			       (and q (arm64-put-ref ref q (arm64-put vals (cadr p) (cadr op)))))))
      ((memq c '(vshl vshr))
			(let* ((bound (array-at vals (<arm64-plan>-t-slot plan))) (e (and bound (arm64-esize bound))))
			  (and e (long? op)
			       (if (= c 'vshl) (and (<= 0 op) (< op e)) (and (< 0 op) (<= op e)))
			       (arm64-put-ref (cadr p) (if (= c 'vshl) (+ e op) (- (* 2 e) op)) vals))))
      ((= c 'bimm)	(let ((f (and (long? op) (arm64-bitmask op (cadr p)))))
			  (and f (arm64-put (arm64-put (arm64-put vals (caddr p) (car f)) (cadddr p) (cadr f))
					    (car (cddddr p)) (caddr f)))))
      ((= c 'lslimm)	(let ((w (cadr p)))
			  (and (long? op) (<= 0 op) (< op w)
			       (arm64-put (arm64-put vals (caddr p) (& (- w op) (- w 1))) (cadddr p) (- (- w 1) op)))))
      ((= c 'fimm)	(let ((q (arm64-fp8 op))) (and q (arm64-put vals (cadr p) q))))
      ((= c 'cond)	(let ((q (arm64-cond-code op))) (and q (arm64-put vals (cadr p) q))))
      ((= c 'invcond)	(let ((q (arm64-cond-code op)))	; CSET encodes the inverted condition
			  (and q (< q 14) (arm64-put vals (cadr p) (if (= 0 (& q 1)) (+ q 1) (- q 1))))))
      ((= c 'mreg)	(and (pair? op) (= 'reg (car op)) (= (list-length op) (cadr p))
			     (equal (cdddr op) (caddr p))
			     (arm64-bind-plan plan (cadddr p) (cadr op) vals pc)
			     (arm64-bind-plan plan (car (cddddr p)) (caddr op) vals pc)))
      ((= c 'imm0)	(and (= op 0) vals))
      ((and (memq c '(imm simm pcrel pcpage)) (arm64-reloc? op))	; a placeholder: zero for now
			(let ((ref (cadr p)))
			  (and ref (or (not (cdr op)) (= (cadr op) (car ref))) (arm64-put-ref ref 0 vals))))
      ((memq c '(imm simm pcrel pcpage lsl))
			(let* ((ref (cadr p))
			       (v (cond ((= c 'pcrel)	(and (long? op) (- op pc)))
					((= c 'pcpage)	(and (long? op) (- op (arm64-page pc))))
					((= c 'lsl)	(and (pair? op) (= 'LSL (car op)) (cadr op)))
					(else		op)))
			       (q (and ref v (arm64-scaled (if (memq c '(imm lsl)) 'imm 'simm) (car ref) (caddr p) v))))
			  (and q (arm64-put-ref ref q vals))))
      (else		(and (pair? op) (= (cadr p) (car op))
			     (arm64-bind-plan plan (caddr p) (cadr op) vals pc)
			     (arm64-bind-plan plan (cadddr p) (caddr op) vals pc))))))

(list-do row arm64-rows (set-cdr (cdr (cddddr row)) (list (arm64-plan row))))

(define-function arm64-encode-row (row ops pc)
  (let* ((plan (arm64-row-plan row)) (kinds (<arm64-plan>-kinds plan)))
    (and (= (list-length kinds) (list-length ops))
	 (let ((vals (array (+ 1 (<arm64-plan>-t-slot plan)))) (ok 1))
	   (list-do p kinds
	     (and ok (or (arm64-bind-plan plan p (car ops) vals pc) (set ok ())))
	     (set ops (cdr ops)))
	   (and ok
		(let ((word (car (cddddr row))) (shifts (<arm64-plan>-shifts plan)))	; the fixed bits, then each field
		  (for (i 0 (<arm64-plan>-t-slot plan))
		    (let ((v (array-at vals i)))
		      (or v (error (car row)": field "(array-at (<arm64-plan>-names plan) i)" has no arm64-operand"))
		      (set word (| word (<< v (array-at shifts i))))))
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

;;; Operand shapes for the candidate table (asm-table.l), by what an operand is:
;;; 'num (a number or a placeholder), (reg class special) for a register
;;; (special sp or zr for X and W 31), 'sym (any other symbol), 'vec (a vector
;;; or a lane), (mem tag base offset) for a memory operand, and (pair tag) for
;;; any other list.  A kind that its test reads from the value takes every
;;; number, and a kind this does not know takes anything.

;; A register's shape, by its name: one shape for each class and kind.
(define arm64-register-shapes (identity-hash-table))
(list-do r arm64-registers
  (hash-at-put arm64-register-shapes (car r) (asm-intern-shape (list 'reg (cadr r) (cadddr r)))))

(define-function arm64-shape (op)
  (cond ((or (long? op) (double? op) (arm64-reloc? op))	'num)
	((symbol? op)				(or (hash-at arm64-register-shapes op) 'sym))
	((arm64-vector? op)			'vec)
	((memq (car op) '(off pre post))	(asm-intern-shape (list 'mem (car op) (arm64-shape (cadr op))
									(arm64-shape (caddr op)))))
	(else					(asm-intern-shape (list 'pair (car op))))))

(define-function arm64-accepts (k s)
  (let ((c (car k)))
    (cond ((= c 'reg)		(and (pair? s) (= 'reg (car s)) (= (arm64-reg-class (cadr k)) (cadr s))
				     (or (not (caddr s)) (= (caddr s) (if (caddr k) 'sp 'zr)))))
	  ((memq c '(vreg vlane))	(= 'vec s))
	  ((= c 'vbrace)		(arm64-accepts (cadr k) s))
	  ((memq c '(vshl vshr imm simm pcrel pcpage bimm lslimm fimm))	(= 'num s))
	  ((memq c '(cond invcond))	(= 'sym s))
	  ((= c 'lsl)			(and (pair? s) (= 'pair (car s)) (= 'LSL (cadr s))))
	  ((memq c '(off pre post))	(and (pair? s) (= 'mem (car s)) (= c (cadr s))
					     (arm64-accepts (cadr k) (caddr s)) (arm64-accepts (caddr k) (cadddr s))))
	  (else				1))))

(asm-register-isa 'arm64 arm64-rows arm64-encode arm64-decode arm64-field-range arm64-parse-form
		  arm64-shape arm64-accepts 1)
