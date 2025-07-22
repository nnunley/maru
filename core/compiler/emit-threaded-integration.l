;;; emit-threaded-integration.l -- Integration layer for threaded C backend
;;;
;;; This transforms the compiler's instruction stream into threaded execution

(require "core/compiler/emit-c-threaded.l")

;;; Thread generation state
(define *thread-counter* 0)
(define *thread-functions* ())  ; List of generated thread functions
(define *thread-labels* ())     ; Label -> thread name mapping

(define-function fresh-thread-name ()
  (concat-string "thread_" (long->string (set *thread-counter* (+ *thread-counter* 1)))))

;;; Transform emit instructions to threaded code
(define-function emit-to-thread (insn)
  "Transform an emit instruction to threaded code"
  (let ((op (car insn))
        (args (cdr insn)))
    (cond
      ;; Control flow
      ((= op BR)
       (let ((label (car args)))
         `(BR ,(or (cdr (assq label *thread-labels*))
                   (let ((tname (fresh-thread-name)))
                     (set *thread-labels* (cons (cons label tname) *thread-labels*))
                     tname)))))
      
      ((= op BF)
       (let ((label (car args)))
         `(BF ,(or (cdr (assq label *thread-labels*))
                   (let ((tname (fresh-thread-name)))
                     (set *thread-labels* (cons (cons label tname) *thread-labels*))
                     tname)))))
      
      ((= op BT)
       (let ((label (car args)))
         `(BT ,(or (cdr (assq label *thread-labels*))
                   (let ((tname (fresh-thread-name)))
                     (set *thread-labels* (cons (cons label tname) *thread-labels*))
                     tname)))))
      
      ;; Labels become thread entry points
      ((= op DEFLABEL)
       (let* ((label (car args))
              (tname (or (cdr (assq label *thread-labels*))
                        (let ((name (fresh-thread-name)))
                          (set *thread-labels* (cons (cons label name) *thread-labels*))
                          name))))
         `(DEFTHREAD ,tname)))
      
      ;; Pass through other instructions
      (else insn))))

;;; Generate threaded code for a function
(define-function gen-threaded-function (name params body comp)
  "Generate threaded C code for a function"
  (let ((thread-name (concat-string "thread_" (symbol->string name)))
        (instructions ())
        (current-thread ())
        (threads ()))
    
    ;; Transform instructions to threaded form
    (let ((i 0))
      (while (< i (<compiler>-pc comp))
        (let ((insn (array-at (<compiler>-asm comp) i)))
          (set instructions (cons (emit-to-thread insn) instructions)))
        (set i (+ i 1))))
    (set instructions (reverse instructions))
    
    ;; Generate thread functions
    (println "/* Threaded function: " name " */")
    (println)
    
    ;; Generate individual threads
    (let ((current-thread-insns ())
          (current-thread-name ()))
      (list-do insn instructions
        (if (and (pair? insn) (= (car insn) 'DEFTHREAD))
            ;; Start new thread
            (let ()
              (and current-thread-name
                   (gen-thread-function current-thread-name (reverse current-thread-insns)))
              (set current-thread-name (cadr insn))
              (set current-thread-insns ()))
          ;; Add instruction to current thread
          (set current-thread-insns (cons insn current-thread-insns))))
      ;; Generate final thread
      (and current-thread-name
           (gen-thread-function current-thread-name (reverse current-thread-insns))))
    
    ;; Generate main function wrapper
    (print "oop " (c-mangle-label name) "(")
    (if params
        (let ((first 't))
          (list-do param params
            (if first (set first ()) (print ", "))
            (print "oop " (symbol->string param))))
      (print "void"))
    (println ") {")
    (println "    thread_context ctx = {0};")
    (println "    ctx.sp = ctx.stack;")
    ;; Push parameters onto stack in reverse order
    (let ((params-rev (reverse params)))
      (list-do param params-rev
        (println "    PUSH(&ctx, " (symbol->string param) ");")))
    ;; Start execution at first thread
    (println "    return " (or (car (car *thread-labels*)) "thread_entry") "(&ctx);")
    (println "}")
    (println)))

;;; Generate a single thread function
(define-function gen-thread-function (name instructions)
  "Generate C code for a single thread"
  (println "static oop " name "(thread_context *ctx) {")
  
  ;; Generate code for each instruction
  (list-do insn instructions
    (if (pair? insn)
        (let ((op (car insn))
              (args (cdr insn)))
          (cond
            ;; Arithmetic operations
            ((= op ADD)
             (println "    ctx->acc = LONG(getLong(ctx->acc) + getLong(POP(ctx)));"))
            ((= op SUB)
             (println "    ctx->acc = LONG(getLong(ctx->acc) - getLong(POP(ctx)));"))
            ((= op MUL)
             (println "    ctx->acc = LONG(getLong(ctx->acc) * getLong(POP(ctx)));"))
            ((= op DIV)
             (println "    ctx->acc = LONG(getLong(ctx->acc) / getLong(POP(ctx)));"))
            
            ;; Load/Store
            ((= op LOAD)
             (let ((arg (car args)))
               (cond
                 ((LI32? arg)
                  (println "    ctx->acc = LONG(" (<LI32>-value arg) ");"))
                 ((TI32? arg)
                  (println "    ctx->acc = ctx->locals[" (>> (<TI32>-offset arg) 2) "];"))
                 (else
                  (println "    ctx->acc = " arg ";")))))
            
            ((= op STORE)
             (let ((arg (car args)))
               (if (TI32? arg)
                   (println "    ctx->locals[" (>> (<TI32>-offset arg) 2) "] = ctx->acc;")
                 (println "    /* STORE to " arg " */"))))
            
            ;; Control flow
            ((= op BR)
             (println "    return " (car args) "(ctx);"))
            ((= op BT)
             (println "    if (ctx->acc != nil) return " (car args) "(ctx);"))
            ((= op BF)
             (println "    if (ctx->acc == nil) return " (car args) "(ctx);"))
            
            ;; Function calls
            ((= op CALL)
             (println "    /* CALL " (car args) " */")
             (println "    ctx->acc = ((oop (*)(thread_context*))ctx->acc)(ctx);"))
            
            ;; Stack operations
            ((= op MOVE)
             (println "    PUSH(ctx, POP(ctx));"))
            
            ;; Default
            (else
             (println "    /* " op " */"))))))
  
  ;; Default: continue to next thread (should be explicit)
  (println "    return ctx->acc;")
  (println "}")
  (println))

;;; Override gen-definition for threaded mode
(define-method gen-definition-threaded <expr> (name ocomp)
  (let* ((defn (<expr>-defn self))
         (params (map (lambda (v) (<variable>-name v)) (cadr defn)))
         (body (cddr defn))
         (comp (compiler (+ 1 (<compiler>-level ocomp)))))
    
    ;; Generate body
    (list-do e body (gen e comp))
    
    ;; Generate threaded function
    (gen-threaded-function name params body comp)))

;;; Integration with gen-env
(define-function gen-env-threaded (env)
  "Generate threaded C code for an environment"
  (generate-threaded-c-header)
  
  ;; Reset state
  (set *thread-counter* 0)
  (set *thread-functions* ())
  (set *thread-labels* ())
  
  ;; Generate definitions
  (let* ((vars  (<env>-bindings env))
         (comp  (compiler 0))
         (index (array-length vars)))
    (while (<= 0 (set index (- index 1)))
      (let ((name  (<variable>-name  (array-at vars index)))
            (value (<variable>-value (array-at vars index))))
        (if (= <expr> (type-of value))
            (gen-definition-threaded value name comp)
          (println "/* Non-function definition: " name " */")))))
  
  ;; Generate test main if needed
  (if (member 'test-main (map (lambda (v) (<variable>-name v)) 
                              (array->list (<env>-bindings env))))
      (let ()
        (println)
        (println "int main() {")
        (println "    oop result = test_main();")
        (println "    printf(\"Result: %ld\\n\", getLong(result));")
        (println "    return 0;")
        (println "}"))))

(define-function LI32? (obj) (= <LI32> (type-of obj)))
(define-function TI32? (obj) (= <TI32> (type-of obj)))