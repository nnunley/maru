;;; grammar.l -- a grammar keeps its definition, to be reflected on.  Each grammar registers its rules as it's defined, a
;;; rule its name, parameters, body (the tree tpeg parsed) and annotations (each @name written before it).  Grammars live in
;;; scopes: the root holds tpeg's (compile-tpeg.l emits the registration), kept by type too, as Maru keeps a type's fields
;;; and bases; a compilation may make a scope of its own under it for grammars only it sees (irl's grammar blocks), whose
;;; names are found there first, then in the scopes above.
;;;   (grammar-of type)			a tpeg grammar's <grammar>, or ()
;;;   (grammar-named name [scope])		a grammar by name, in scope and those above it, or ()
;;;   (grammar-rules g)			its rules and its ancestors', nearest first, an overridden one once
;;;   (grammar-rules-base-first g)	the same rules, the base's first in their order, each grammar's own after them
;;;   (grammar-rule g name)		the nearest rule of that name
;;;   (grammar-all-fields g)		its fields and its ancestors', the base's first
(define-structure <grammar> (name type parent fields rules scope))	; parent: a <grammar>, or () above the grammars
(define-structure <grammar-rule> (name parameters body annotations))
(define-structure <grammar-scope> (grammars parent))	; grammars: ((name . <grammar>) ...)
(define-method do-print <grammar> () (print "<grammar " self.name ">"))
(define-method do-print <grammar-rule> () (print "<rule " self.name ">"))
(define *grammar-root* (make <grammar-scope>))
(define *grammars* (array))	; type -> <grammar>, for tpeg's
(define-function grammar-scope (parent) (make <grammar-scope> parent: parent))

(define-function grammar-of (type) (and (long? type) (array-at *grammars* type)))
(define-function grammar-named (name . scope)
  (let ((s (if scope (car scope) *grammar-root*)) (found ()))
    (while (and s (not found)) (set found (cdr (assq name (<grammar-scope>-grammars s)))) (set s (<grammar-scope>-parent s)))
    found))
(define-function grammar-parent (g) (<grammar>-parent g))
(define-function grammar-own-fields (type)	; the fields type adds to its base's
  (let ((fs (array-at %structure-fields type)) (base (array-at %structure-bases type)))
    (and base (for (i 0 (list-length (array-at %structure-fields base))) (set fs (cdr fs))))
    fs))
(define-function grammar-type-parent (type)	; the nearest registered grammar among type's bases
  (let ((b (array-at %structure-bases type)) (found ()))
    (while (and b (not found)) (set found (grammar-of b)) (set b (array-at %structure-bases b)))
    found))
(define-function grammar-rule-of (r)	; a parsed rule, (name body parameters annotations), as a <grammar-rule>
  (make <grammar-rule> name: (car r) body: (cadr r) parameters: (caddr r) annotations: (cadddr r)))
(define-function grammar-add-rules (g rules)	; added, or replacing those of their names in their places
  (list-do r rules
    (let ((rule (grammar-rule-of r)) (done ()) (rs (<grammar>-rules g)))
      (while rs (when (= (<grammar-rule>-name (car rs)) (car r)) (set-car rs rule) (set done 1)) (set rs (cdr rs)))
      (or done (set (<grammar>-rules g) (concat-list (<grammar>-rules g) (list rule))))))
  g)
(define-function grammar-enter (scope g) (set (<grammar-scope>-grammars scope) (cons (cons (<grammar>-name g) g) (<grammar-scope>-grammars scope))) g)
(define-function grammar-register (name type rules)	; a tpeg grammar's rules, in the root
  (let ((g (or (grammar-of type)
	       (grammar-enter *grammar-root* (set-array-at *grammars* type
							   (make <grammar> name: name type: type parent: (grammar-type-parent type)
								 fields: (grammar-own-fields type) rules: () scope: *grammar-root*))))))
    (grammar-add-rules g rules)))
(define-function grammar-define-in (scope name parent fields rules)	; a grammar of scope's, its parent named (or ())
  (let ((p (and parent (or (grammar-named parent scope) (error "grammar " name ": no grammar " parent)))))
    (grammar-add-rules (grammar-enter scope (make <grammar> name: name parent: p fields: fields rules: () scope: scope)) rules)))

(define-function grammar-rules (g)
  (let ((out ()) (seen ()))
    (while g
      (list-do r (<grammar>-rules g)
	(unless (memq (<grammar-rule>-name r) seen) (push seen (<grammar-rule>-name r)) (push out r)))
      (set g (grammar-parent g)))
    (list-reverse! out)))
(define-function grammar-rules-base-first (g)
  (if (not g) ()
    (let ((out ()) (own (map (lambda (r) (<grammar-rule>-name r)) (<grammar>-rules g))))
      (list-do r (grammar-rules-base-first (grammar-parent g)) (or (memq (<grammar-rule>-name r) own) (push out r)))
      (concat-list (list-reverse! out) (<grammar>-rules g)))))
(define-function grammar-rule (g name)
  (let ((found ()))
    (while (and g (not found))
      (list-do r (<grammar>-rules g) (and (not found) (= name (<grammar-rule>-name r)) (set found r)))
      (set g (grammar-parent g)))
    found))
(define-function grammar-all-fields (g) (if g (concat-list (grammar-all-fields (grammar-parent g)) (<grammar>-fields g)) ()))
