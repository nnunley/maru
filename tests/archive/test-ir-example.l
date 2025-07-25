;; Example of using the IR system to compile a simple function

(load "boot.l")
(load "core/compiler/ir.k")

;; Create an IR context
(define *ir* (ir-new <ir> ()))

;; Define a simple add function: (lambda (a b) (+ a b))
(define add-function
  (ir-fun 'add 
    (ir-function-type *ir* IR-INT (list IR-INT IR-INT))
    (list
      (ir-arg 'a IR-INT)
      (ir-arg 'b IR-INT)
      (ir-ret (ir-add (ir-get 'a) (ir-get 'b))))))

;; Add the function to the IR program
(ir-put *ir* add-function)

;; Type check the IR
(ir-typecheck *ir*)

;; Generate C code
(println ";; Generated C code:")
(ir-gen-c add-function *ir*)
(println)

;; The same IR could be used to generate x86 or ARM64 assembly
;; by using ir-gen-x86 or ir-gen-arm64 instead