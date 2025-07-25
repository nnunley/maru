;;; test-compile-arm64-simple.l -- Simple test of ARM64 assembly generation

;; First, let's just test that our IR generator produces valid ARM64 assembly
(load "core/compiler/ir2.k")
(load "core/compiler/ir-gen-arm64-fixed.k")

(println "=== Testing ARM64 Assembly Generation ===\n")

;; Create a simple IR module
(let ((module (make <ir-module>)))
  
  ;; Test 1: Simple function that returns 42
  (let* ((func (make <ir-function>))
         (lit-42 (make <ir-lit> (type IR-INT32) (value 42)))
         (ret (make <ir-return> (value lit-42))))
    
    (set (<ir-function>-name func) 'return_42)
    (set (<ir-function>-export func) '_return_42)
    (set (<ir-function>-parameters func) ())
    (set (<ir-function>-body func) ret)
    (set (<ir-function>-frame-size func) 0)
    
    (set (<ir-module>-functions module) (list func)))
  
  (println "Test 1: Function that returns 42")
  (println "--------------------------------")
  (println (ir-gen module))
  (println))

;; Test 2: Function that adds two parameters
(let ((module (make <ir-module>)))
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
    
    (set (<ir-function>-name func) 'add)
    (set (<ir-function>-export func) '_add)
    (set (<ir-function>-parameters func) (list param-a param-b))
    (set (<ir-function>-body func) ret-insn)
    (set (<ir-function>-frame-size func) 0)
    
    (set (<ir-module>-functions module) (list func)))
  
  (println "Test 2: Function that adds two parameters")
  (println "-----------------------------------------")
  (println (ir-gen module))
  (println))

;; Test 3: Function with conditional
(let ((module (make <ir-module>)))
  (let* ((func (make <ir-function>))
         (param-n (make <ir-parameter> (name 'n) (type IR-INT32)))
         (lit-0 (make <ir-lit> (type IR-INT32) (value 0)))
         (lit-1 (make <ir-lit> (type IR-INT32) (value 1)))
         (lit-neg1 (make <ir-lit> (type IR-INT32) (value -1)))
         
         ;; if (n == 0) return 1; else return -1;
         (test (make <ir-eq>
                 (type IR-INT32)
                 (operand-l (make <ir-get> (type IR-INT32) (location param-n)))
                 (operand-r lit-0)))
         (then-branch (make <ir-return> (value lit-1)))
         (else-branch (make <ir-return> (value lit-neg1)))
         (if-stmt (make <ir-if>
                    (test test)
                    (consequent then-branch)
                    (alternate else-branch))))
    
    (set (<ir-function>-name func) 'check_zero)
    (set (<ir-function>-export func) '_check_zero)
    (set (<ir-function>-parameters func) (list param-n))
    (set (<ir-function>-body func) if-stmt)
    (set (<ir-function>-frame-size func) 0)
    
    (set (<ir-module>-functions module) (list func)))
  
  (println "Test 3: Function with conditional")
  (println "---------------------------------")
  (println (ir-gen module))
  (println))

(println "=== Assembly Generation Complete ===")
(println "\nTo compile these to executables, save the output to .s files")
(println "and use: clang -o program file.s")