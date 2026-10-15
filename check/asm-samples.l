;;; Sample operands for every row, and clang's syntax for them; shared by
;;; check/asm-rows.l and check/asm-patch.l.

(define-function product (ls)
  (if ls
      (let ((out ()))
	(list-do x (car ls) (list-do rest (product (cdr ls)) (set out (cons (cons x rest) out))))
	out)
    (list ())))

(define-function reg-sym (p i)	(string->symbol (concat-string p (long->string i))))



;; Sample operands for kind k of row, using register number pos where a register goes.
(define-function arm64-samples (row k pos)
  (let ((c (car k)))
    (cond
      ((= c 'reg)	(let ((x (= ?X (string-at (symbol->string (cadr k)) 0))))
			  (list (reg-sym (if x "X" "W") pos)
				(if (caddr k) (if x 'SP 'WSP) (if x 'XZR 'WZR)))))
      ((= c 'imm)	(if (= 'imm0 (cadr k)) '(0)
			  (map (lambda (q) (* q (caddr k))) (list 7 (- (<< 1 (arm64-width-of row (cadr k))) 1)))))
      ((= c 'simm)	(let ((w (arm64-width-of row (cadr k))))
			  (map (lambda (q) (* q (caddr k))) (list -2 (- (<< 1 (- w 1)) 1) (- (<< 1 (- w 1)))))))
      ((= c 'pcpage)	(map (lambda (d) (list 'page d)) (list 4096 -8192 (* 4096 (- (<< 1 (- (arm64-width-of row (cadr k)) 1)) 1)))))
      ((= c 'pcrel)	(map (lambda (d) (list 'rel d)) (list 8 -8 (* (caddr k) (- (<< 1 (- (arm64-width-of row (cadr k)) 1)) 1)))))
      ((= c 'lsl)	'((LSL 0) (LSL 16) (LSL 48)))
      (else		(let ((out ()))
			  (list-do b (arm64-samples row (cadr k) 9)
			    (list-do i (arm64-samples row (caddr k) 0) (set out (cons (list c b i) out))))
			  out)))))

;; clang's syntax for one operand; label is this instruction's label number.
(define-function arm64-text (op label)
  (cond
    ((symbol? op)		(symbol->string op))
    ((long? op)			(concat-string "#" (long->string op)))
    ((= 'LSL (car op))		(concat-string "LSL #" (long->string (cadr op))))
    ((= 'page (car op))		(concat-string "#" (long->string (cadr op))))
    ((= 'rel (car op))		(concat-strings "L" (long->string label) (if (< (cadr op) 0) " - " " + ")
					(long->string (if (< (cadr op) 0) (- 0 (cadr op)) (cadr op)))))
    ((= 'off (car op))		(concat-strings "[" (arm64-text (cadr op) label) ", " (arm64-text (caddr op) label) "]"))
    ((= 'pre (car op))		(concat-strings "[" (arm64-text (cadr op) label) ", " (arm64-text (caddr op) label) "]!"))
    ((= 'post (car op))		(concat-strings "[" (arm64-text (cadr op) label) "], " (arm64-text (caddr op) label)))))

