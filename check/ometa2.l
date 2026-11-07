;;; KSWorld's KScript2 compiler passes, OMeta2 grammar classes, run from their sources on Maru's PEG (ometa2.l, ometa2.g):
;;; their rule methods a tpeg grammar each, their Smalltalk actions run with the rules' bindings and the grammar's object.
(require "ometa2.l")
(define ok 1)
(define-function expect (what got want)
  (or (equal got want) (let () (set ok ()) (print "FAIL " what ": got ") (dump got) (print ", want ") (dump want) (println))))

;; ometa2.g reads OMeta2's rule syntax to tpeg's rules
(expect "a rule with a list pattern, a value, a binding and a result"
	(let ((p (text-parser-for-on <ometa2> "var :extraDep =\n\tanything:src anything:v\n\t\t-> [{#quoted. #(). {#var. src. v}}]")))
	  (text-parser-invoke-rule 'rule $rule p) (<text-parser>-result p))
	'(var (match-all (assign-result src (match-any)) (assign-result v (match-any)) (result-expr (smalltalk "{#quoted. #(). {#var. src. v}}"))) (extraDep)))

;; KSQuoteAttributor2 marks the nodes inside a stream expression that make streams: a send, a call, a field reference, and
;; a list holding one; the stream expression's own call and what holds no stream it leaves alone
(ometa2-load-class 'KSQuoteAttributor2 ())
(let* ((inner (list 'call "" '(var "timerE" timerE) 100))
       (body (list 'func "" '(x) () 'false '(var "x" x)))
       (send (list 'send "" 'mapE inner body))
       (tree (list 'call "" (list 'var "$$" (string->symbol "$$")) send))
       (attrs (ometa2-match 'KSQuoteAttributor2 'start tree ())))
  (expect "the send and the call inside are marked"
	  (list (ks-send attrs '_includesKey (list send) () attrs) (ks-send attrs '_includesKey (list inner) () attrs)) '(true true))
  (expect "the outer call and a plain variable are not"
	  (list (ks-send attrs '_includesKey (list tree) () attrs) (ks-send attrs '_includesKey (list (caddr inner)) () attrs)) '(false false)))

;; KSQuoteTranslator2, the pass that gives a stream expression its meaning, turns $$(timerE(100)) into KSWorld's construction
;; code: a pvtStrm declared as a new KSNewEventStream, the timerE stream added to it as a sub-expression (its selector, its
;; source, its argument), and the top level finished from the dependencies
(ks-load-source-class 'KSProtoObject)
(ks-load-source-class 'KSNewEventStream)
(ometa2-load-class 'KSQuoteTranslator2 ())
(let* ((call (list 'call "timerE(100)" '(var "timerE" timerE) 100))
       (tree (list 'call "$$(timerE(100))" (list 'var "$$" (string->symbol "$$")) call))
       (attrs (ometa2-match 'KSQuoteAttributor2 'start tree ()))
       (code (ometa2-match 'KSQuoteTranslator2 'start tree (list attrs))))
  (expect "a block that declares the stream" (list (car code) (caddr code)) '(begin (decl "pvtStrm" (quote pvtStrm) (new "" (var "KSNewEventStream" KSNewEventStream)))))
  (let ((add (cadddr code)))
    (expect "the timerE stream added as a sub-expression, made by eventStream with its selector, source and argument"
	    (list (car add) (caddr add) (car (caddr (cdddr add))) (cadddr (cddr (caddr (cdddr add)))))
	    '(send addSubExpression send (quote timerE))))
  (expect "the top level finished from what it depends on" (let ((l (car (last-pair code)))) (list (car l) (caddr l))) '(send finalizeTopLevelCreationWith2)))

(println (if ok "ometa2 ok" "ometa2 FAILED"))
