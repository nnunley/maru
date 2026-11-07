;;; KSWorld's own methods from its sources (ksworld-source.l): a class's file-out (ksworld/CLASS.st, Squeak's chunk format,
;;; read by st-fileout.g) gives each method's category and source; a KScript one is read by kscript.g, and becomes a method
;;; of its class, answering the sends a document makes of its instances.  KSTextLayout's 73 methods are 72 KScript and 1
;;; Smalltalk, as ksworld/INDEX.txt counts them.
(require "ksworld-source.l")
(define ok 1)
(define-function expect (what got want)
  (or (equal got want) (let () (set ok ()) (print "FAIL " what ": got ") (dump got) (print ", want ") (dump want) (println))))

(let* ((ms (ks-source-methods "ksworld/KSTextLayout.st"))
       (kscript (let ((n 0)) (list-do m ms (and (<ks-source-method>-kscript? m) (set n (+ n 1)))) n))
       (unread (let ((out ())) (list-do m ms (and (<ks-source-method>-kscript? m) (not (<ks-source-method>-tree m))
						 (push out (<ks-source-method>-selector m))))
		     out)))
  (expect "every method of the file-out" (list-length ms) 73)
  (expect "KScript ones as INDEX.txt counts them" kscript 72)
  (expect "every KScript method read" unread ())
  (let ((do08 (let ((f ())) (list-do m ms (and (= 'do08 (<ks-source-method>-selector m)) (set f m))) f)))
    (expect "a method's class and category" (list (<ks-source-method>-class do08) (<ks-source-method>-category do08))
	    '(KSTextLayout "key commands"))
    (expect "its parameters and body as kscript.g reads them" (<ks-source-method>-tree do08)
	    '(fn () (send this textAction "delete"))))
  ;; the three constructs the methods use that the documents' streams don't
  (expect "+= and -=" (kscript-parse "this.n += 1\nthis.n -= 2") '((assign-add (field this n) 1) (assign-sub (field this n) 2)))
  (expect "a symbol literal" (kscript-parse "x = #'wordWidth'") '((assign x (symbol wordWidth))))
  (expect "a stream made from an expression" (kscript-parse "x = $$(@s.doE(() -> 1))")
	  '((assign x (stream-expr (send (stream-ref s) doE (fn () 1)))))))

;; a class's KScript methods answer its instances' sends
(ks-load-source-class 'KSTextLayout)
(expect "a source method is the class's" (and (ks-method-for 'KSTextLayout 'do08) 1) 1)

;; Smalltalk methods, read by squeak.g to KScript's trees: every one of KSContentsCollection's and KSBox's
(list-do f '("ksworld/KSContentsCollection.st" "ksworld/KSBox.st")
  (let ((unread ()) (n 0))
    (list-do m (ks-source-methods f)
      (unless (<ks-source-method>-kscript? m)
	(set n (+ n 1))
	(or (<ks-source-method>-tree m) (push unread (<ks-source-method>-selector m)))))
    (expect (concat-string "every Smalltalk method read: " f) unread ())))
(let ((ms (ks-source-methods "ksworld/KSContentsCollection.st")))
  (expect "the class definition: its superclass and instance variables" (ks-source-class-of "ksworld/KSContentsCollection.st")
	  '(KSContentsCollection Object (array firstIndex lastIndex indexCache)))
  (let ((tree-of (lambda (sel) (let ((f ())) (list-do m ms (and (= sel (<ks-source-method>-selector m)) (set f (<ks-source-method>-tree m)))) f))))
    (expect "a keyword method and its send, in KScript's naming of Smalltalk's selectors" (tree-of '_add)
	    '(fn (newObject) (method-return (send this _addLast newObject))))
    (expect "an instance variable, a temporary, a block and ^" (tree-of '_after_ifAbsent)
	    '(fn (target exceptionBlock) (var index nil) (assign index (send this _indexOf target))
		 (method-return (send (send (send index = 0) _or (fn () (send index = (send this size)))) _ifTrue_ifFalse
				      (fn () (send exceptionBlock value)) (fn () (send this _at (send index + 1)))))))
    (expect "assigning an instance variable" (tree-of '_addFirst)
	    '(fn (newObject) (send (send (field this firstIndex) = 1) _ifTrue (fn () (send this makeRoomAtFirst)))
		 (assign (field this firstIndex) (send (field this firstIndex) - 1))
		 (send (field this array) _at_put (field this firstIndex) newObject)
		 (method-return newObject)))))

(println (if ok "ksworld sources ok" "ksworld sources FAILED"))
