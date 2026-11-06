;;; THROWAWAY SPIKE.  Call by meaning against a scripted model: a spec that lies, a formula that's wrong, one that tries to do more than
;;; compute, and answers read back from the store.
(require "spike/meaning.l")
(define *script* ())  (define *prompts* ())  (define *calls* 0)
(set llm-generate
     (lambda (prompt)
       (set *calls* (+ *calls* 1)) (push *prompts* prompt)
       (if *script* (let ((a (car *script*))) (set *script* (cdr *script*)) a) "nothing left")))
(define failures 0)
(define-function check-that (name ok) (println (if ok "ok   " "FAIL ") name) (or ok (set failures (+ failures 1))))
(define-function has-text? (lines text) (let ((r ())) (list-do l lines (and (text-find l text 0) (set r 1))) r))
(define world "
create Converter spec factor.
make Converter Honest \"multiplies minutes by 60 to give seconds\" 60.
make Converter Liar \"converts minutes to seconds\" 100.
make Converter Grams \"turns kilograms into grams\" 1000.
qualify Converter convert: N is it factor * N.
qualify Converter minutes-to-seconds if it convert: 2 = 120 and it convert: 5 = 300.
")
(define-function run (script statements)
  (set *script* script) (set *prompts* ()) (set *calls* 0) (set *adapters* ()) (set *john-replica* (replica-new (quote a)))
  (john-run (concat-list (john-read-text world) (john-read-text statements))))
(let ((out (run '("Liar" "Honest") "\"converts minutes to seconds\" find-passing: \"minutes-to-seconds\".")))
  (check-that "a spec that lies is caught by what it does" (equal '("Honest") out))
  (check-that "and the model is told why" (text-find (car *prompts*) "Liar: its behaviour doesn't match" 0)))
;; John's errors end the program, so this one runs in a child
(define fork (subr "fork" ">i"))  (define waitpid (subr "waitpid" "ipi>i"))  (define quit (subr "_exit" "i"))
(define status ((subr "malloc" "l>p") 8))
(define-function fails? (thunk)
  (let ((pid (fork)))
    (if (= 0 pid)
	(let () (thunk) (quit 0))
      (let () (waitpid pid status 0) (or (!= 0 (byte-at status 0)) (!= 0 (byte-at status 1)))))))
(check-that "a model that never finds one is an error, not a guess"
	    (fails? (lambda () (run '("Grams" "Liar" "Grams") "\"converts minutes to seconds\" find-passing: \"minutes-to-seconds\"."))))
(let ((out (run '("x * 60 + 1" "x / 60") "\"minutes from seconds\" adapt: [ [ 120, 2 ], [ 30, 0 ], [ 3600, 60 ] ]. 900 apply-adapter: \"minutes from seconds\".")))
  (check-that "a wrong formula is refused by the examples, and the right one used" (equal '("minutes from seconds" "15") out))
  (check-that "the refusal says what it gave" (text-find (car *prompts*) "gives 7201 for 120, not 2" 0))
  (check-that "two calls" (= 2 *calls*)))
(let ((out (run '("\"q\" ask" "load \"spike/evil.l\"" "x / 60") "\"minutes from seconds\" adapt: [ [ 120, 2 ] ].")))
  (check-that "a formula that sends a message, or loads, is refused before anything runs"
	      (and (equal '("minutes from seconds") out) (not (member? "spike/evil.l" *loaded*)) (= 3 *calls*))))
(let ((out (run '("(x * 9 / 5) + 32") "\"Fahrenheit from Celsius\" adapt: [ [ 100, 212 ], [ 0, 32 ], [ 40, 104 ] ]. 25 apply-adapter: \"Fahrenheit from Celsius\". 37 apply-adapter: \"Fahrenheit from Celsius\".")))
  (check-that "once found, a formula runs with no model: one call for any number of values" (and (equal '("Fahrenheit from Celsius" "77" "98") out) (= 1 *calls*))))
;; the record: a second run on the same replica asks nothing
(let ((r *john-replica*))
  (set *script* ()) (set *calls* 0) (set *adapters* ())
  (john-run (concat-list (john-read-text world) (john-read-text "\"Fahrenheit from Celsius\" adapt: [ [ 100, 212 ], [ 0, 32 ], [ 40, 104 ] ].")))
  (check-that "a replay reads the formula from the store" (= 0 *calls*)))
(println "failures " failures)
(exit (if (= 0 failures) 0 1))
