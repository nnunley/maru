;;; catch.l unwinds native and Maru frames alike, on each evaluator and instruction set.
(require "catch.l")
(define ok 1)
(define-function expect (what got want)
  (or (equal got want) (let () (set ok ()) (println "FAIL " what ": got " got ", want " want))))
(define-function deep (n tag) (if (= n 0) (throw tag 'deep) (+ 1 (deep (- n 1) tag))))
(define-function churn (n) (let ((l ())) (for (i 0 n) (set l (cons i l))) (list-length l)))

(expect "a normal answer" (catch 'a (lambda () 42)) 42)
(expect "a thrown value" (catch 'a (lambda () (throw 'a 7) 8)) 7)
(expect "through many frames" (catch 'a (lambda () (deep 500 'a))) 'deep)
(expect "through C, in map" (catch 'a (lambda () (map (lambda (x) (throw 'a x)) '(1 2 3)))) 1)
(expect "the inner tag" (catch 'o (lambda () (list 'o (catch 'i (lambda () (throw 'i 1) 2))))) '(o 1))
(expect "past the inner, to the outer" (catch 'o (lambda () (catch 'i (lambda () (throw 'o 1))) 2)) 1)
(expect "a catch is gone once it returns" *catch-tags* ())
(expect "and the thrown value" *thrown* ())

;; the collector's roots are right after a throw: nothing live is freed, nothing freed is marked
(let ((live (list 1 2 3)))
  (for (i 0 2000)
    (catch 'a (lambda () (let ((x (list i i))) (churn 50) (deep 20 'a)))))
  (for (i 0 20) (churn 30000))
  (expect "what was live stays live" live '(1 2 3)))
;; many throws leave the stack where it was: at this depth a leak would overflow it
(for (i 0 200000) (catch 'a (lambda () (throw 'a i))))
(expect "many throws" (catch 'a (lambda () (throw 'a 'done))) 'done)

;; cleanups, on the way out and on a normal end
(let ((seen ()))
  (expect "a normal end" (unwind-protect 1 (push seen 'normal)) 1)
  (expect "a throw past it"
	  (catch 'o (lambda () (unwind-protect (throw 'o 2) (push seen 'thrown)) 3)) 2)
  (expect "each cleanup ran" seen '(thrown normal)))
(expect "the state after" *thrown* ())
(and ok (println "catch ok"))
