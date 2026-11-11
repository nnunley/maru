;;; kscript.g reads every KScript listing transcribed from TR-2012-001 (the arguments), and
;;; kscript.l runs streams tick by tick: fby, lag, when, undefined, and a selector on a box.
(require "kscript.l")

(define ok 1)
(define-function expect (what got want)
  (or (equal got want)
      (let () (set ok ()) (println "FAIL " what ": got " got ", want " want))))

(define-function box-of (source)
  (let ((box (ks-new-object 'KSBox 1 () () () 0)))
    (list-do st (kscript-parse source) (ks-eval st () box))
    box))

(define-function ks-run (text) (ks-stream-curr (ks-eval (car (kscript-parse text)) () ())))
;; a stream's value at each of ticks logical times
(define-function ticks (source name n)
  (let ((box (box-of source))
	(ev (ks-evaluator-new))
	(out ()))
    (ks-evaluator-add-from ev box)
    (for (t 0 n)
      (ks-sort-and-evaluate-at ev t)
      (push out (ks-val box name)))
    (list-reverse! out)))

(let ((n 0))
  (while *arguments*
    (kscript-read (next-argument))
    (incr n))
  (expect "listings read" n 39))

(expect "a stream, its lag and fby"
	(kscript-parse "nat <- 0 fby nat' + 1")
	'((stream-def nat (fby 0 (+ (lag nat) 1) ()))))

;; a primed name isn't a dependency: with no trigger, nat "would never update"
(expect "nat with no trigger" (ticks "nat <- 0 fby nat' + 1" 'nat 5) '(0 0 0 0 0))

;; mutual references, each through a lag (the report's a and b)
(let ((source "timer <- timerE(1)
a <- true fby when timer then b'
b <- false fby when timer then a'
"))
  (expect "a" (ticks source 'a 5) '(t () t () t))
  (expect "b" (ticks source 'b 5) '(() t () t ())))

;; undefined stops a change propagating, and the stream keeps its value (the report's stopper)
(let ((source "myTimer <- timerE(1)
stopper <- if myTimer > 2 then undefined else myTimer
viewer <- stopper * 10
"))
  (expect "stopper" (ticks source 'stopper 5) '(0 1 2 2 2))
  (expect "viewer" (ticks source 'viewer 5) '(0 10 20 20 20)))

;; mergeE takes the stream that fired, not one holding an older value
(expect "mergeE"
	(ticks "even <- timerE(2)
odd <- when timerE(1) then 100
m <- mergeE(even, odd)
" 'm 4)
	'(0 100 2 100))

;; a when that doesn't fire is undefined, and the stream keeps its value
(expect "when holds between events"
	(ticks "t <- timerE(2)
c <- 0 fby when t then c' + 1
" 'c 5)
	'(0 0 1 1 2))

(expect "a long equals a double" (ks-eval (car (kscript-parse "1 == 1.0")) () ()) 't)

(let ((box (box-of "")))
  (ks-set-val box 'bounds (ks-rect 1 2 3 4))
  (let ((p (ks-eval (car (kscript-parse "this.topLeft()")) () box)))
    (expect "a box's topLeft" (list (<ks-point>-x p) (<ks-point>-y p)) '(1 2))))

;; for over a range by a step
(expect "for by" (ks-val (box-of "total := 0
for i in [0...10] by 5 total := total + i
") 'total) 15)

;; KScript's truth is Maru's: true is t, false and nil are both (), and anything else, an empty array too, is true
(expect "true, false and nil are Maru's t and ()" (list (ks-run "true") (ks-run "false") (ks-run "nil") (ks-run "false == nil")) '(t () () t))
(expect "comparisons and not answer t and ()" (list (ks-run "1 < 2") (ks-run "2 < 1") (ks-run "not true") (ks-run "not nil")) '(t () () t))
(expect "undefined is neither, and stops a change" (list (ks-run "undefined") (ks-run "not undefined")) '(undefined undefined))
(expect "t is a Symbol (as test-pepsi.l's true is #true), () an UndefinedObject"
	(list (ks-class-of 't) (ks-class-of ()) (ks-send 't 'asBoolean () () ()) (ks-send () 'asBoolean () () ())
	      (ks-send 't 'printString () () ()) (ks-send () 'printString () () ()))
	'(Symbol UndefinedObject t () "true" "nil"))
(let ((box (box-of "flag := false\n")))
  (expect "a field holding false is a field: read and set by a send, never missing"
	  (list (ks-send box 'flag () () box) (ks-send box 'flag '(t) () box) (ks-val box 'flag)) '(() t t)))

;; KScript's lists are Maru arrays (one representation with Smalltalk's Arrays): a literal, a range and a comprehension
;; each make one, counted from 0 by an index, and an empty one is a collection, true as a test, never nil or false
(let ((a (ks-run "[1, 2, 3]")))
  (expect "a literal is an array" (and (array? a) (array->list a)) '(1 2 3)))
(expect "a range is an array" (let ((a (ks-run "[1...3]"))) (and (array? a) (array->list a))) '(1 2 3))
(expect "a comprehension is an array" (let ((a (ks-run "[x * 2 for x in [1, 2, 3] when x > 1]"))) (and (array? a) (array->list a))) '(4 6))
(expect "an index counts from 0" (ks-run "[10, 20, 30][1]") 20)
(expect "an empty array: size 0, isEmpty, and true as a test"
	(list (ks-run "[].size()") (ks-truthy? (ks-run "[].isEmpty()")) (ks-run "if [] then 1 else 2") (ks-run "if nil then 1 else 2"))
	'(0 t 1 2))
(expect "for, a comprehension and a detect over an array"
	(list (ks-val (box-of "total := 0\nfor i in [1, 2, 3] total := total + i\n") 'total) (ks-run "(x in [1, 2, 3] when x > 1)"))
	'(6 2))
(expect "first, second, copy and sort of an array"
	(list (ks-run "[3, 1, 2].first()") (ks-run "[3, 1, 2].second()") (array->list (ks-run "[3, 1, 2].copy()")) (array->list (ks-run "[3, 1, 2].sort()")))
	'(3 1 (3 1 2) (1 2 3)))

(expect "a long range, made without recursion" (array-length (ks-run "[1...20000]")) 20000)
;; an object's [k] is its slot k, as a.k is: KSCompiler>>get compiles both to ksAt:, so a stream answers as itself, not
;; its value (check/ksworld.l maps one named by its key)
(let ((box (box-of "n <- 5\n")))
  (expect "an object's [k], its field k: the stream itself"
	  (let ((at (ks-eval (car (kscript-parse "this[\"n\"]")) () box)))
	    (list (and (ks-stream? at) 't) (= at (ks-eval (car (kscript-parse "this.n")) () box))))
	  '(t t))
  ;; @n in a function's body is n's value: KSQuoteTranslator>>trans reads each step's currentValue there
  (expect "a function's @chain: its read, and the value it ends at"
	  (let ((fn (ks-read-chains (car (kscript-parse "() -> @n")) ())))
	    (list fn (ks-apply (ks-eval fn () box) () () box)))
	  '((fn () (chain-value (stream-ref n))) 5)))
;; a chain's end as KSNewEventStream>>findForGet: finds it: the root's value, then v ksAt: key for each key, a slot not
;; unwrapped, so after the first key v is a stream and the next key is its own or its home object's.  a's value holds
;; b, whose value holds c (2), and c (1) beside b: @a.b ends at b, and @a.b.c at the c beside b
(let* ((x (ks-new-object 'KSBox 1 () () () 0)) (y (ks-new-object 'KSBox 1 () () () 0)) (box (ks-new-object 'KSBox 1 () () () 0)))
  (ks-set-slot y 'c (ks-make-stream y "exprE" "" 2))
  (ks-set-slot x 'b (ks-make-stream x "exprE" "" y))
  (ks-set-slot x 'c (ks-make-stream x "exprE" "" 1))
  (ks-set-slot box 'a (ks-make-stream box "exprE" "" x))
  (expect "a two-step chain ends at the key's slot in the root's value"
	  (= (ks-chain-end (car (kscript-parse "@a.b")) box) (ks-slot x 'b)) 't)
  (expect "a three-step chain ends at the last key on the object holding the one before it"
	  (= (ks-chain-end (car (kscript-parse "@a.b.c")) box) (ks-slot x 'c)) 't))
;; a send to a reference in a stream's expression: a combinator's on the stream, any other to its value, as
;; KSObject>>eventStream falls back to exprE; in KScript 2 code a chain from a name is a reference (a fieldRef), and in a
;; function's body reads its value at each step (KSCompiler>>fieldRef): deviation-demo's slider1.bounds.center()
(let* ((box (box-of "b <- P(10, 20).extent(P(30, 40))\n"))
       (run (lambda (text v2) (ks-stream-curr (ks-eval (ks-read-chains (car (kscript-parse text)) v2) () box)))))
  (expect "a stream of a rectangle, its center and width"
	  (list (run "this.b.center().y()" 't) (run "@b.center().y()" ()) (ks-apply (run "() -> this.b.width()" 't) () () box))
	  '(40 40 30))
  (expect "a combinator's receiver, the stream itself"
	  (ks-read-chains (car (kscript-parse "this.b.mapE((r) -> r.width())")) 't)
	  '(send (field this b) mapE (fn (r) (send r width)))))
(expect "an element of an array is set by its index"
	(let ((box (box-of "a := [1, 2, 3]\na[1] := 9\n"))) (array->list (ks-val box 'a))) '(1 9 3))

(expect "a stream with no value is undefined, one holding false is false"
	(let ((none (ks-new-object 'KSEventStream 0 () () () 0)) (off (ks-make-stream () "exprE" "" ())))
	  (list (ks-stream-curr none) (ks-stream-prev none) (ks-stream-curr off) (ks-stream-prev off)))
	'(undefined undefined () ()))

(let ((s (ks-make-stream () "exprE" "" 1)) (f (ks-eval (car (kscript-parse "(v, acc) -> acc && v > 3")) () ())))
  (ks-send s 'collectE (list 't f) () ())
  (ks-set-slot s '__currentValue__ 5)
  (expect "collectE carries a false accumulator on, not its first value" (ks-send s 'collectE (list 't f) () ()) ()))
;; set fires the stream, so what depends on it updates (scroll bars and halos set a stream from a method, TR-2013-002 §3.1)
(expect "set from a stream"
	(ticks "x <- 1
y <- x * 2
d <- when timerE(2) then this.x.set(5)
" 'y 4)
	'(2 2 10 10))
(expect "set from a method"
	(ticks "x <- 1
y <- x * 2
poke = () -> this.x.set(5)
d <- when timerE(2) then poke()
" 'y 4)
	'(2 2 10 10))
(let ((box (box-of "x <- 1
y <- x * 2
")) (ev (ks-evaluator-new)) (out ()))
  (ks-evaluator-add-from ev box)
  (for (t 0 4)
    (when (= t 2) (set *ks-logical-time* t) (ks-send (ks-slot box 'x) 'set (list 5) () ()))
    (ks-sort-and-evaluate-at ev t)
    (push out (ks-val box 'y)))
  (expect "set between ticks" (list-reverse! out) '(2 2 10 10)))
;; set to undefined stops the change, as any undefined does: the stream keeps its value and doesn't fire
(expect "set to undefined"
	(ticks "x <- 1
y <- x * 2
d <- when timerE(2) then this.x.set(undefined)
" 'y 4)
	'(2 2 2 2))

(let ((ev (ks-evaluator-new)) (box (box-of "")) (none (ks-new-object 'KSEventStream 0 () () () 0)))
  (ks-set-slot box 'quiet none)
  (ks-evaluator-add-from ev box)
  (ks-sort-and-evaluate-at ev 1)
  (expect "a stream with no value stays undefined in its previous value" (ks-stream-prev none) 'undefined))
;; anyE and switchColE take the item whose stream fired, not the first holding a value (the reports' menus and toolbars)
(let ((a (box-of "")) (b (box-of "x <- 5")) (c (box-of "x <- 6")) (ev (ks-evaluator-new)))
  (ks-evaluator-add-from ev b)
  (ks-evaluator-add-from ev c)
  (ks-sort-and-evaluate-at ev 0)
  (expect "anyE passes over a box without the slot" (ks-eval `(call anyE (global ,(list->array (list a b c))) "x") () ()) 5))
(let ((one (box-of "fire <- when timerE(2) then 1"))
      (two (box-of "fire <- when timerE(3) then 2"))
      (menu (box-of ""))
      (ev (ks-evaluator-new))
      (out ()))
  (ks-set-slot menu 'items (list->array (list one two)))
  (list-do st (kscript-parse "anyPick <- anyE(items, \"fire\")
switchPick <- switchColE(items, \"fire\")
") (ks-eval st () menu))
  (list-do box (list one two menu) (ks-evaluator-add-from ev box))
  (for (t 0 6)
    (ks-sort-and-evaluate-at ev t)
    (push out (list (ks-val menu 'anyPick) (ks-val menu 'switchPick))))
  ;; both fire at 0 (the first is taken), the first at 2 and 4, the second at 3; between, the pick holds
  (expect "anyE and switchColE take the one that fired" (list-reverse! out) '((1 1) (1 1) (1 1) (2 2) (1 1) (1 1))))

(and ok (println "kscript ok"))
