;;; Held registers (h0, h1 …): abi.spec's held row, mapped by stub-reg as s0, s1 … are mapped from its scratch row, hold a
;;; value from its producer to its consumer, so no intent's lowering may touch one except as that value.  The cases: the
;;; mapping, a hand-built unit computing through h registers and run natively, and the scan, which lowers every intent of
;;; check/native/*.k's units and LOADER (default maru-check.k) with sites off, for each ISA, and reports each form naming
;;; a held machine register its intent doesn't carry as that h register.  The last line is "native held ok".
;;;   ./eval2 check/native-held.l [LOADER]
(define loader (and *arguments* (pop *arguments*)))	; before native.l: maru.k loads any arguments left
(define *arm64-sites* ())	; symbolic forms, so the scan can read the registers they name
(require "native.l")
(define failures 0)
(define-function expect (what got want)
  (or (equal got want) (let () (set failures (+ failures 1)) (println "FAIL " what ": got " got ", want " want))))

(expect "h0 on arm64" (stub-reg 'arm64 'h0) 'X13)
(expect "h5 on arm64" (stub-reg 'arm64 'h5) 'X4)
(expect "h1 on x64" (stub-reg 'x64 'h1) 'RDI)
(require "recover.l")
(expect "h2 on x64, which holds two, refused" (try (let () (stub-reg 'x64 'h2) ()) (lambda (c) 't)) 't)

;; a unit of intents written by hand: (a + b) * b, its arguments loaded into h registers and computed through them
(define held-unit
  (new <native-unit>
       (list (list '__init '((enter 16 0) (params ()) (leave 16) (return)) 16)
	     (list 'held_sum '((enter 32 0) (params ((8 0 int) (8 8 int))) (load 8 0 h0) (load 8 8 h1) (op add h0 h0 h1)
			       (op mul h0 h0 h1) (store 8 16 h0) (result 8 16 int) (leave 32) (return))
		   32))
       ()))
(let ((image (native-install held-unit)))
  (expect "a unit computing through h registers" ((subr (cdr (assq 'held_sum image)) "ll>l") 3 4) 28))

;; the scan: each held machine register's names (its views), and the h registers an intent carries
(define-function held-views (isa r)
  (cond ((= isa 'x64) (cdr (assq r '((RSI RSI ESI SI SIL) (RDI RDI EDI DI DIL)))))
	(else (let ((name (symbol->string r))) (list r (string->symbol (concat-string "W" (string-copy name 1 (- (string-length name) 1))))))))
  )
(define-function symbols-in (x out)	; every symbol in x, onto out
  (cond ((symbol? x) (cons x out))
	((pair? x) (symbols-in (cdr x) (symbols-in (car x) out)))
	(else out)))
(define-function h-register? (s) (let ((n (symbol->string s))) (and (< 1 (string-length n)) (= ?h (string-at n 0)) (<= ?0 (string-at n 1)) (<= (string-at n 1) ?9))))
(define-function native-held-violations (unit isa held)	; held: the ISA's held machine registers
  (let ((lower (cdr (assq isa native-lowerings))) (out ()))
    (list-do f (car (native-symbols (<native-unit>-functions unit)))
      (let ((intents (cadr f)) (forms (lower (cadr f))))
	(while intents
	  (let* ((allowed ()) (i (car intents)))
	    (list-do s (symbols-in i ()) (and (h-register? s) (set allowed (concat-list (held-views isa (stub-reg isa s)) allowed))))
	    ;; params and call use the argument registers, held between calls: no held value spans a call, and params runs
	    ;; before any
	    (and (memq (car i) '(params call)) (list-do r held (set allowed (concat-list (held-views isa r) allowed))))
	    (list-do form (car forms)
	      (list-do s (symbols-in form ())
		(and (not (memq s allowed))
		     (list-detect r held (memq s (held-views isa r)))
		     (push out (list (car f) i form))))))
	  (set intents (cdr intents)) (set forms (cdr forms)))))
    out))

(expect "the scan finds a register enter and leave name" (< 0 (list-length (native-held-violations held-unit 'arm64 '(X29)))) 't)
(list-do isa '(arm64 x64)
  (expect (concat-string "the hand-built unit, scanned on " (symbol->string isa)) (native-held-violations held-unit isa (abi isa 'held)) ()))
(list-do path (concat-list '("check/native/add.k" "check/native/flow.k" "check/native/memory.k" "check/native/floats.k" "check/native/calls.k"
			     "check/native/extern-self.k" "check/native/held.k")
			   (list (or loader "maru-check.k")))
  (let ((unit (native-compile-file path)))	; one unit, its intents lowered for each ISA: the same on all of them
    (list-do isa '(arm64 x64)
      (let ((v (native-held-violations unit isa (abi isa 'held))))
	(or (not v) (println "  " path " on " isa ": " (car v)))
	(expect (concat-string path (concat-string " scanned on " (symbol->string isa))) (list-length v) 0)))))
(or (= 0 failures) (error "native-held: " failures " failures"))
(println "native held ok")
