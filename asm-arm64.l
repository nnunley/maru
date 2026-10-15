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

;; A row: (mnemonic operands fields mask value), fields as strings of bits or (name . width).
(define arm64-rows
  (map (lambda (row)
	 (let ((fields (map (lambda (f) (if (string? f) f (cons (car f) (arm64-field-width f)))) (caddr row)))
	       (mask 0) (value 0) (n 0))
	   (list-do f fields
	     (if (string? f)
		 (string-do c f (set mask (| (<< mask 1) 1)) (set value (| (<< value 1) (- c ?0))) (set n (+ n 1)))
	       (set mask (<< mask (cdr f))) (set value (<< value (cdr f))) (set n (+ n (cdr f)))))
	   (or (= n 32) (error (car row)" "(cadr row)": "n" bits, not 32"))
	   (list (car row) (cadr row) fields mask value)))
       (parse-string <arm64spec> $file (contents-of-file-named "arm64.spec"))))

;; Registers: (name width number kind), kind sp or zr for number 31.
(define-function arm64-reg-sym (p i)		(string->symbol (concat-string p (long->string i))))
(define arm64-registers ())
(for (i 0 31)
  (set arm64-registers (cons (list (arm64-reg-sym "X" i) 64 i ()) (cons (list (arm64-reg-sym "W" i) 32 i ()) arm64-registers))))
(set arm64-registers (concat-list '((SP 64 31 sp) (XZR 64 31 zr) (WSP 32 31 sp) (WZR 32 31 zr)) arm64-registers))

(define-function arm64-reg-field (r)		(let ((s (symbol->string r))) (string->symbol (concat-string "R" (array->string (arm64-array-from s 1))))))
(define-function arm64-reg-width (r)		(if (= ?X (string-at (symbol->string r) 0)) 64 32))
(define-function arm64-reg-named (width n sp?)
  (car (list-detect e arm64-registers (and (= width (cadr e)) (= n (caddr e))
					 (or (< n 31) (= (cadddr e) (if sp? 'sp 'zr)))))))

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
			  (and r (= (cadr r) (arm64-reg-width (cadr k)))
			       (or (< (caddr r) 31) (= (cadddr r) (if (caddr k) 'sp 'zr)))
			       (cons (cons (arm64-reg-field (cadr k)) (caddr r)) env))))
            ((and (memq c '(imm simm pcrel pcpage)) (arm64-reloc? op))	; a placeholder: zero for now
			(and (not (= 'imm0 (cadr k)))
			     (or (not (cdr op)) (= (cadr op) (arm64-width-of row (cadr k))))
			     (arm64-bind-field row (cadr k) 0 env)))
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

(define-function arm64-operand (row k word pc)
  (let ((c (car k)))
    (cond
      ((= c 'reg)	(arm64-reg-named (arm64-reg-width (cadr k)) (arm64-field-of row word (arm64-reg-field (cadr k))) (caddr k)))
      ((= c 'imm)	(if (= 'imm0 (cadr k)) 0 (* (caddr k) (arm64-field-of row word (cadr k)))))
      ((= c 'simm)	(* (caddr k) (arm64-sext (arm64-field-of row word (cadr k)) (arm64-width-of row (cadr k)))))
      ((= c 'pcrel)	(+ pc (* (caddr k) (arm64-sext (arm64-field-of row word (cadr k)) (arm64-width-of row (cadr k))))))
            ((= c 'pcpage)	(+ (arm64-page pc) (* (caddr k) (arm64-sext (arm64-field-of row word (cadr k)) (arm64-width-of row (cadr k))))))
      ((= c 'lsl)	(list 'LSL (* (caddr k) (arm64-field-of row word (cadr k)))))
      (else		(list c (arm64-operand row (cadr k) word pc) (arm64-operand row (caddr k) word pc))))))

;; The instruction encoded by word at address pc.
(define-function arm64-decode-word (word pc)
  (let ((row (list-detect r arm64-rows (= (cadddr (cdr r)) (& word (cadddr r))))))
    (and row (cons (car row) (map (lambda (k) (arm64-operand row k word pc)) (cadr row))))))

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
(define-function arm64-field-range (row position pc)
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

(asm-register-isa 'arm64 arm64-rows arm64-encode arm64-decode arm64-field-range)
