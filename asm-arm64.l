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

;; A row: (mnemonic operands fields mask value allowed plan), fields as strings
;; of bits or (name . width); allowed is the row's T=... arrangements, or ();
;; plan its compiled diagram, added once the rows are read (arm64-plan).
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

(define-structure <arm64-plan> (names shifts kinds t-slot allowed q size sz infos))	; infos: each kind's info

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

;; What operand kind k needs against slots: (tag info...), names resolved; arm64-binder makes its binder from it.
(define-function arm64-kind-info (slots k)
  (let ((c (car k)))
    (cond ((= c 'reg)		(list 'reg (arm64-slot slots (arm64-reg-field (cadr k))) (arm64-reg-class (cadr k))
				      (if (caddr k) 'sp 'zr)))
	  ((= c 'vreg)		(list 'vreg (arm64-slot slots (arm64-reg-field (cadr k))) (caddr k)))
	  ((= c 'vbrace)	(arm64-kind-info slots (cadr k)))
	  ((= c 'vlane)		(list 'vlane (arm64-slot slots (arm64-reg-field (cadr k))) (string->symbol (caddr k))
				      (arm64-kind-info slots (cadddr k))))
	  ((memq c '(vshl vshr))	(list c (arm64-field-ref slots 'immh:immb)))
	  ((= c 'bimm)		(list 'bimm (cadr k) (arm64-slot slots 'n) (arm64-slot slots 'immr) (arm64-slot slots 'imms)))
	  ((= c 'lslimm)	(list 'lslimm (cadr k) (arm64-slot slots 'immr) (arm64-slot slots 'imms)))
	  ((= c 'fimm)		(list 'fimm (arm64-slot slots 'imm8)))
	  ((memq c '(cond invcond))	(list c (arm64-slot slots 'cond)))
	  ((= c 'mreg)		(list 'mreg (list-length k) (cdddr k)
				      (arm64-kind-info slots (cadr k)) (arm64-kind-info slots (caddr k))))
	  ((and (= c 'imm) (= 'imm0 (cadr k)))	(list 'imm0))
	  ((memq c '(imm simm pcrel pcpage))	(list c (arm64-field-ref slots (cadr k)) (caddr k)))
	  ((= c 'lsl)		(list 'lsl (arm64-field-ref slots (cadr k)) (caddr k)))
	  (else			(list 'tag c (arm64-kind-info slots (cadr k)) (arm64-kind-info slots (caddr k)))))))

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
;; a register's entry by its symbol, through a cache (hash.l): every operand of every instruction asks
(define arm64-register-cache (identity-cache 1024))
(define-function arm64-register-entry (op)	; op a symbol: its entry, or ()
  (or (cache-at arm64-register-cache op)
      (let ((r (hash-at arm64-register-table op))) (and r (cache-at-put arm64-register-cache op r)))))

;; A simple operand kind's value: what its field holds for op, or () if op isn't of the kind.  Its binder puts the
;; value in the row's fields, and its operand rule (arm64-operands.g) answers it: the kind is defined here, once.
(define-function arm64-reg-value (class kind op)	; a register of class, 31 being SP or ZR as kind says: its number
  (let ((r (and (symbol? op) (arm64-register-entry op))))
    (and r (= (cadr r) class) (or (not (cadddr r)) (= (cadddr r) kind)) (caddr r))))
(define-function arm64-cond-value (op) (arm64-cond-code op))
(define-function arm64-invcond-value (op)	; CSET encodes the inverted condition
  (let ((q (arm64-cond-code op))) (and q (< q 14) (if (= 0 (& q 1)) (+ q 1) (- q 1)))))
(define-function arm64-fimm-value (op) (arm64-fp8 op))
;; a number field width bits wide, scaled: imm, simm, pcrel and pcpage take a placeholder ((reloc), or (reloc N) of
;; its width), which is zero for now; lsl reads (LSL n)
(define-function arm64-number-value (c width scale op pc)
  (if (and (memq c '(imm simm pcrel pcpage)) (arm64-reloc? op))
      (and width (or (not (cdr op)) (= (cadr op) width)) 0)
    (let ((v (cond ((= c 'pcrel)	(and (long? op) (- op pc)))
		   ((= c 'pcpage)	(and (long? op) (- op (arm64-page pc))))
		   ((= c 'lsl)		(and (pair? op) (= 'LSL (car op)) (cadr op)))
		   (else		op))))
      (and width v (arm64-scaled (if (memq c '(imm lsl)) 'imm 'simm) width scale v)))))

;; Each operand kind binds through a binder of its own, made once when its row's plan is: a function of
;; (plan op vals pc) that binds op into vals and answers vals, or () if op doesn't fit.  The kind's info (arm64-kind-info)
;; is read when the binder is made, so binding tests nothing about the kind itself.
(define arm64-binder-makers (identity-hash-table))
(define-form define-arm64-binder (tags info . body)	; body: the binder's lambda, made from info
  `(let ((maker (lambda (,info) ,@body)))
     (list-do tag ',tags (hash-at-put arm64-binder-makers tag maker))))
(define-function arm64-binder (info)
  ((or (hash-at arm64-binder-makers (car info)) (error "arm64: no binder for operand kind " info)) info))

(define-arm64-binder (reg) p
  (let ((slot (cadr p)) (class (caddr p)) (kind (cadddr p)))
    (lambda (plan op vals pc) (let ((q (arm64-reg-value class kind op))) (and q (arm64-put vals slot q))))))
(define-arm64-binder (vreg) p
  (let ((slot (cadr p)) (a (caddr p)))
    (lambda (plan op vals pc)
      (and (arm64-vector? op) (long? (caddr op))
	   (let ((arr (arm64-data-arr op)))
	     (and (if (= 'T a) (arm64-bind-arrangement plan arr vals) (= a arr))
		  (arm64-put vals slot (cadr op))))))))
(define-arm64-binder (vlane) p
  (let* ((slot (cadr p)) (name (caddr p)) (lane (cadddr p)) (ref (cadr lane)))
    (lambda (plan op vals pc)
      (and (arm64-vector? op) (symbol? (caddr op)) (= name (caddr op))
	   (let ((q (and ref (arm64-scaled (car lane) (car ref) (caddr lane) (cadddr op)))))
	     (and q (arm64-put-ref ref q (arm64-put vals slot (cadr op)))))))))
(define-arm64-binder (vshl) p
  (let ((ref (cadr p)))
    (lambda (plan op vals pc)
      (let* ((bound (array-at vals (<arm64-plan>-t-slot plan))) (e (and bound (arm64-esize bound))))
	(and e ref (long? op) (<= 0 op) (< op e) (arm64-put-ref ref (+ e op) vals))))))
(define-arm64-binder (vshr) p
  (let ((ref (cadr p)))
    (lambda (plan op vals pc)
      (let* ((bound (array-at vals (<arm64-plan>-t-slot plan))) (e (and bound (arm64-esize bound))))
	(and e ref (long? op) (< 0 op) (<= op e) (arm64-put-ref ref (- (* 2 e) op) vals))))))
(define-arm64-binder (bimm) p
  (let ((width (cadr p)) (n (caddr p)) (immr (cadddr p)) (imms (car (cddddr p))))
    (lambda (plan op vals pc)
      (let ((f (and (long? op) (arm64-bitmask op width))))
	(and f (arm64-put (arm64-put (arm64-put vals n (car f)) immr (cadr f)) imms (caddr f)))))))
(define-arm64-binder (lslimm) p
  (let ((w (cadr p)) (immr (caddr p)) (imms (cadddr p)))
    (lambda (plan op vals pc)
      (and (long? op) (<= 0 op) (< op w)
	   (arm64-put (arm64-put vals immr (& (- w op) (- w 1))) imms (- (- w 1) op))))))
(define-arm64-binder (fimm) p
  (let ((slot (cadr p)))
    (lambda (plan op vals pc) (let ((q (arm64-fimm-value op))) (and q (arm64-put vals slot q))))))
(define-arm64-binder (cond) p
  (let ((slot (cadr p)))
    (lambda (plan op vals pc) (let ((q (arm64-cond-value op))) (and q (arm64-put vals slot q))))))
(define-arm64-binder (invcond) p
  (let ((slot (cadr p)))
    (lambda (plan op vals pc) (let ((q (arm64-invcond-value op))) (and q (arm64-put vals slot q))))))
(define-arm64-binder (mreg) p
  (let ((n (cadr p)) (rest (caddr p)) (first (arm64-binder (cadddr p))) (second (arm64-binder (car (cddddr p)))))
    (lambda (plan op vals pc)
      (and (pair? op) (= 'reg (car op)) (= (list-length op) n) (equal (cdddr op) rest)
	   (first plan (cadr op) vals pc)
	   (second plan (caddr op) vals pc)))))
(define-arm64-binder (imm0) p
  (lambda (plan op vals pc) (and (= op 0) vals)))
;; a number field: its value (arm64-number-value) put in its parts
(define-arm64-binder (imm simm pcrel pcpage lsl) p
  (let* ((c (car p)) (ref (cadr p)) (width (and ref (car ref))) (scale (caddr p)))
    (lambda (plan op vals pc) (let ((q (arm64-number-value c width scale op pc))) (and q (arm64-put-ref ref q vals))))))
(define-arm64-binder (tag) p
  (let ((head (cadr p)) (first (arm64-binder (caddr p))) (second (arm64-binder (cadddr p))))
    (lambda (plan op vals pc)
      (and (pair? op) (= head (car op))
	   (first plan (cadr op) vals pc)
	   (second plan (caddr op) vals pc)))))

(define-function arm64-plan (row)
  (let ((slots ()) (shift 32) (n 0))
    (list-do f (caddr row)
      (let ((w (if (string? f) (string-length f) (cdr f))))
	(set shift (- shift w))
	(when (pair? f)
	  (and (assq (car f) slots) (error (car row)": field "(car f)" twice in its diagram"))
	  (set slots (cons (list (car f) n shift w) slots))
	  (set n (+ n 1)))))
    (let ((names (array n)) (shifts (array n)) (infos (map (lambda (k) (arm64-kind-info slots k)) (cadr row))))
      (list-do s slots (set-array-at names (cadr s) (car s)) (set-array-at shifts (cadr s) (caddr s)))
      (new <arm64-plan> names shifts (map arm64-binder infos) n
	   (arm64-allowed row) (arm64-slot slots 'q) (arm64-slot slots 'size) (arm64-slot slots 'sz) infos))))

(list-do row arm64-rows (set-cdr (cdr (cddddr row)) (list (arm64-plan row))))
(define-function arm64-plan-word (row vals)	; the row's fixed bits, then each field of vals in its place
  (let* ((plan (arm64-row-plan row)) (word (car (cddddr row))) (shifts (<arm64-plan>-shifts plan)))
    (for (i 0 (<arm64-plan>-t-slot plan))
      (let ((v (array-at vals i)))
	(or v (error (car row)": field "(array-at (<arm64-plan>-names plan) i)" has no arm64-operand"))
	(set word (| word (<< v (array-at shifts i))))))
    word))

(define-function arm64-encode-row (row ops pc)
  (let* ((plan (arm64-row-plan row)) (kinds (<arm64-plan>-kinds plan))
	 (vals (array (+ 1 (<arm64-plan>-t-slot plan)))) (ok 1))
    (while (and ok kinds ops)	; each operand by its kind's binder, walking both lists, so neither is measured first
      (or ((car kinds) plan (car ops) vals pc) (set ok ()))
      (set kinds (cdr kinds))
      (set ops (cdr ops)))
    (and ok (not kinds) (not ops) (arm64-plan-word row vals))))

;;; ---------------------------------------------------------------- the encoder grammar
;;; arm64.spec's rows as a tree grammar (gen-arm64-rules.l writes arm64-rules.g): an operand rule for each simple
;;; operand kind, answering its value (above), a rule for each row matching an instruction and answering (row .
;;; word), and for each mnemonic the choice of its rows in file order (asm's first fit), and for a placeholder in an
;;; operand position the rows sorted by that field's size, widest first (asm-best-row's choice for an open one).
(define arm64-row-vector (list->array arm64-rows))	; a row by its index, as the rules name it
(define-function arm64-rule-name (prefix name)	; prefix then name, letters and digits only (a dot spelt dot)
  (let ((out (array)) (s (concat-string prefix (if (symbol? name) (symbol->string name) name))))
    (for (i 0 (string-length s))
      (let ((c (string-at s i)))
	(if (or (and (<= ?A c) (<= c ?Z)) (and (<= ?a c) (<= c ?z)) (and (<= ?0 c) (<= c ?9)))
	    (array-append out c)
	  (string-do d "dot" (array-append out d)))))
    (string->symbol (array->string out))))
(define-function arm64-info-width (info) (let ((ref (cadr info))) (and ref (car ref))))
(define-function arm64-operand-rule (info)	; a simple kind's operand rule: (name expression-of-v), or ()
  (let ((c (car info)))
    (cond ((= c 'reg)		(list (arm64-rule-name "reg" (concat-string (long->string (caddr info)) (symbol->string (cadddr info))))
				      `(arm64-reg-value ,(caddr info) ',(cadddr info) v)))
	  ((memq c '(imm simm pcrel pcpage lsl))
	   (let ((w (arm64-info-width info)))
	     (and w (list (arm64-rule-name (symbol->string c) (concat-string (long->string w) (concat-string "s" (long->string (caddr info)))))
			  `(arm64-number-value ',c ,w ,(caddr info) v self.pc)))))
	  ((= c 'cond)		(list 'cond '(arm64-cond-value v)))
	  ((= c 'invcond)	(list 'invcond '(arm64-invcond-value v)))
	  ((= c 'fimm)		(list 'fimm '(arm64-fimm-value v))))))
;; a kind with no value of its own (vectors, bitmasks, vector shifts) still shows in a row's pattern, by an opaque rule
;; testing only the operand's shape; the row then encodes through its encoder (arm64-escape-result)
(define-function arm64-opaque-value (tag v)
  (if (memq tag '(vreg vlane)) (and (arm64-vector? v) v) (and (long? v) v)))
(define-function arm64-opaque-rule (info)	; (name expression-of-v)
  (list (arm64-rule-name "opaque" (symbol->string (car info))) `(arm64-opaque-value ',(car info) v)))
(define-function arm64-put-leaves (info leaves vals)	; a matched operand's values into vals: the leaves left
  (let ((c (car info)))
    (cond ((memq c '(reg cond invcond fimm))		(arm64-put vals (cadr info) (car leaves)) (cdr leaves))
	  ((memq c '(imm simm pcrel pcpage lsl))	(arm64-put-ref (cadr info) (car leaves) vals) (cdr leaves))
	  ((= c 'imm0)					leaves)
	  ((= c 'tag)	(arm64-put-leaves (cadddr info) (arm64-put-leaves (caddr info) leaves vals) vals))
	  ((= c 'mreg)	(arm64-put-leaves (car (cddddr info)) (arm64-put-leaves (cadddr info) leaves vals) vals))
	  (else		(error "arm64: no leaves for " info)))))
(define-function arm64-row-result (k leaves)	; row k's (row . word) from its operands' values, as its rule matched them
  (let* ((row (array-at arm64-row-vector k)) (vals (array (+ 1 (<arm64-plan>-t-slot (arm64-row-plan row))))))
    (list-do info (<arm64-plan>-infos (arm64-row-plan row)) (set leaves (arm64-put-leaves info leaves vals)))
    (cons row (arm64-plan-word row vals))))
(define-function arm64-escape-result (k insn pc)	; a row whose kinds have no operand rules: its encoder, on the whole insn
  (let* ((row (array-at arm64-row-vector k)) (w (and (pair? insn) (= (car insn) (car row)) (arm64-encode-row row (cdr insn) pc))))
    (and w (cons row w))))

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

;; A number standing for op's shape (asm-table.l's key): 1 to 3 a number, a symbol, a vector; 4 on a register's, one for
;; each of its shapes; a memory operand's from its mode, base and offset; a pair as (LSL 12) by its head, each head its
;; own from 1024 on first sight; () for a memory operand whose parts aren't keyed below 16, which takes the chain.
(define arm64-register-keys (identity-hash-table))
(define arm64-pair-keys (identity-hash-table))
(let ((by-shape (identity-hash-table)))
  (list-do r arm64-registers
    (let ((s (hash-at arm64-register-shapes (car r))))
      (hash-at-put arm64-register-keys (car r)
		   (or (hash-at by-shape s) (hash-at-put by-shape s (+ 4 (hash-count by-shape))))))))
(define arm64-shape-key)
(define-function arm64-mode-index (mode)	(if (= 'off mode) 0 (if (= 'pre mode) 1 2)))
(define-function arm64-memory-key (op)	; (off|pre|post base offset)
  (let ((b (arm64-shape-key (cadr op))) (o (arm64-shape-key (caddr op))))
    (and b o (< b 16) (< o 16) (pair? (cddr op)) (not (cdddr op))
	 (+ (+ 16 (* 256 (arm64-mode-index (car op)))) (+ (* 16 b) o)))))
(define-function arm64-pair-key (op)
  (or (hash-at arm64-pair-keys (car op))
      (hash-at-put arm64-pair-keys (car op) (+ 1024 (hash-count arm64-pair-keys)))))
(define arm64-symbol-keys (identity-cache 1024))	; a symbol's shape key, through a cache (hash.l)
(define-function arm64-shape-key (op)
  (cond ((or (long? op) (double? op) (arm64-reloc? op))	1)
	((symbol? op)				(or (cache-at arm64-symbol-keys op)
						    (cache-at-put arm64-symbol-keys op (or (hash-at arm64-register-keys op) 2))))
	((arm64-vector? op)			3)
	((memq (car op) '(off pre post))	(arm64-memory-key op))
	(else					(arm64-pair-key op))))

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
		  arm64-shape arm64-accepts 1 arm64-shape-key)

;;; ---------------------------------------------------------------- sites

;; A lowering site: an instruction a lowering rule always means, its row chosen when the rule loads rather than found
;; again for every instruction (the kernel plan's Task 7; oecm's staged evaluation).  Rules write them as arm64-sites
;; templates (below); inside, a site's specs are each a literal operand (a symbol, a number or a quoted list) or (KIND
;; EXPR), KIND one of x (an X register), w (a W register), r (either), n (a number), f (an FP register, (f d EXPR) or
;; (f s EXPR) of one width), mem with its shape ((mem (off SP 0) EXPR)) or without, lsl (an (LSL n) operand) or c (a
;; condition).  When the rule loads, the specialiser (below) reduces the encoder grammar's rows for the mnemonic to the
;; ones that can take the template; at run time the site answers (data b0 b1 b2 b3) from the first of them that takes
;; the operands, as asm would choose it, or the symbolic form, for asm to encode or refuse, when an operand isn't of
;; the declared kind or no row takes it.  A site with nothing variable is encoded once, as it loads.  *arm64-sites* ()
;; makes every site its symbolic form.
(or (defined? '*arm64-sites*) (define *arm64-sites* 1))

(define-function arm64-site-variable? (spec) (and (pair? spec) (memq (car spec) '(x w r n f mem lsl c))))
(define-function arm64-site-literal (spec) (if (and (pair? spec) (= 'quote (car spec))) (cadr spec) spec))
(define-function arm64-site-expr (spec)	; (x e), (f d e), (mem shape e): the operand's expression, last
  (while (cdr spec) (set spec (cdr spec)))
  (car spec))

(define-function arm64-site-word-bytes (word)
  (list 'data (& 255 word) (& 255 (>> word 8)) (& 255 (>> word 16)) (& 255 (>> word 24))))

;;; The specialiser: a site's template composed with the encoder grammar's definitions as the rule loads (the design
;;; doc/plans/2026-11-21-encoder-tree-grammar-design.md).  Each hole's guard runs once; a row is kept if every
;;; operand's kind takes the hole's (a register of its class, a number, a condition, a memory operand of its mode) or
;;; the literal, which is folded into the row's constant; what is left of a kept row is its kinds' tests and one OR of
;;; shifted fields.  The rows are the mnemonic's in file order, so the first that fits is asm's.  A row whose kinds it
;;; can't reason about (vectors, bitmasks) is kept as a call of that row's encoder (arm64-escape-code).
(or (defined? '*arm64-sites-recorder*) (define *arm64-sites-recorder* ()))	; (f mnemonic specs kept-rows escaped label), for a check
(define-function arm64-hole-classes (spec)	; a register hole's classes (the letters' codes), or ()
  (let ((k (car spec)))
    (cond ((= k 'x) '(88)) ((= k 'w) '(87)) ((= k 'r) '(88 87))
	  ((= k 'f) (cond ((not (cddr spec)) '(68 83)) ((= 'd (cadr spec)) '(68)) (else '(83)))))))
;; a union (r: X or W; f with no width: D or S) is guarded only as a symbol: each row tests it by its own operand rule,
;; so the row of the register's width is the one that takes it
(define-function arm64-hole-tested? (spec) (or (= 'r (car spec)) (and (= 'f (car spec)) (not (cddr spec)))))
(define-function arm64-mem-guard (spec e)
  (let ((shape (cadr spec)))
    `(and (pair? ,e) (= ',(car shape) (car ,e)) (pair? (cdr ,e)) (pair? (cddr ,e)) (not (cdddr ,e)) (long? (caddr ,e))
	  ,(if (= 'SP (cadr shape)) `(= 'SP (cadr ,e)) `(arm64-reg-value 88 'plain (cadr ,e)))
	  ,e)))
(define-function arm64-hole-guard (spec e)	; code answering the hole's value from e, or () where it isn't of its kind
  (let ((k (car spec)) (classes (arm64-hole-classes spec)))
    (cond ((arm64-hole-tested? spec)	`(and (symbol? ,e) ,e))
	  (classes	`(arm64-reg-value ,(car classes) 'plain ,e))	; X0-X30 and the like, not SP or ZR, as the site's shape key
	  ((= k 'n)	`(and (long? ,e) ,e))
	  ((= k 'c)	`(and (symbol? ,e) ,e))
	  ((= k 'lsl)	`(and (pair? ,e) (= 'LSL (car ,e)) ,e))
	  ((= k 'mem)
	   (arm64-mem-guard spec e)))))
(define-function arm64-mem-hole-forms (spec code)	; a memory hole's (mode base offset), base and offset as forms
  (let ((shape (cadr spec)))
    (list (car shape)
	  (if (= 'SP (cadr shape)) '(lit SP) (list 'hole '(x) `(arm64-reg-value 88 'plain (cadr ,code))))
	  (list 'hole '(n) `(caddr ,code)))))
(define-function arm64-join-leaves (a b)	; two reductions in order: drop or fallback if either is
  (cond ((= a 'fallback) a) ((= b 'fallback) b) ((= a 'drop) a) ((= b 'drop) b) (else (concat-list a b))))
;; An operand's reduction for a row's kind info: a list of entries, (const v), (value code), (test code) or (check
;; code), in leaf order; or drop (the row can't take it), or fallback (beyond the specialiser).  form is (lit L), or
;; (hole SPEC code), code the hole's guarded value.
;; The encoder grammar's rules as data (arm64-rules-data.l: arm64-rules.g parsed by grammar-data.l, at make), loaded
;; the first time a site is specialised, so no parser loads with native.l; a rule found by name
(define arm64-rule-defs ())
(define arm64-rule-index ())
(define-function arm64-rule (name)	; the rule's pattern, as tpeg parsed it
  (or arm64-rule-index
      (let ((t (identity-hash-table)))
	(load "arm64-rules-data.l")
	(list-do r arm64-rule-defs (hash-at-put t (car r) (cadr r)))
	(set arm64-rule-index t)))
  (hash-at arm64-rule-index name))
(define-function arm64-mnemonic-rules (mnemonic)	; its rows' rules, in its rule's order (the first that fits is asm's)
  (let ((pe (arm64-rule (arm64-rule-name "mn" mnemonic))))
    (cond ((not pe)			())
	  ((= 'match-first (car pe))	(map (lambda (alt) (arm64-rule (cadr alt))) (cdr pe)))
	  (else				(list (arm64-rule (cadr pe)))))))
(define-function arm64-last (l) (while (cdr l) (set l (cdr l))) (car l))
(define-function arm64-row-rule-parts (pe)	; (k escape items): the row the action names, whether it encodes through its
  (let* ((first (cadr pe))					; encoder, and the list pattern's operand items
	 (lst (if (= 'assign-result (car first)) (caddr first) first))
	 (inner (cadr lst))
	 (action (cadr (arm64-last pe)))
	 (items (if (= 'match-all (car inner)) (cddr inner) ()))
	 (mnemonic (cadr (if (= 'match-all (car inner)) (cadr inner) inner)))
	 (row (and (long? (cadr action)) (<= 0 (cadr action)) (< (cadr action) (array-length arm64-row-vector)) (array-at arm64-row-vector (cadr action)))))
    ;; the rules name rows by index into arm64.spec's: one that doesn't fit its row is data older than the spec
    (or (and row (= mnemonic (car row)) (= (list-length items) (list-length (cadr row))))
	(error "arm64-rules-data.l doesn't fit arm64.spec (make arm64-rules-data.l): row " (cadr action) " for " mnemonic))
    (list (cadr action) (= 'arm64-escape-result (car action)) items)))
(define-function arm64-operand-expr (name)	; an operand rule's value expression, of v: its &-> test
  (let ((pe (arm64-rule name))) (cadr (caddr pe))))
(define-function arm64-subst (x code)	; x with v the operand's code and self.pc 0, as a site encodes at 0
  (cond ((= x 'v)	code)
	((= x 'self.pc)	0)
	((pair? x)	(cons (arm64-subst (car x) code) (arm64-subst (cdr x) code)))
	(else		x)))
(define-function arm64-const-leaf (v) (if v (list (list 'const v)) 'drop))

;; an operand's leaves, read from the rule that matches it: its value expression, by its head, says what kind it takes;
;; a literal is evaluated now, a hole is tested as the residual runs.  form is (lit L) or (hole SPEC code).
(define arm64-expr-leaf-table (identity-hash-table))
(define-function arm64-rule-leaves (name form)
  (let* ((e (arm64-operand-expr name)) (f (hash-at arm64-expr-leaf-table (car e))))
    (cond ((not f)		'fallback)
	  ((= 'lit (car form))	(f e (car (cdr form)) () ()))
	  (else			(f e () (cadr form) (caddr form))))))
(define-form define-arm64-expr-leaves (heads params . body)	; params: (e literal spec code), literal () for a hole
  `(let ((f (lambda ,params ,@body))) (list-do h ',heads (hash-at-put arm64-expr-leaf-table h f))))
(define-function arm64-literal-value (e l) (eval (arm64-subst e (list 'quote l))))
(define-function arm64-test-leaf (e code) (list (list 'test (arm64-subst e code))))
(define-arm64-expr-leaves (arm64-reg-value) (e l spec code)
  (cond ((not spec)					(arm64-const-leaf (arm64-literal-value e l)))
	((not (memq (cadr e) (arm64-hole-classes spec)))	'drop)
	((arm64-hole-tested? spec)				(arm64-test-leaf e code))	; the row's own test
	(else							(list (list 'value code)))))	; the hole's guard proved it
(define-arm64-expr-leaves (arm64-number-value) (e l spec code)
  (let ((c (cadr (cadr e))))
    (cond ((and (memq c '(pcrel pcpage)) (if spec (= 'n (car spec)) (long? l)))	; a site encodes as it loads, not at its address
	   (error "arm64-sites: a number where a row takes a PC-relative offset (name the target with (label ,l)): " e))
	  ((not spec)					(arm64-const-leaf (arm64-literal-value e l)))
	  ((and (memq c '(imm simm)) (= 'n (car spec)))	(arm64-test-leaf e code))
	  ((and (= c 'lsl) (= 'lsl (car spec)))		(arm64-test-leaf e code))
	  (else						'drop))))
(define-arm64-expr-leaves (arm64-cond-value arm64-invcond-value) (e l spec code)
  (cond ((not spec) (arm64-const-leaf (arm64-literal-value e l))) ((= 'c (car spec)) (arm64-test-leaf e code)) (else 'drop)))
(define-arm64-expr-leaves (arm64-fimm-value) (e l spec code)
  (if spec 'drop (arm64-const-leaf (arm64-literal-value e l))))
(define-arm64-expr-leaves (=) (e l spec code)	; imm0: the operand is 0, and fills no field
  (cond ((not spec) (if (= l 0) () 'drop)) ((= 'n (car spec)) (list (list 'check (arm64-subst e code)))) (else 'drop)))
(define-arm64-expr-leaves (arm64-opaque-value) (e l spec code)	; a kind with no value: its row's encoder decides
  (cond ((not spec) 'fallback)
	((and (= 'n (car spec)) (memq (cadr (cadr e)) '(bimm lslimm vshl vshr))) 'fallback)
	(else 'drop)))

;; a pattern item's leaves: an operand rule, bound or not; a nested list (a memory operand, a register offset); a literal
(define arm64-item-leaf-table (identity-hash-table))
(define-function arm64-item-leaves (item form) ((hash-at arm64-item-leaf-table (car item)) item form))
(define-form define-arm64-item-leaves (head params . body)
  `(hash-at-put arm64-item-leaf-table ',head (lambda ,params ,@body)))
(define-arm64-item-leaves assign-result (item form)	(arm64-rule-leaves (cadr (caddr item)) form))
(define-arm64-item-leaves match-rule (item form)	(arm64-rule-leaves (cadr item) form))
(define-arm64-item-leaves match-object (item form)
  (if (and (= 'lit (car form)) (equal (cadr form) (cadr item))) () 'drop))
(define-function arm64-items-leaves (items forms)	; items against forms, in order
  (let ((leaves ()))
    (if (= (list-length items) (list-length forms))
	(let () (map (lambda (i f) (set leaves (arm64-join-leaves leaves (arm64-item-leaves i f)))) items forms) leaves)
      'drop)))
(define-arm64-item-leaves match-list (item form)	; `( 'head item … ): a literal list, or a memory hole of that mode
  (let* ((inner (cadr item)) (head (cadr (cadr inner))) (items (cddr inner)))
    (if (= 'lit (car form))
	(let ((l (cadr form)))
	  (if (and (pair? l) (= head (car l))) (arm64-items-leaves items (map (lambda (x) (list 'lit x)) (cdr l))) 'drop))
      (let* ((spec (cadr form)) (parts (and (= 'mem (car spec)) (arm64-mem-hole-forms spec (caddr form)))))
	(if (and parts (= head (car parts)) (= 2 (list-length items)))
	    (arm64-items-leaves items (cdr parts))
	  'drop)))))
(define-function arm64-place-leaves (info leaves vals place-fn check-fn)	; info's leaves to their fields: those left
  (let ((c (car info)))
    (cond ((memq c '(reg cond invcond fimm))		(place-fn (cadr info) (car leaves)) (cdr leaves))
	  ((memq c '(imm simm pcrel pcpage lsl))	(place-fn (cadr info) (car leaves)) (cdr leaves))
	  ((= c 'imm0)	(if (and leaves (= 'check (car (car leaves)))) (let () (check-fn (cadr (car leaves))) (cdr leaves)) leaves))
	  ((= c 'tag)	(arm64-place-leaves (cadddr info) (arm64-place-leaves (caddr info) leaves vals place-fn check-fn) vals place-fn check-fn))
	  ((= c 'mreg)	(arm64-place-leaves (car (cddddr info)) (arm64-place-leaves (cadddr info) leaves vals place-fn check-fn) vals place-fn check-fn))
	  (else		(error "arm64: no placing for " info)))))
;; a kept row's code: its tests, then its word, the literal fields folded into the constant; or fallback
(define-function arm64-row-code (row leaves finish)	; finish: the word's code to what the site answers
  (let* ((plan (arm64-row-plan row)) (vals (array (+ 1 (<arm64-plan>-t-slot plan)))) (shifts (<arm64-plan>-shifts plan))
	 (terms ()) (binds ()) (checks ()) (n 0) (ok 1))
    (list-do info (<arm64-plan>-infos plan)
      (set leaves (arm64-place-leaves info leaves vals
		    (lambda (place entry)	; place: a slot, or a field reference; entry: a leaf
		      (let* ((kind (car entry))
			     (x (cond ((= kind 'const) (cadr entry))
				      ((= kind 'value) (cadr entry))
				      (else (let ((t (concat-symbol '_t (concat-symbol (string->symbol (long->string n)) '_))))
					      (set n (+ n 1)) (push binds (list t (cadr entry))) (push checks t) t)))))
			(if (= kind 'const)
			    (if (pair? place) (arm64-put-ref place x vals) (arm64-put vals place x))
			  (if (pair? place)
			      (let ((off 0))
				(list-do part (cdr place)
				  (set-array-at vals (car part) 0)
				  (push terms `(<< (& (>> ,x ,off) ,(- (<< 1 (cdr part)) 1)) ,(array-at shifts (car part))))
				  (set off (+ off (cdr part)))))
			    (let () (set-array-at vals place 0) (push terms `(<< ,x ,(array-at shifts place))))))))
		    (lambda (code) (push checks code)))))
    (for (i 0 (<arm64-plan>-t-slot plan)) (or (array-at vals i) (set ok ())))	; a field no operand fills
    (and ok
	 (let ((word (arm64-plan-word row vals)))
	   (list-do x terms (set word `(| ,word ,x)))
	   `(let ,(list-reverse! binds) (and ,@(list-reverse! checks) ,(finish word)))))))
(define-function arm64-rule-alternatives (pe)	; a choice rule's rows' rules, in its order
  (cond ((not pe)			())
	((= 'match-first (car pe))	(map (lambda (alt) (arm64-rule (cadr alt))) (cdr pe)))
	(else				(list (arm64-rule (cadr pe))))))
(define-function arm64-open-rules (mnemonic position)	; the rows giving position a field, widest first: asm-best-row's
  (arm64-rule-alternatives (arm64-rule (arm64-rule-name "open" (concat-string (symbol->string mnemonic) (long->string position))))))
;; A row the specialiser can't reduce (an escape row, whose kinds have no value, or a kind beyond it) is kept in its
;; place as a call of that row's encoder on the operands: the row is still fixed as the template loads, and the first
;; row that takes the operands is still asm's.  finish: the word's code to what the site answers.
(define-function arm64-escape-code (row es finish)
  `(let ((_w_ (arm64-encode-row ',row (list ,@es) 0))) (and _w_ ,(finish '_w_))))
;; A site's residual code.  label, for a label site, is (position code): the template has (reloc) at position, the rows
;; are the open rule's for it, and each answers (label-data BYTES POSITION ROW INSN L), the bytes with the field zero
;; and the report asm would give, which native-assemble places and patches.
(define-function arm64-specialise (mnemonic specs . label)
  (let* ((n -1)
	 (label (car label))
	 (es (map (lambda (s) (set n (+ n 1)) (concat-symbol '_e (concat-symbol (string->symbol (long->string n)) '_))) specs))
	 (forms (map (lambda (s e) (if (arm64-site-variable? s) (list 'hole s (concat-symbol e 'h)) (list 'lit (arm64-site-literal s)))) specs es))
	 (symbolic (if label
		       (let ((i -1)) (map (lambda (e) (set i (+ i 1)) (if (= i (car label)) '(list 'label _label_) e)) es))
		     es))
	 (guards ()) (rows ()) (escaped 0))
    (map (lambda (s e) (and (arm64-site-variable? s) (push guards (list (concat-symbol e 'h) (arm64-hole-guard s e))))) specs es)
    (list-do rule (if label (arm64-open-rules mnemonic (car label)) (arm64-mnemonic-rules mnemonic))	; the grammar's rows, in order
      (let* ((parts (arm64-row-rule-parts rule)) (row (array-at arm64-row-vector (car parts)))
	     (leaves (arm64-items-leaves (caddr parts) forms))
	     (finish (if label
			 (lambda (w) `(list 'label-data (cdr (arm64-site-word-bytes ,w)) ,(car label) ',row (list ',mnemonic ,@es) _label_))
		       (lambda (w) `(arm64-site-word-bytes ,w))))
	     (code (and (not (memq leaves '(drop fallback))) (not (cadr parts)) (arm64-row-code row leaves finish))))
	(cond ((= leaves 'drop))
	      (code	(push rows (cons row code)))
	      (else	(set escaped (+ escaped 1)) (push rows (cons row (arm64-escape-code row es finish)))))))
    (set rows (list-reverse! rows))
    (set guards (list-reverse! guards))
    (and *arm64-sites-recorder* (*arm64-sites-recorder* mnemonic specs (map car rows) escaped (and label (car label))))
    `(let (,@(map (lambda (s e) (list e (if (arm64-site-variable? s) (arm64-site-expr s) `',(arm64-site-literal s)))) specs es)
	   ,@(if label `((_label_ ,(cadr label))) ()))
       (let ,guards
	 (or (and ,@(map car guards) (or ,@(map cdr rows)))
	     (list ',mnemonic ,@symbolic))))))

(define-function arm64-place-spec (specs) (list-detect s specs (and (pair? s) (= 'mem (car s)) (not (cddr s)))))
;; (mem ,place): specialised twice, on SP (a literal, folded into the rows' constants) and on an X register (its guard
;; proving it once), and chosen by the base as it runs, sooner than testing the base in every row; site-code is
;; arm64-site-code, for each
(define-function arm64-place-code (mnemonic specs site-code)
  (let* ((place (arm64-place-spec specs))
	 (with (lambda (shape) (site-code mnemonic (map (lambda (s) (if (= s place) (list 'mem shape '_p_) s)) specs)))))
    `(let ((_p_ ,(cadr place))) (if (and (pair? _p_) (= 'SP (cadr _p_))) ,(with '(off SP 0)) ,(with '(off X0 0))))))
(define-function arm64-site-code (mnemonic specs)	; the code a site expands to
  (let ((symbolic `(list ',mnemonic ,@(map (lambda (s) (if (arm64-site-variable? s) (arm64-site-expr s) `',(arm64-site-literal s))) specs))))
    (cond ((not *arm64-sites*)	symbolic)
	  ((not (list-detect s specs (arm64-site-variable? s)))
	   (let* ((b (asm-buffer 0)) (r (asm-attempt 'arm64 b (cons mnemonic (map arm64-site-literal specs)))))
	     (and (pair? r) (= 'error (car r)) (apply error (cdr r)))
	     (list 'quote (cons 'data (array->list (asm-buffer-bytes b))))))
	  ((arm64-place-spec specs)	(arm64-place-code mnemonic specs arm64-site-code))
	  (else				(arm64-specialise mnemonic specs)))))

;; A label site: an instruction with a (label ,l) operand in an arm64-sites template, one (label EXPR) spec naming
;; L.  The template is specialised with (reloc) in L's place over the rows that give it a field (arm64-specialise's
;; label); an instruction no row takes stays the symbolic form, for asm to refuse with its message.
(define-function arm64-label-site-code (mnemonic specs label)	; label: the (label EXPR) spec, its place in specs
  (let ((specs (map (lambda (s) (if (= s label) ''(reloc) s)) specs)))
    (if *arm64-sites*
	(let ((i -1) (at ())) (list-do s specs (set i (+ i 1)) (and (equal s ''(reloc)) (set at i)))
	  (arm64-specialise mnemonic specs (list at (cadr label))))
      `(list ',mnemonic ,@(map (lambda (s) (cond ((equal s ''(reloc))		`(list 'label ,(cadr label)))
						 ((arm64-site-variable? s)	(arm64-site-expr s))
						 (else				`',(arm64-site-literal s))))
			       specs)))))

;; (arm64-sites `((MNEMONIC OPERAND …) …)): the forms of the instructions a rule always means, each a site, as a list.
;; An operand that varies is a kind around an unquote: (x ,r) (w ,r) (n ,v) (lsl ,v) (c ,cond) (f d ,r) (f s ,r)
;; (mem SHAPE ,place) (label ,l).  Two are unions: (r ,a) an X or W register, (f ,a) a D or S one, each row testing the
;; register by its own rule, so one template serves both widths; and (mem ,place) without a shape is any (off BASE N),
;; its base SP or an X register, specialised for each and chosen by the base (arm64-site-code).  Anything else is literal: SP, 16, (post SP 16), (LSL 0).  An instruction with a
;; (label ,l) is a label site.
(define-function arm64-unquoted (x) (and (pair? x) (= 'unquote (car x)) (cadr x)))	; e of ,e, or ()
(define-function last-pair-of (l) (while (cdr l) (set l (cdr l))) l)
(define-function arm64-template-spec (op)	; a template operand as a site's spec: (KIND … EXPR), or the literal
  (let ((last (and (pair? op) (let ((l op)) (while (cdr l) (set l (cdr l))) (car l)))))
    (cond ((arm64-unquoted op)	(error "arm64-sites: an operand that varies needs a kind: " op))
	  ((and (pair? op) (memq (car op) '(x w r n lsl c f mem label)) (arm64-unquoted last))
	   (let ((spec (map (lambda (x) x) op)))
	     (set-car (last-pair-of spec) (arm64-unquoted last))
	     spec))
	  ((pair? op)		(list 'quote op))
	  (else			op))))
(define-function arm64-insn-site-code (insn)
  (let* ((specs (map arm64-template-spec (cdr insn)))
	 (label (list-detect s specs (and (pair? s) (= 'label (car s))))))
    (if label (arm64-label-site-code (car insn) specs label) (arm64-site-code (car insn) specs))))
(define-function arm64-insn-code (insn)	; one instruction's code: its site or label site
  (if (= 'at (car insn))
      `(list 'at ,(or (arm64-unquoted (cadr insn)) `',(cadr insn)))	; (at ,l) marks where label l is
    (arm64-insn-site-code insn)))
(define-form arm64-sites (template)
  (or (and (pair? template) (= 'quasiquote (car template))) (error "arm64-sites: a quasiquoted list of instructions: " template))
  `(list ,@(map arm64-insn-code (cadr template))))
