;;; For every row: encode sample operands, write them in Intel syntax for clang,
;;; and check that decoding our bytes gives back the instruction.

(define *spike* (next-argument))
(define bytes ())
(define-function _B (X b)	(set bytes (cons (& b 255) bytes)))
(define total 0)
(define n 0)
(define-function _PC (X)	(+ total (list-length bytes)))
(load (concat-string *spike* "/x86-pre.l"))
(load (concat-string *spike* "/x86-gen.l"))

(define mems '((m 8 EBP ESI 4) (m 0 EBP () 1) (m 0 ESP () 1) (m 1000 () ECX 2)
	       (m 0x1234 () () 1) (m -4 EBX () 1) (m 200 EAX EDI 8) (m -300 ESP EBP 1)))

(define-function samples (k size pos)
  (let ((c (kind k)))
    (cond
      ((= 'r (car c))	(list (reg-named (cadr c) pos)))
      ((= 'rm (car c))	(cons (reg-named (cadr c) 3) (map (lambda (x) (cons (mem-tag (cadr c)) (cdr x))) mems)))
      ((= 'm (car c))	mems)
      ((= 'imm (car c))	(let ((vs ()))
			  (list-do v (cdr (assq (cadr c) '((1 100 -5 200) (2 0x1234 -1000) (4 0x12345678 -100000))))
			    (and (fits? v (cadr c) size) (set vs (cons v vs))))
			  vs))
      ((= 'rel (car c))	(map (lambda (d) (list 'rel d)) (if (= 1 (cadr c)) '(-10 20) '(1000 -1000))))
      (else		(list k)))))

(define-function map2 (f a b) (and a (cons (f (car a) (car b)) (map2 f (cdr a) (cdr b)))))
(define-function product (ls)
  (if ls
      (let ((out ()))
	(list-do x (car ls) (list-do rest (product (cdr ls)) (set out (cons (cons x rest) out))))
	out)
    (list ())))

(define-function intel (op k)
  (cond
    ((mem? op)
     (concat-strings
      (cdr (assq (car op) '((m . "") (m8 . "byte ptr ") (m16 . "word ptr ") (m32 . "dword ptr "))))
      "[" (if (caddr op) (symbol->string (caddr op)) "")
      (if (cadddr op) (concat-strings (if (caddr op) " + " "") (symbol->string (cadddr op)) "*" (long->string (car (cddddr op)))) "")
      (if (or (caddr op) (cadddr op)) (concat-string " + " (long->string (cadr op))) (long->string (cadr op)))
      "]"))
    ((and (pair? op) (= 'rel (car op))) (concat-strings "L" (long->string n) (if (< (cadr op) 0) " - " " + ") (long->string (if (< (cadr op) 0) (- 0 (cadr op)) (cadr op)))))
    ((symbol? op)	(symbol->string op))
    (else		(long->string op))))

(define s (open (concat-string *spike* "/clang.s") "w"))
(define o (open (concat-string *spike* "/ours.txt") "w"))
(define-function out (f . strs)	(list-do x strs (string-do c x (putc c f))))
(out s ".intel_syntax noprefix\n")

(define fails 0)
(list-do row x86-rows
  (let ()
    (let ((size (row-size row)) (pos 0))
      (list-do sops (product (map (lambda (k) (set pos (+ pos 1)) (samples k size pos)) (cadr row)))
	(set bytes ())
	(let ((ops (map (lambda (x) (if (and (pair? x) (= 'rel (car x))) (+ total (cadr x)) x)) sops)))
	(apply x86 (cons () (cons (car row) ops)))
	(let* ((b (list-reverse! bytes))
	       (text (concat-strings (symbol->string (car row)) " "
				     (let ((ks (cadr row)) (strs ()))
				       (list-do x sops (set strs (cons (intel x (car ks)) strs)) (set ks (cdr ks)))
				       (let ((r "")) (list-do x (list-reverse! strs) (set r (if (= r "") x (concat-strings r ", " x)))) r))))
	       (back (x86-decode b total)))
	  (set n (+ n 1))
	  (set total (+ total (list-length b)))
	  (out s "L" (long->string (- n 1)) ": " text "\n")
	  (out o text "\t") (list-do x b (out o (format "%02x " x))) (out o "\n")
	  (unless (and (not (cdr back))
		       (equal (car back) (cons (car row) (map2 (lambda (op k) (if (and (long? op) (= 'imm (car (kind k))) (<= (cadr (kind k)) size)) (sext op (cadr (kind k))) op)) ops (cadr row)))))
	    (set fails (+ fails 1))
	    (println "ROUNDTRIP " text " -> " (car back) " rest " (cdr back)))))))))
(close s) (close o)
(println n " instructions, " fails " round-trip failures")
