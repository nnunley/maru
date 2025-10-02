;;; jit-manual-ffi.l - JIT with manually defined FFI functions
;;; Using the approach from dlopen.k but defined directly

(println "=== Manual FFI JIT Demo ===")
(println)

;; First check if we need to load eval.l to get extern
(if (defined? 'extern)
    (println "extern is available")
    (println "extern is not available - using eval.l approach"))

;; Try to define FFI functions manually using the eval.l pattern
(println "Attempting to define system functions...")

;; Define dlopen/dlsym/system functions
(define %dlopen  (extern "dlopen" dlopen "si"))
(define %dlsym   (extern "dlsym" dlsym "ps"))
(define %dlerror (extern "dlerror" dlerror ""))
(define system   (extern "system" system "s"))
(define unlink   (extern "unlink" unlink "s"))

;; Constants for dlopen
(define RTLD_NOW 2)
(define RTLD_GLOBAL 8) 
(define RTLD_DEFAULT -2)

(define-function compile-and-test ()
  "Generate, compile, and test simple assembly"
  
  ;; Generate assembly file
  (let ((asm-file "/tmp/simple_test.s")
        (dylib-file "/tmp/simple_test.dylib"))
    
    (println "1. Generating assembly...")
    (let ((port (open-output-file asm-file)))
      (println ".section __TEXT,__text,regular,pure_instructions" port)
      (println ".global _simple_function" port)
      (println ".align 2" port)
      (println "_simple_function:" port)
      (println "    mov x0, #123" port)
      (println "    ret" port)
      (close-output-port port))
    
    (println "2. Assembly generated, attempting to compile...")
    
    ;; Try to compile
    (let ((compile-cmd (concat-string "as -arch arm64 -o /tmp/temp.o " asm-file))
          (link-cmd (concat-string "ld -dylib -arch arm64 -o " dylib-file " /tmp/temp.o -lSystem")))
      
      (println (concat-string "   Compile: " compile-cmd))
      (let ((result (system compile-cmd)))
        (println (concat-string "   Result: " (number->string result)))
        
        (if (= result 0)
            (let ()
              (println (concat-string "   Link: " link-cmd))
              (let ((link-result (system link-cmd)))
                (println (concat-string "   Link result: " (number->string link-result)))
                
                (if (= link-result 0)
                    (let ()
                      (println "3. Loading dylib...")
                      (let ((lib (%dlopen dylib-file (| RTLD_NOW RTLD_GLOBAL))))
                        (if (= lib 0)
                            (println (concat-string "   dlopen failed: " (%dlerror)))
                            (let ()
                              (println "4. Looking up symbol...")
                              (let ((sym (%dlsym lib "_simple_function")))
                                (if (= sym 0)
                                    (println "   Symbol not found")
                                    (let ()
                                      (println "5. Creating subr and calling...")
                                      (let ((fn (subr "_simple_function" "")))
                                        (if fn
                                            (let ((result (fn)))
                                              (println (concat-string "   Function returned: " (number->string result))))
                                            (println "   Could not create subr"))))))))))
                    (println "   Link failed"))))
            (println "   Compile failed"))))))

;; Run the test
(compile-and-test)

(println)
(println "=== Demo Complete ===")