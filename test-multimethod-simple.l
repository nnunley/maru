;;; test-multimethod-simple.l - Simple multi-method design demonstration

(define println print)

(println "\n=== Multi-Method Design Demonstration ===\n")

(println "The eval-multimethod.k file implements Maru's evaluator using")
(println "multi-method dispatch instead of switch statements.\n")

(println "Key concepts:")
(println "1. Generic functions define the interface")
(println "2. Methods provide type-specific implementations")
(println "3. Dispatch is automatic based on argument types\n")

(println "Example: (define-generic maru-eval (exp ctx))")
(println "Creates a generic function that dispatches on exp's type\n")

(println "Then each type defines its method:")
(println "- (define-method maru-eval <maru-long> ((ctx ...)) ...)")
(println "- (define-method maru-eval <maru-pair> ((ctx ...)) ...)")
(println "- (define-method maru-eval <maru-symbol> ((ctx ...)) ...)\n")

(println "This achieves:")
(println "- Clean code organization")
(println "- Easy extensibility")
(println "- Type-based dispatch")
(println "- No manual type checking\n")

(println "The design follows Ian Piumarta's vision of")
(println "open, extensible object models!\n")