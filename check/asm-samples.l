;;; Sample operands for every row, and clang's syntax for them; shared by
;;; check/asm-rows.l and check/asm-patch.l.

(define-function product (ls)
  (if ls
      (let ((out ()))
	(list-do x (car ls) (list-do rest (product (cdr ls)) (set out (cons (cons x rest) out))))
	out)
    (list ())))

(define-function reg-sym (p i)	(string->symbol (concat-string p (long->string i))))



;; The arrangement vector samples use: set per variant by the row check, else
;; the row's first allowed arrangement.
(define arm64-sample-arrangement ())
(define-function arm64-variants (row)
  (if (list-detect k (cadr row) (or (and (= 'vreg (car k)) (= 'T (caddr k)))
				    (and (= 'vbrace (car k)) (= 'T (caddr (cadr k))))))
      (arm64-allowed row)
    '(())))
(define-function arm64-set-variant (arr)	(set arm64-sample-arrangement arr))

;; Sample operands for kind k of row, using register number pos where a register goes.
(define-function arm64-samples (row k pos)
  (let ((c (car k)))
    (cond
            ((= c 'reg)	(let* ((class (string-at (symbol->string (cadr k)) 0))
			       (letter (character->string class)))
			  (list (reg-sym letter pos)
				(cond ((= class ?X)	(if (caddr k) 'SP 'XZR))
				      ((= class ?W)	(if (caddr k) 'WSP 'WZR))
				      (else		(reg-sym letter 31))))))
            ((= c 'vreg)	(let ((arr (if (= 'T (caddr k)) (or arm64-sample-arrangement (car (arm64-allowed row))) (caddr k))))
			  			  (list (arm64-arr-data pos arr) (arm64-arr-data 31 arr))))
      ((= c 'vbrace)	(arm64-samples row (cadr k) pos))
      ((= c 'vlane)	(let ((w (arm64-width-of row (cadr (cadddr k)))) (t (string->symbol (caddr k))))
			  (list (list 'V pos t 0) (list 'V 31 t (- (<< 1 w) 1)))))
      ((memq c '(vshl vshr))
			(let ((e (arm64-esize (or arm64-sample-arrangement (car (arm64-allowed row))))))
			  (if (= c 'vshl) (list 0 (- e 1)) (list 1 e))))
      ((= c 'bimm)	(if (= 64 (cadr k)) '(0x5555555555555555 0xff -2 0x0ff00ff00ff00ff0) '(0x55555555 0xff00ff00 0x7ffffffe)))
      ((= c 'lslimm)	(list 1 (- (cadr k) 1)))
      ((= c 'fimm)	'(1.0 -2.5 0.125 31.0))
      ((memq c '(cond invcond)) '(EQ LT HI))
      ((= c 'mreg)	(map (lambda (i) (concat-list (list 'reg 'X9 i) (cdddr k))) (arm64-samples row (caddr k) pos)))
      ((= c 'imm)	(if (= 'imm0 (cadr k)) '(0)
			  (map (lambda (q) (* q (caddr k))) (list 7 (- (<< 1 (arm64-width-of row (cadr k))) 1)))))
      ((= c 'simm)	(let ((w (arm64-width-of row (cadr k))))
			  (map (lambda (q) (* q (caddr k))) (list -2 (- (<< 1 (- w 1)) 1) (- (<< 1 (- w 1)))))))
      ((= c 'pcpage)	(map (lambda (d) (list 'page d)) (list 4096 -8192 (* 4096 (- (<< 1 (- (arm64-width-of row (cadr k)) 1)) 1)))))
      ((= c 'pcrel)	(map (lambda (d) (list 'rel d)) (list 8 -8 (* (caddr k) (- (<< 1 (- (arm64-width-of row (cadr k)) 1)) 1)))))
      ((= c 'lsl)	(list '(LSL 0) (list 'LSL (* (caddr k) (- (<< 1 (arm64-width-of row (cadr k))) 1)))))
      (else		(let ((out ()))
			  (list-do b (arm64-samples row (cadr k) 9)
			    (list-do i (arm64-samples row (caddr k) 0) (set out (cons (list c b i) out))))
			  out)))))

;; clang's syntax for one operand; label is this instruction's label number.
(define-function arm64-text (op label . kind)
  (cond
    ((and kind (pair? (car kind)) (= 'vbrace (caar kind)))	(concat-strings "{" (arm64-text op label) "}"))
        ((and (pair? op) (= 'V (car op)) (long? (caddr op)))
     (concat-strings "V" (long->string (cadr op)) "." (symbol->string (arm64-data-arr op))))
    ((and (pair? op) (= 'V (car op)))
     (concat-strings "V" (long->string (cadr op)) "." (symbol->string (caddr op)) "[" (long->string (cadddr op)) "]"))
    ((and (pair? op) (= 'off (car op)) (= 0 (caddr op)))	(concat-strings "[" (arm64-text (cadr op) label) "]"))
        ((symbol? op)		(symbol->string op))
    ((double? op)		(concat-string "#" (double->string op)))
    ((and (long? op) (or (< op -65536) (< 65536 op)))	(format "#0x%lx" op))
    ((long? op)			(concat-string "#" (long->string op)))
    ((= 'reg (car op))		(concat-strings "[" (arm64-text (cadr op) label) ", " (arm64-text (caddr op) label)
					(if (cdddr op) (concat-strings ", " (symbol->string (cadddr op)) " #" (long->string (car (cddddr op)))) "")
					"]"))
    ((= 'LSL (car op))		(concat-string "LSL #" (long->string (cadr op))))
    ((= 'page (car op))		(concat-string "#" (long->string (cadr op))))
    ((= 'rel (car op))		(concat-strings "L" (long->string label) (if (< (cadr op) 0) " - " " + ")
					(long->string (if (< (cadr op) 0) (- 0 (cadr op)) (cadr op)))))
    ((= 'off (car op))		(concat-strings "[" (arm64-text (cadr op) label) ", " (arm64-text (caddr op) label) "]"))
    ((= 'pre (car op))		(concat-strings "[" (arm64-text (cadr op) label) ", " (arm64-text (caddr op) label) "]!"))
    ((= 'post (car op))		(concat-strings "[" (arm64-text (cadr op) label) "], " (arm64-text (caddr op) label)))))


;;; ---------------------------------------------------------------- x86 and x64

(define x86-sample-mode 'x64)
(define-function x86-variants (row)		'(()))
(define-function x86-set-variant (v)		())

(define-function x86-sample-reg (kind size n)	(x86-reg-named kind size n (= x86-sample-mode 'x86) x86-sample-mode))	; byte 4-7: AH..BH in 32-bit mode, SPL..DIL in 64

;; Memory samples of tag at register position pos: base only, base + scaled
;; index + negative displacement, an absolute address, and (x64) RIP-relative.
(define-function x86-memories (tag pos)
  (let ((asize (if (= x86-sample-mode 'x64) 8 4))
	(bases (if (= x86-sample-mode 'x64) '(3 13 4 12 5) '(3 5 4 6 7))))
    (let ((b (x86-sample-reg 'r asize (x86-nth bases (% pos 5))))
	  (b2 (x86-sample-reg 'r asize (x86-nth bases (% (+ pos 1) 5))))
	  (i (x86-sample-reg 'r asize (if (= x86-sample-mode 'x64) 9 6))))
      (concat-list (list (list tag 0 b () 1) (list tag -4 b2 i 8) (list tag 0x12345678 () () 1))
		   (if (= x86-sample-mode 'x64) (list (list tag '(rel 16) 'RIP () 1)) ())))))

(define-function x86-samples (row k pos)
  (let* ((c (x86-kind k)) (size (x86-row-size row x86-sample-mode)) (x64 (= x86-sample-mode 'x64)))
    (cond
      ((= 'r (car c))	(if x64
			    (list (x86-sample-reg 'r (cadr c) (% pos 4)) (x86-sample-reg 'r (cadr c) (+ 8 (% pos 8))))
			  (list (x86-sample-reg 'r (cadr c) (% pos 4)) (x86-sample-reg 'r (cadr c) (if (= 1 (cadr c)) 7 (+ 4 (% pos 4)))))))
            ((= 'x (car c))	(list (x86-sample-reg 'x 16 (% pos 8)) (x86-sample-reg 'x 16 (if x64 (+ 8 (% pos 8)) 7))))
      ((= 'y (car c))	(list (x86-sample-reg 'y 32 (% pos 8)) (x86-sample-reg 'y 32 (if x64 (+ 8 (% pos 8)) 7))))
      ((= 'ym (car c))	(concat-list (x86-samples row 'ymm pos) (x86-memories (x86-mem-tag (cadr c)) pos)))
      ((= 'rm (car c))	(concat-list (x86-samples row (list-detect e '(r8 r16 r32 r64) (= (cadr c) (cadr (x86-kind e)))) pos)
				     (x86-memories (x86-mem-tag (cadr c)) pos)))
      ((= 'xm (car c))	(concat-list (x86-samples row 'xmm pos) (x86-memories (x86-mem-tag (cadr c)) pos)))
      ((= 'mem (car c))	(x86-memories (x86-mem-tag (cadr c)) pos))
      ((= 'm (car c))	(x86-memories 'm pos))
      ((= 'imm (car c))	(let ((bits (* 8 (cadr c))))
			  (cond ((= bits 64)		'(5 -2 0x123456789abcdef0))
				((x86-unsigned? row)	(list 0 (- (<< 1 bits) 1)))
				((<= size (cadr c))	(list 5 -2 (- (<< 1 (- bits 1)) 1) (- (<< 1 bits) 1)))
				(else			(list 5 -2 (- (<< 1 (- bits 1)) 1))))))
            ((= 'rel (car c))	(if (= 1 (cadr c)) '((rel 8) (rel -8)) '((rel 8) (rel -8) (rel 0x10000))))
      ((= 'one (car c))	'(1))
      (else		(list k)))))

(define x86-ptr '((m8 . "BYTE PTR ") (m16 . "WORD PTR ") (m32 . "DWORD PTR ") (m64 . "QWORD PTR ") (m128 . "XMMWORD PTR ") (m256 . "YMMWORD PTR ") (m . "")))

;; Intel syntax, as clang reads it.
(define-function x86-text (op label . kind)
  (cond
    ((symbol? op)	(symbol->string op))
    ((long? op)		(long->string op))
    ((= 'rel (car op))	(concat-strings "L" (long->string label) (if (< (cadr op) 0) " - " " + ")
				(long->string (if (< (cadr op) 0) (- 0 (cadr op)) (cadr op)))))
    ((x86-mem? op)
     (let ((d (cadr op)) (b (caddr op)) (i (cadddr op)) (s (car (cddddr op))) (parts ()))
       (and b (set parts (list (symbol->string b))))
       (and i (set parts (concat-list parts (list (concat-strings (symbol->string i) "*" (long->string s))))))
       (concat-strings (cdr (assq (car op) x86-ptr)) "["
		       (cond ((pair? d)	(concat-strings (car parts) " + " (x86-text d label)))
			     ((not parts)	(format "0x%lx" d))
			     (else		(let ((t (car parts)))
						  (and (cdr parts) (set t (concat-strings t " + " (cadr parts))))
						  (cond ((< d 0) (concat-strings t " - " (long->string (- 0 d))))
							((> d 0) (concat-strings t " + " (long->string d)))
							(else t)))))
		       "]")))))
