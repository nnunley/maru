;;; eval-introspection.l - Introspect the eval environment

(println "=== Eval Introspection ===")
(println)

;; Let's check what eval itself tells us
(println "1. Basic eval test:")
(println (format "  (eval 'car) = %s" (eval 'car)))
(println (format "  (eval '(+ 1 2)) = %s" (eval '(+ 1 2))))

(println "\n2. Checking eval's behavior with undefined symbols:")
(define result (catch 'error
  (lambda () (eval 'system))
  (lambda (err) (format "Error: %s" err))))
(println (format "  (eval 'system) = %s" result))

(println "\n3. What happens when we load eval.l?")
(println "  eval.l defines externs like malloc, system, etc.")
(println "  But it requires other files like osdefs.k")

(println "\n4. Available in basic eval:")
(println "  File I/O:")
(println "    - open-input-file, open-output-file")
(println "    - close-input-port, close-output-port")  
(println "    - read-byte, write-byte")
(println "    - putc, getc")

(println "\n5. Can we define our own 'system'?")
(define-function make-asm-file (name)
  (let ((filename (concat-string "/tmp/" name ".s"))
        (port (open-output-file filename)))
    ;; Write assembly using putc
    (define (puts str port)
      (let ((len (string-length str)))
        (for (i 0 len)
          (putc (string-at str i) port))))
    
    (puts ".global _test_fn\n" port)
    (puts ".align 2\n" port)
    (puts "_test_fn:\n" port)
    (puts "    mov x0, #42\n" port)
    (puts "    ret\n" port)
    
    (close-output-port port)
    filename))

(println "\n6. Demonstration:")
(let ((asm-file (make-asm-file "test_asm")))
  (println (format "  Created: %s" asm-file))
  (println "  To compile: as -o test.o test_asm.s")
  (println "  To link: ld -dylib -o test.dylib test.o"))

(println "\n7. Summary:")
(println "  - Basic eval has file I/O but no system/dlopen")
(println "  - eval.l adds FFI capabilities via extern")
(println "  - We can generate files but not execute commands")
(println "  - Need eval+emit.l for full JIT capability")

;; Exit cleanly
(println "\nDone.")