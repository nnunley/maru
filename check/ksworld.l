;;; KSWorld documents run headless (ksworld-run.l): a fixture of ours, every stream read and run tick by tick, a send no
;;; method answers named as the failure; and, where the dbjr documents are (MARU_DBJR, else ~/pkm's copy), KSWorld.ks.
(require "ksworld-run.l")
(require "check/temp.l")
(define ok 1)
(define-function expect (what got want)
  (or (equal got want) (let () (set ok ()) (println "FAIL " what ": got " got ", want " want))))
(define-function at (r k) (cdr (assq k r)))

(let* ((r (ksworld-run "check/ksworld/tiny.pp" 4))
       (box (array-at (at r 'table) 1)))
  (expect "objects and streams" (list (at r 'objects) (at r 'streams) (at r 'setters) (at r 'code) (at r 'unreadable)) '(5 4 1 3 0))
  (expect "the counter counts the timer's ticks" (ks-val box 'count) 3)
  (expect "evaluations, fired, failed" (list (at r 'evaluations) (at r 'fired) (at r 'failed)) '(12 8 1))
  (expect "a setter keeps the value the document holds" (ks-val box 'label) "hello")
  (expect "a send nothing answers fails its stream, naming kind and selector"
	  (at r 'failures) '(("KScript: no method blink for KSBox" . 1))))

(expect "Color's class and its colours answer apart"
	(list (<ks-color>-r (ks-send 'Color 'white () () ())) (try (ks-send 'Color 'lighter () () ()) (lambda (c) (ksw-message c))))
	'(1.0 "KScript: no method lighter for ColorClass"))
(expect "match (the pattern receives it) and sort, as a listing uses them"
	(list (ks-send "*.jpg" 'match '("photo.JPG") () ()) (ks-send "*.jpg" 'match '("a.txt") () ()) (ks-send '(3 1 2) 'sort () () ()))
	'(true false (1 2 3)))
(expect "a value's kind names the failure too"
	(try (ks-send 5 'frobnicate () () ()) (lambda (c) (ksw-message c))) "KScript: no method frobnicate for Number")

(let* ((dir (or (env-var "MARU_DBJR") (concat-string (or (env-var "HOME") "/nonexistent") "/pkm/raw/vpri/frank/dbjr/docs")))
       (doc (concat-string dir "/d4ea559dada5.pp")))	; KSWorld.ks/index.pp
  (if (not (= 0 ((subr "access" "si>i") doc 4)))
      (println "KSWorld.ks: skipped, no dbjr documents at " dir)
    (let ((r (ksworld-run doc 3)))
      (expect "KSWorld.ks: objects and streams" (list (at r 'objects) (at r 'streams) (at r 'setters) (at r 'code) (at r 'unreadable))
	      '(520 346 281 65 0))
      (expect "KSWorld.ks: what's missing"
	      (at r 'failures)
	      '(("KScript: no method installSelection for KSTextLayout" . 10)
		("KScript: no method handlePointerMotion for KSTextLayout" . 5)
		("KScript: no method handleButtonDown for KSTextLayout" . 5))))))

(println (if ok "ksworld ok" "ksworld FAILED"))
