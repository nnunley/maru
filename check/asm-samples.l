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

