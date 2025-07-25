;;; jit-poc-simple.l - Simplified JIT PoC that works with basic Maru
;;;
;;; This version uses only functions available in boot.l

(define *jit-temp-dir* "/tmp/maru-jit")

;; Define system function
(define system (extern 'system))

;; Convert number to string (simple version for demo)
(define-function number->string (n)
  (let ((buf (array 20))
        (i 0)
        (negative (< n 0)))
    (if negative (set n (- 0 n)))
    (if (= n 0)
        "0"
        (let ()
          ;; Extract digits
          (while (> n 0)
            (set (array-at buf i) (+ ?0 (% n 10)))
            (set n (/ n 10))
            (set i (+ i 1)))
          ;; Add negative sign if needed
          (if negative
              (let ()
                (set (array-at buf i) ?-)
                (set i (+ i 1))))
          ;; Reverse and convert to string
          (let ((result (array i))
                (j 0))
            (while (> i 0)
              (set i (- i 1))
              (set (array-at result j) (array-at buf i))
              (set j (+ j 1)))
            (array->string result))))))

;;; Simple assembly generation

(define-function write-line (str port)
  "Write a line to a port"
  (let ((len (string-length str)))
    (for (i 0 len)
      (write-byte (string-at str i) port)))
  (write-byte 10 port))  ; newline

(define-function emit-arm64-return-42 (port)
  "Emit ARM64 assembly to return 42"
  (write-line ".global _maru_jit_fn" port)
  (write-line ".align 2" port)
  (write-line "_maru_jit_fn:" port)
  (write-line "    mov x0, #42" port)
  (write-line "    ret" port))

;;; File operations

(define-function write-asm-file (filename)
  "Write assembly file"
  (let ((port (open-output-file filename)))
    (emit-arm64-return-42 port)
    (close-output-port port)))

;;; Compile and load

(define-function compile-simple-function ()
  "Compile a simple function that returns 42"
  (let ((asm-file (concat-string *jit-temp-dir* "/simple.s"))
        (obj-file (concat-string *jit-temp-dir* "/simple.o"))
        (dylib-file (concat-string *jit-temp-dir* "/simple.dylib")))
    
    ;; Create directory
    (system (concat-string "mkdir -p " *jit-temp-dir*))
    
    ;; Write assembly file
    (write-asm-file asm-file)
    (println (concat-string "Generated: " asm-file))
    
    ;; Assemble
    (let ((cmd (concat-string "as -arch arm64 -o " obj-file " " asm-file)))
      (println (concat-string "Assembling: " cmd))
      (system cmd))
    
    ;; Link
    (let ((cmd (concat-string "ld -arch arm64 -dylib -o " dylib-file " " obj-file 
                              " -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path`")))
      (println (concat-string "Linking: " cmd))
      (system cmd))
    
    (println (concat-string "Created: " dylib-file))
    dylib-file))

;;; dlopen interface

(define dlopen (extern 'dlopen))
(define dlsym (extern 'dlsym))
(define dlclose (extern 'dlclose))
(define dlerror (extern 'dlerror))

(define RTLD_NOW 2)

(define-function load-and-test ()
  "Load the compiled library and test it"
  (let* ((dylib-path (compile-simple-function))
         (handle (dlopen dylib-path RTLD_NOW)))
    (if handle
        (let ()
          (println "Library loaded successfully")
          (let ((fn-ptr (dlsym handle "_maru_jit_fn")))
            (if fn-ptr
                (let ()
                  (println "Found function symbol")
                  ;; In a real implementation, we'd call the function
                  ;; For now, just show we can load it
                  (println "SUCCESS: JIT compilation and loading works!")
                  (dlclose handle))
                (println "ERROR: Could not find symbol"))))
        (println "ERROR: Could not load library"))))

;;; Test

(println "=== Maru JIT Proof of Concept ===")
(println "This demonstrates compiling and loading native code")
(load-and-test)