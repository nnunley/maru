;;; Call by meaning (meaning.l) against a scripted model: a spec that lies, a formula that's wrong, one that tries to do
;;; more than compute, answers asked again, and an adapter kept in the world it was found in.  And the model client
;;; (ollama.l) against a server forked here: a reply, a refusal, nothing listening, and JSON both ways.
(require "meaning.l")
(define ok 1)
(define-function expect (what c) (or c (let () (set ok ()) (println "FAIL " what))))
(define-function has? (str sub)
  (let ((i 0) (n (- (string-length str) (string-length sub))))
    (while (and (<= i n) (not (= sub (string-copy str i (string-length sub))))) (incr i))
    (<= i n)))

(define *script* ())  (define *prompts* ())  (define *calls* 0)
(set *meaning-model*
     (lambda (prompt)
       (set *calls* (+ *calls* 1)) (push *prompts* prompt)
       (if *script* (let ((a (car *script*))) (set *script* (cdr *script*)) a) "nothing left")))
(define world "
create Converter spec factor.
make Converter Honest \"multiplies minutes by 60 to give seconds\" 60.
make Converter Liar \"converts minutes to seconds\" 100.
make Converter Grams \"turns kilograms into grams\" 1000.
qualify Converter convert: N is it factor * N.
qualify Converter minutes-to-seconds if it convert: 2 = 120 and it convert: 5 = 300.
")
(define-function run (script statements)	; a fresh model record, so every question is asked
  (set *script* script) (set *prompts* ()) (set *calls* 0) (set *meaning-answers* ())
  (john-run (concat-list (john-read-text world) (john-read-text statements))))
;; the error's message, or () if it ran.  Its arguments are the literals in the source: a string the program made is
;; undone with the failed world (recover.l)
(define-function fails (script statements)
  (try (let () (run script statements) ()) (lambda (c) (concat-strings (cadr c) (caddr c)))))

(expect "a spec that lies is caught by what it does"
	(equal '("Honest") (run '("Liar" "Honest") "\"converts minutes to seconds\" find-passing: \"minutes-to-seconds\".")))
(expect "and the model is told why" (has? (car *prompts*) "Liar: its behaviour doesn't match"))
(expect "a reply's numbering and emphasis aren't its name"
	(equal '("Honest") (run '("1. **Honest**") "\"converts minutes to seconds\" find-passing: \"minutes-to-seconds\".")))
(expect "a model that never finds one is an error, which try catches"
	(has? (fails '("Grams" "Liar" "Nobody") "\"converts minutes to seconds\" find-passing: \"minutes-to-seconds\".")
	      "john: no object found for: "))

(expect "a wrong formula is refused by the examples, and the right one used"
	(equal '("minutes from seconds" "15")
	       (run '("x * 60 + 1" "x / 60") "\"minutes from seconds\" adapt: [ [ 120, 2 ], [ 30, 0 ], [ 3600, 60 ] ]. 900 apply-adapter: \"minutes from seconds\".")))
(expect "the refusal says what it gave" (has? (car *prompts*) "x * 60 + 1: gives 7201 for 120, not 2"))
(expect "two calls" (= 2 *calls*))
(expect "a reply that sends a message, or divides by zero on an example, is refused before it's used"
	(and (equal '("minutes from seconds") (run '("\"q\" ask" "x / (x - 120)" "x / 60") "\"minutes from seconds\" adapt: [ [ 120, 2 ] ]."))
	     (= 3 *calls*) (has? (car *prompts*) "gives no value for 120")))
(expect "usual precedence, and once found a formula runs with no model"
	(and (equal '("Fahrenheit from Celsius" "77" "98")
		    (run '("`x * 9 / 5 + 32`") "\"Fahrenheit from Celsius\" adapt: [ [ 100, 212 ], [ 0, 32 ], [ 40, 104 ] ]. 25 apply-adapter: \"Fahrenheit from Celsius\". 37 apply-adapter: \"Fahrenheit from Celsius\"."))
	     (= 1 *calls*)))
(expect "a value it has none for is an error"
	(equal "john: no value at " (fails '("60 / x") "\"per\" adapt: [ [ 60, 1 ] ]. 0 apply-adapter: \"per\".")))

;; the record: the same question asked again isn't sent again
(set *script* ()) (set *calls* 0)
(john-run (concat-list (john-read-text world) (john-read-text "\"Fahrenheit from Celsius\" adapt: [ [ 100, 212 ], [ 0, 32 ], [ 40, 104 ] ].")))
(expect "a question asked before is answered from the record" (= 0 *calls*))
;; an adapter found in a world is in that world and those after it, not before
(let ((parent *john-world*) (child (new <john-world>)))
  (set (<john-world>-parent child) parent)
  (set *script* '("x + 1")) (set *meaning-answers* ())
  (set *john-builtin-world* child)
  (john-adapt "plus one" '((1 2)))
  (let ((later (new <john-world>)))
    (set (<john-world>-parent later) child)
    (expect "an adapter is kept in the world it was found in, and the worlds after it"
	    (and (adapter-of later "plus one") (not (adapter-of parent "plus one"))))))

(expect "a formula found before is held to new examples, and asked for again if it fails them"
	(and (equal '("f" "f" "6") (run '("x + 1" "x * 3") "\"f\" adapt: [ [ 1, 2 ] ]. \"f\" adapt: [ [ 1, 3 ], [ 2, 6 ] ]. 2 apply-adapter: \"f\"."))
	     (= 2 *calls*)))
;; ---- the client
(expect "JSON read: objects, arrays, escapes, numbers"
	(equal (json-read "{\"a\":[1,-2,true,null],\"s\":\"x\\n\\u00e9\",\"o\":{}}")
	       (list (list 'object (cons "a" '(1 -2 true null)) (cons "s" "x\n\303\251") (cons "o" '(object))))))
(expect "JSON written reads back"
	(let ((v '(object ("m" . "a \"q\"\n") ("n" . (1 2)) ("f" . false)))) (equal (json-read (json-write v)) (list v))))
(expect "what isn't JSON reads as nothing" (not (json-read "{\"a\":")))
(define fork (subr "fork" ">i"))  (define waitpid (subr "waitpid" "ipi>i"))  (define quit (subr "_exit" "i"))
(define status ((subr "malloc" "l>p") 8))
(define-function serve-once (response)		; a server for one request, answering response; its port
  (let* ((l (socket-listen 0)) (pid (fork)))
    (when (= 0 pid)			; the child only serves, however that goes
      (try (let ((fd (socket-accept (car l))))
	     (socket-read-c fd socket-buffer socket-buffer-size)
	     (socket-send fd response)
	     (socket-close fd))
	   (lambda (c) ()))
      (quit 0))
    (socket-close (car l))
    (cons pid (cdr l))))
(define-function ask-server (response)
  (let ((s (serve-once response)))
    (set *ollama-port* (cdr s))
    (let ((answer (ollama-ask "public text")))
      (waitpid (car s) status 0)
      answer)))
(expect "a reply's message content"
	(equal "x / 60" (ask-server "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n\r\n{\"model\":\"m\",\"message\":{\"role\":\"assistant\",\"content\":\"x / 60\"},\"done\":true}")))
(expect "a refusal is no answer" (not (ask-server "HTTP/1.1 404 Not Found\r\n\r\n{\"error\":\"model not found\"}")))
(expect "a reply that isn't a chat reply is no answer" (not (ask-server "HTTP/1.1 200 OK\r\n\r\n{\"done\":true}")))
(set *ollama-port* (cdr (let ((l (socket-listen 0))) (socket-close (car l)) l)))
(expect "nothing listening is no answer" (not (ollama-ask "public text")))
(expect "a server that closes before reading a long request is no answer, not SIGPIPE"
	(let ((s (serve-once "")) (long "x"))
	  (set *ollama-port* (cdr s))
	  (for (i 0 18) (set long (concat-strings long long)))
	  (let ((answer (ollama-ask long))) (waitpid (car s) status 0) (not answer))))
(expect "control characters are escaped" (equal (json-write "a\001b") "\"a\\u0001b\""))

(println (if ok "meaning ok" "meaning FAILED"))
