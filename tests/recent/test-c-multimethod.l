;; Test the multimethod C backend approach
(require "core/compiler/emit.l")

;; Set up a string port to capture output
(define test-port (string-port))
(set *emit-output-port* test-port)

;; First, let's define the backend variable if it doesn't exist
(or (defined? '*emit-backend*) (define *emit-backend* ()))

;; Test with assembly backend (default)
(println "Test 1: Assembly backend (default)")
(set *emit-backend* 'asm)
(let ((comp (compiler 0)))
  ;; Generate: if (5) then 10 else 20
  (gen-if '(if 5 10 20) comp)
  ;; Generate some instructions to see output
  (for (i 0 (<compiler>-pc comp))
    (let ((insn (array-at (<compiler>-asm comp) i)))
      (println "  Instruction: " insn))))

;; Now load the multimethod C backend
(load "core/compiler/emit-c-multimethod.l")

;; Test with C backend
(println "\nTest 2: C backend")
(set *emit-backend* 'c)
(set (port-contents test-port) ()) ; Clear port
(let ((comp (compiler 0)))
  ;; Generate: if (5) then 10 else 20
  (gen-if '(if 5 10 20) comp))

(println "Generated C code:")
(println (port-contents test-port))

;; Test a while loop
(println "\nTest 3: C while loop")
(set (port-contents test-port) ()) ; Clear port
(let ((comp (compiler 0)))
  ;; Generate: while (x) x = x - 1
  (gen-while '(while x (set x (- x 1))) comp))

(println "Generated C code:")
(println (port-contents test-port))