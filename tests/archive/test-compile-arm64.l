;;; test-compile-arm64.l -- Test ARM64 compilation pipeline

;; Create necessary symlinks for file loading
(define-function ensure-symlinks ()
  (system "ln -sf core/osdefs.k osdefs.k 2>/dev/null")
  (system "ln -sf lib/port.l port.l 2>/dev/null"))

(ensure-symlinks)

;; Load the compilation pipeline
(load "core/compiler/compile-arm64.l")

;; Test 1: Compile a simple "return 42" program
(println "=== Test 1: Simple return 42 ===")
(compile-test-program)

;; Test 2: Compile a more complex program
(println "\n=== Test 2: Hello World program ===")

(let ((module (make <ir-module>)))
  ;; We need to create a proper hello world that calls write() syscall
  ;; For now, let's create a function that adds two numbers
  (let* ((func (make <ir-function>))
         (param-a (make <ir-parameter> (name 'a) (type IR-INT32)))
         (param-b (make <ir-parameter> (name 'b) (type IR-INT32)))
         (add-insn (make <ir-add>
                     (type IR-INT32)
                     (operand-l (make <ir-get> 
                                  (type IR-INT32)
                                  (location param-a)))
                     (operand-r (make <ir-get>
                                  (type IR-INT32)
                                  (location param-b)))))
         (ret-insn (make <ir-return> (value add-insn))))
    
    (set (<ir-function>-name func) 'add_numbers)
    (set (<ir-function>-export func) '_add_numbers)
    (set (<ir-function>-parameters func) (list param-a param-b))
    (set (<ir-function>-body func) ret-insn)
    (set (<ir-function>-frame-size func) 0)
    
    ;; Also create a main function that calls add_numbers
    (let* ((main-func (make <ir-function>))
           (lit-5 (make <ir-lit> (type IR-INT32) (value 5)))
           (lit-7 (make <ir-lit> (type IR-INT32) (value 7)))
           ;; Create a call to add_numbers
           (func-addr (make <ir-global> (name 'add_numbers)))
           (call (make <ir-call>
                   (signature (make <ir-function-type>
                                (ret-type IR-INT32)
                                (arg-types (list IR-INT32 IR-INT32))))
                   (operands (list func-addr lit-5 lit-7))))
           (ret (make <ir-return> (value call))))
      
      (set (<ir-function>-name main-func) 'main)
      (set (<ir-function>-export main-func) '_main)
      (set (<ir-function>-parameters main-func) ())
      (set (<ir-function>-body main-func) ret)
      (set (<ir-function>-frame-size main-func) 0)
      
      (set (<ir-module>-functions module) (list func main-func))))
  
  (compile-ir-to-executable module "test-add"))

(println "\n=== Compilation Complete ===")
(println "Generated files:")
(system "ls -la test-program* test-add* 2>/dev/null")
(println "\nRun the executables:")
(println "  ./test-program  (should return exit code 42)")
(println "  ./test-add      (should return exit code 12 = 5+7)")