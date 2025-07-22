;;; compile-arm64.l -- ARM64 compilation pipeline
;;; Generates assembly, invokes assembler, and produces executable

(require "ir2.k")
(load "core/compiler/ir-gen-arm64-fixed.k")

(define-function shell-command (cmd)
  "Execute a shell command and return exit status"
  (let ((result (system cmd)))
    (if (= 0 result)
        't
      (error "Command failed: " cmd " (exit code: " result ")"))))

(define-function compile-arm64-assembly (asm-file obj-file)
  "Compile ARM64 assembly to object file"
  ;; Use clang as assembler for better compatibility on macOS
  (shell-command (concat-string "clang -c -o " obj-file " " asm-file)))

(define-function link-arm64-executable (obj-file exe-file)
  "Link object file to executable"
  ;; Link with system libraries on macOS
  (shell-command (concat-string "clang -o " exe-file " " obj-file)))

(define-function compile-ir-to-executable (ir output-name)
  "Complete compilation pipeline from IR to executable"
  (let ((asm-file (concat-string output-name ".s"))
        (obj-file (concat-string output-name ".o")))
    
    ;; Step 1: Generate assembly
    (println "Generating ARM64 assembly...")
    (let ((asm-code (ir-gen ir))
          (port (output-stream-open asm-file)))
      ;; Add assembler directives for macOS
      (println port "	.section	__TEXT,__text,regular,pure_instructions")
      (println port "	.build_version macos, 11, 0")
      (println port "	.p2align	2")
      (println port "")
      ;; Output the generated assembly
      (print port asm-code)
      (output-stream-close port)
      (println "  -> " asm-file))
    
    ;; Step 2: Assemble
    (println "Assembling...")
    (compile-arm64-assembly asm-file obj-file)
    (println "  -> " obj-file)
    
    ;; Step 3: Link
    (println "Linking...")
    (link-arm64-executable obj-file output-name)
    (println "  -> " output-name)
    
    ;; Clean up intermediate files (optional)
    ;; (shell-command (concat-string "rm " asm-file " " obj-file))
    
    (println "Done! Executable: " output-name)))

;;; Test compilation function
(define-function compile-test-program ()
  "Compile a simple test program"
  (let ((module (make <ir-module>)))
    
    ;; Create main function
    (let* ((func (make <ir-function>))
           ;; Simple function that returns 42
           (lit-42 (make <ir-lit> (type IR-INT32) (value 42)))
           (ret (make <ir-return> (value lit-42))))
      
      (set (<ir-function>-name func) 'main)
      (set (<ir-function>-export func) '_main)  ; macOS requires underscore
      (set (<ir-function>-parameters func) ())
      (set (<ir-function>-body func) ret)
      (set (<ir-function>-frame-size func) 0)
      
      (set (<ir-module>-functions module) (list func)))
    
    ;; Compile it
    (compile-ir-to-executable module "test-program")))

;;; Helper to compile Lisp-like source to IR (stub for now)
(define-function compile-source (source-file output-name)
  "Compile source file to executable (needs IR translation)"
  (error "Source to IR compilation not yet implemented"))

;; Export main compilation function
(define compile-arm64 compile-ir-to-executable)