(println "1. Starting IR test...")

(define-structure <ir-node> (type))
(println "2. ir-node defined")

(define-structure <ir-literal> (type value))
(println "3. ir-literal defined")

(define-function make-ir-literal (value)
  (println "  Making literal for: " value)
  (let ((node (new <ir-literal>)))
    (set (<ir-literal>-type node) 'literal)
    (set (<ir-literal>-value node) value)
    (println "  Created: " node)
    node))

(println "4. Testing literal creation...")
(let ((lit (make-ir-literal 42)))
  (println "  Type: " (<ir-literal>-type lit))
  (println "  Value: " (<ir-literal>-value lit)))

(println "5. Done")