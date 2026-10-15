;;; Encode and decode A64 by interpreting the Arm ARM encoding diagrams in arm64.spec.
;;; Operands: a register is its name (X0, W3, SP, XZR), an immediate is a number,
;;; a branch target is an address, a shift is (LSL n), memory is (off X1 16),
;;; (pre SP -16) or (post SP 16).  The caller supplies (_B X byte) and (_PC X).

(require "text-parser.l")
(load (concat-string *spike* "/arm64.g.l"))

(define-function array-from (s i)	(let ((a (array))) (for (j i (string-length s)) (array-append a (string-at s j))) a))

(define-function field-width (f)
  (let ((s (symbol->string (car f))))
    (cond ((cdr f)				(cadr f))
	  ((= ?R (string-at s 0))		5)
	  (else					(string->number (array->string (array-from s 3)))))))

;; A row: (mnemonic operands fields mask value), fields as strings of bits or (name . width).
(define a64-rows
  (map (lambda (row)
	 (let ((fields (map (lambda (f) (if (string? f) f (cons (car f) (field-width f)))) (caddr row)))
	       (mask 0) (value 0) (n 0))
	   (list-do f fields
	     (if (string? f)
		 (string-do c f (set mask (| (<< mask 1) 1)) (set value (| (<< value 1) (- c ?0))) (set n (+ n 1)))
	       (set mask (<< mask (cdr f))) (set value (<< value (cdr f))) (set n (+ n (cdr f)))))
	   (or (= n 32) (error (car row)" "(cadr row)": "n" bits, not 32"))
	   (list (car row) (cadr row) fields mask value)))
       (parse-string <a64spec> $file (contents-of-file-named (concat-string *spike* "/arm64.spec")))))

;; Registers: (name width number kind), kind sp or zr for number 31.
(define-function reg-sym (p i)		(string->symbol (concat-string p (long->string i))))
(define a64-registers ())
(for (i 0 31)
  (set a64-registers (cons (list (reg-sym "X" i) 64 i ()) (cons (list (reg-sym "W" i) 32 i ()) a64-registers))))
(set a64-registers (concat-list '((SP 64 31 sp) (XZR 64 31 zr) (WSP 32 31 sp) (WZR 32 31 zr)) a64-registers))

(define-function reg-field (r)		(let ((s (symbol->string r))) (string->symbol (concat-string "R" (array->string (array-from s 1))))))
(define-function reg-width (r)		(if (= ?X (string-at (symbol->string r) 0)) 64 32))
(define-function reg-named (width n sp?)
  (car (list-detect e a64-registers (and (= width (cadr e)) (= n (caddr e))
					 (or (< n 31) (= (cadddr e) (if sp? 'sp 'zr)))))))

(define-function width-of (row name)	(cdr (list-detect f (caddr row) (and (pair? f) (= name (car f))))))

;; The field value for v under operand kind (imm|simm|pcrel f scale), or () if it doesn't fit.
(define-function scaled (row k v)
  (let* ((w (width-of row (cadr k))) (s (caddr k)) (q (and (long? v) (/ v s))))
    (and q (= v (* q s))
	 (if (= 'imm (car k))
	     (and (<= 0 q) (< q (<< 1 w)) q)
	   (and (<= (- (<< 1 (- w 1))) q) (< q (<< 1 (- w 1))) (& q (- (<< 1 w) 1)))))))

;; Bind the fields operand op fills under kind k, onto env; () if it doesn't match.
(define-function bind (row k op env pc)
  (let ((c (car k)))
    (cond
      ((= c 'reg)	(let ((r (assq op a64-registers)))
			  (and r (= (cadr r) (reg-width (cadr k)))
			       (or (< (caddr r) 31) (= (cadddr r) (if (caddr k) 'sp 'zr)))
			       (cons (cons (reg-field (cadr k)) (caddr r)) env))))
      ((memq c '(imm simm))
			(let ((q (scaled row k op))) (and q (cons (cons (cadr k) q) env))))
      ((= c 'pcrel)	(let ((q (and (long? op) (scaled row k (- op pc))))) (and q (cons (cons (cadr k) q) env))))
      ((= c 'lsl)	(and (pair? op) (= 'LSL (car op))
			     (let ((q (scaled (list () () (caddr row)) (list 'imm (cadr k) (caddr k)) (cadr op))))
			       (and q (cons (cons (cadr k) q) env)))))
      (else		(and (pair? op) (= c (car op))
			     (let ((e (bind row (cadr k) (cadr op) env pc)))
			       (and e (bind row (caddr k) (caddr op) e pc))))))))

(define-function encode-row (row ops pc)
  (let ((env ()) (ok 1) (kinds (cadr row)))
    (and (= (list-length kinds) (list-length ops))
	 (let ()
	   (list-do k kinds
	     (and ok (or (set env (bind row k (car ops) env pc)) (set ok ())))
	     (set ops (cdr ops)))
	   (and ok
		(let ((word 0))
		  (list-do f (caddr row)
		    (if (string? f)
			(string-do c f (set word (| (<< word 1) (- c ?0))))
		      (let ((b (assq (car f) env)))
			(or b (error (car row)": field "(car f)" has no operand"))
			(set word (| (<< word (cdr f)) (cdr b))))))
		  word))))))

(define-function a64 (X mnemonic . ops)
  (let ((word ()) (rows a64-rows))
    (while (and rows (not word))
      (and (= mnemonic (caar rows)) (set word (encode-row (car rows) ops (_PC X))))
      (set rows (cdr rows)))
    (or word (error "no encoding for "mnemonic" "ops))
    (for (i 0 4) (_B X (& 255 (>> word (* 8 i)))))))

;;; ---------------------------------------------------------------- decoding

(define-function sext (v n)		(let ((s (- 64 n))) (>> (<< v s) s)))

;; The value of field name in word.
(define-function field-of (row word name)
  (let ((shift 32) (v ()))
    (list-do f (caddr row)
      (let ((w (if (string? f) (string-length f) (cdr f))))
	(set shift (- shift w))
	(and (pair? f) (= name (car f)) (set v (& (>> word shift) (- (<< 1 w) 1))))))
    v))

(define-function operand (row k word pc)
  (let ((c (car k)))
    (cond
      ((= c 'reg)	(reg-named (reg-width (cadr k)) (field-of row word (reg-field (cadr k))) (caddr k)))
      ((= c 'imm)	(if (= 'imm0 (cadr k)) 0 (* (caddr k) (field-of row word (cadr k)))))
      ((= c 'simm)	(* (caddr k) (sext (field-of row word (cadr k)) (width-of row (cadr k)))))
      ((= c 'pcrel)	(+ pc (* (caddr k) (sext (field-of row word (cadr k)) (width-of row (cadr k))))))
      ((= c 'lsl)	(list 'LSL (* (caddr k) (field-of row word (cadr k)))))
      (else		(list c (operand row (cadr k) word pc) (operand row (caddr k) word pc))))))

;; The instruction encoded by word at address pc.
(define-function a64-decode (word pc)
  (let ((row (list-detect r a64-rows (= (cadddr (cdr r)) (& word (cadddr r))))))
    (if row
	(cons (car row) (map (lambda (k) (operand row k word pc)) (cadr row)))
      (list 'WORD word))))
