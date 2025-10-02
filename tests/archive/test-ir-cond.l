(println "Testing cond...")

(define-structure <ir-node> (type))
(define-structure <ir-literal> (type value))

(define-function test-type (node)
  (println "Node: " node)
  (println "Type: " (<ir-node>-type node))
  (cond
    ((= (<ir-node>-type node) 'literal)
     (println "It's a literal!"))
    (else
     (println "Not a literal"))))

(let ((lit (new <ir-literal>)))
  (set (<ir-literal>-type lit) 'literal)
  (set (<ir-literal>-value lit) 42)
  (test-type lit))

(println "Done")