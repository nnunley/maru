;;; test-arm64-ir-gen.l -- Test the fixed ARM64 IR generator

(load "core/compiler/ir2.k")
(load "core/compiler/ir-gen-arm64-fixed.k")

;; Create a simple IR module to test
(let ((module (make <ir-module>)))
  
  ;; Add a global variable
  (let ((global-x (make <ir-variable> (name 'x))))
    (set (<ir-module>-globals module) (list global-x))
    
    ;; Create a simple function: int add(int a, int b) { return a + b; }
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
      (set (<ir-function>-export func) 'add)
      (set (<ir-function>-parameters func) (list param-a param-b))
      (set (<ir-function>-body func) ret-insn)
      (set (<ir-function>-frame-size func) 0)
      
      ;; Add function to module
      (set (<ir-module>-functions module) (list func))))
  
  ;; Generate ARM64 assembly
  (println ";;; Generated ARM64 Assembly:")
  (println (ir-gen module))
  
  ;; Test another function with more complex operations
  (let* ((func2 (make <ir-function>))
         (param-n (make <ir-parameter> (name 'n) (type IR-INT64)))
         ;; if (n < 2) return n; else return fib(n-1) + fib(n-2);
         (lit-2 (make <ir-lit> (type IR-INT64) (value 2)))
         (test (make <ir-lt>
                 (type IR-INT32)
                 (operand-l (make <ir-get> (type IR-INT64) (location param-n)))
                 (operand-r lit-2)))
         (then-branch (make <ir-return> 
                        (value (make <ir-get> (type IR-INT64) (location param-n)))))
         (else-branch (make <ir-return>
                        (value (make <ir-lit> (type IR-INT64) (value 0)))))
         (if-stmt (make <ir-if>
                    (test test)
                    (consequent then-branch)
                    (alternate else-branch))))
    
    (set (<ir-function>-name func2) 'simple_fib)
    (set (<ir-function>-export func2) 'simple_fib)
    (set (<ir-function>-parameters func2) (list param-n))
    (set (<ir-function>-body func2) if-stmt)
    (set (<ir-function>-frame-size func2) 0)
    
    ;; Create new module with this function
    (let ((module2 (make <ir-module>)))
      (set (<ir-module>-functions module2) (list func2))
      (println "\n;;; Generated ARM64 Assembly for simple_fib:")
      (println (ir-gen module2)))))