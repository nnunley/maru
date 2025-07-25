;;; emit-c-threaded-final.l -- Final Two-Pass Threaded C Backend
;;;
;;; Complete implementation with proper forward declarations and dependency handling

(load "emit-c-threaded-fixed.l")

;;; Helper functions
(define-function reverse (lst)
  "Reverse a list"
  (let ((result ()))
    (while lst
      (set result (cons (car lst) result))
      (set lst (cdr lst)))
    result))

(define-function equal? (a b)
  "Test equality"
  (= a b))

(define-function member? (item lst)
  "Test membership in list"
  (if lst
      (if (equal? item (car lst))
          1
          (member? item (cdr lst)))
      ()))

;;; Global compilation state
(define *thread-functions* ())      ; List of all thread function definitions
(define *current-output* ())        ; Current output buffer
(define *string-pool* ())          ; String literal pool
(define *pending-threads* ())       ; Threads referenced but not yet defined

;;; Output buffering
(define-function start-output-buffer ()
  "Start capturing output to buffer"
  (set *current-output* ()))

(define-function emit-to-buffer items
  "Emit items to current buffer"
  (list-do item items
    (set *current-output* (cons item *current-output*))))

(define-function flush-output-buffer ()
  "Get buffered output as list"
  (reverse *current-output*))

;;; Thread function recording
(define-structure <thread-function> (name body refs))

(define-function record-thread-function (name body-generator)
  "Record a thread function for later output"
  (let ((func (new <thread-function>)))
    (set (<thread-function>-name func) name)
    (set (<thread-function>-body func) body-generator)
    (set (<thread-function>-refs func) ())
    (set *thread-functions* (cons func *thread-functions*))
    func))

(define-function add-thread-reference (from-thread to-thread)
  "Record that from-thread references to-thread"
  (let ((from-func (find-thread-function from-thread)))
    (if from-func
        (set (<thread-function>-refs from-func)
             (cons to-thread (<thread-function>-refs from-func)))
        (set *pending-threads* (cons (cons from-thread to-thread) *pending-threads*)))))

(define-function find-thread-function (name)
  "Find thread function by name"
  (find-in-list (lambda (func) (equal? (<thread-function>-name func) name))
                *thread-functions*))

(define-function find-in-list (pred lst)
  "Find first element matching predicate"
  (if lst
      (if (pred (car lst))
          (car lst)
          (find-in-list pred (cdr lst)))
      ()))

;;; Enhanced thread generators that record functions

(define-function c-gen-threaded-literal-final (value next)
  "Generate literal thread with recording"
  (let ((thread-name (c-fresh-thread)))
    (record-thread-function thread-name
      (lambda ()
        (print "oop ") (print thread-name) (println "(thread_context *ctx) {")
        (print "    ctx->acc = ")
        (if (long? value)
            (print "LONG(" value ")")
            (print "nil"))
        (println ";")
        (print "    return ") (print next) (println "(ctx);")
        (println "}")))
    (add-thread-reference thread-name next)
    thread-name))

(define-function c-gen-threaded-binop-final (op-str left right next)
  "Generate binary operation thread with recording"
  (let ((thread-name (c-fresh-thread)))
    (record-thread-function thread-name
      (lambda ()
        (print "oop ") (print thread-name) (println "(thread_context *ctx) {")
        (if (and (long? left) (long? right))
            (let ()
              (print "    ctx->acc = LONG(") (print left) (print " ") 
              (print op-str) (print " ") (print right) (println ");"))
            (let ()
              (print "    oop left = ")
              (if (long? left)
                  (print "LONG(" left ")")
                  (print left "(ctx)"))
              (println ";")
              (print "    oop right = ")
              (if (long? right)
                  (print "LONG(" right ")")
                  (print right "(ctx)"))
              (println ";")
              (print "    ctx->acc = LONG(getLong(left) ") (print op-str) 
              (println " getLong(right));")))
        (print "    return ") (print next) (println "(ctx);")
        (println "}")))
    (add-thread-reference thread-name next)
    thread-name))

(define-function c-gen-threaded-variable-final (var-name next)
  "Generate variable reference thread with recording"
  (let ((thread-name (c-fresh-thread)))
    (record-thread-function thread-name
      (lambda ()
        (print "oop ") (print thread-name) (println "(thread_context *ctx) {")
        (print "    ctx->acc = env_lookup(ctx->env, intern(\"")
        (print var-name) (println "\"));")
        (print "    return ") (print next) (println "(ctx);")
        (println "}")))
    (add-thread-reference thread-name next)
    thread-name))

(define-function c-gen-threaded-if-final (test-thread then-thread else-thread next)
  "Generate if thread with recording"
  (let ((thread-name (c-fresh-thread)))
    (record-thread-function thread-name
      (lambda ()
        (print "oop ") (print thread-name) (println "(thread_context *ctx) {")
        (print "    oop test = ") (print test-thread) (println "(ctx);")
        (println "    if (test != nil && test != false_value) {")
        (print "        return ") (print then-thread) (println "(ctx);")
        (println "    } else {")
        (print "        return ") (print else-thread) (println "(ctx);")
        (println "    }")
        (println "}")))
    (add-thread-reference thread-name test-thread)
    (add-thread-reference thread-name then-thread)
    (add-thread-reference thread-name else-thread)
    thread-name))

(define-function c-gen-threaded-return-final ()
  "Generate return thread with recording"
  (let ((thread-name (c-fresh-thread)))
    (record-thread-function thread-name
      (lambda ()
        (print "oop ") (print thread-name) (println "(thread_context *ctx) {")
        (println "    return ctx->acc;")
        (println "}")))
    thread-name))

;;; Expression compiler using final thread generators

(define-function c-gen-expr-final (expr next)
  "Compile expression to threaded code with recording"
  (cond
    ((long? expr)
     (c-gen-threaded-literal-final expr next))
    
    ((symbol? expr)
     (c-gen-threaded-variable-final expr next))
    
    ((pair? expr)
     (let ((op (car expr)))
       (cond
         ((= op '+) 
          (compile-binop-final expr "+" next))
         ((= op '-) 
          (compile-binop-final expr "-" next))
         ((= op '*) 
          (compile-binop-final expr "*" next))
         ((= op '/) 
          (compile-binop-final expr "/" next))
         
         ((= op 'if)
          (let* ((test (cadr expr))
                 (then-expr (caddr expr))
                 (else-expr (if (cdddr expr) (cadddr expr) 'nil))
                 (cont-thread (c-gen-threaded-return-final))
                 (then-thread (c-gen-expr-final then-expr cont-thread))
                 (else-thread (c-gen-expr-final else-expr cont-thread))
                 (test-thread (c-gen-expr-final test "thread_dummy")))
            (c-gen-threaded-if-final test-thread then-thread else-thread next)))
         
         (else
          (error "Unsupported operation: " op)))))
    
    (else
     (error "Unsupported expression type"))))

(define-function compile-binop-final (expr op-str next)
  "Compile binary operation"
  (let ((left (cadr expr))
        (right (caddr expr)))
    (if (and (long? left) (long? right))
        ;; Both operands are constants
        (c-gen-threaded-binop-final op-str left right next)
        ;; Need to evaluate operands
        (let* ((right-thread (if (long? right)
                                right
                                (c-gen-expr-final right "thread_cont")))
               (left-thread (if (long? left)
                               left
                               (c-gen-expr-final left "thread_cont"))))
          (c-gen-threaded-binop-final op-str left-thread right-thread next)))))

;;; Topological sort for output ordering

(define-function compute-output-order ()
  "Compute order for outputting thread functions"
  (let ((ordered ())
        (visited ())
        (in-progress ()))
    
    (define-function visit (name)
      (cond
        ((member? name visited) 
         ())  ; Already processed
        
        ((member? name in-progress)
         (println "Warning: Circular dependency detected for " name))
        
        (else
         (let ((func (find-thread-function name)))
           (if func
               (let ()
                 (set in-progress (cons name in-progress))
                 ;; Visit dependencies first
                 (list-do ref (<thread-function>-refs func)
                   (visit ref))
                 (set in-progress (remove-from-list name in-progress))
                 (set visited (cons name visited))
                 (set ordered (cons func ordered))))))))
    
    ;; Visit all functions
    (list-do func *thread-functions*
      (visit (<thread-function>-name func)))
    
    ordered))

(define-function remove-from-list (item lst)
  "Remove item from list"
  (if lst
      (if (equal? item (car lst))
          (cdr lst)
          (cons (car lst) (remove-from-list item (cdr lst))))
      ()))

;;; Main compilation function

(define-function compile-threaded-final (expr)
  "Compile expression with proper forward declarations"
  
  ;; Reset global state
  (set *thread-functions* ())
  (set *pending-threads* ())
  (set *c-thread-counter* 0)
  
  ;; Generate header
  (println "/* Generated by Two-Pass Threaded C Compiler */")
  (println "#include <stdio.h>")
  (println "#include <stdlib.h>")
  (println)
  (generate-threaded-c-header)
  
  ;; Generate minimal runtime
  (println "/* Runtime support */")
  (println "oop false_value = (oop)0x0A;")
  (println "oop true_value = (oop)0x1A;")
  (println)
  (println "typedef struct Env {")
  (println "    struct Env *parent;")
  (println "    oop *names;")
  (println "    oop *values;")
  (println "    int size;")
  (println "} Env;")
  (println)
  (println "oop env_lookup(Env *env, oop name) { return nil; }")
  (println "oop intern(char *str) { return (oop)str; }")
  (println)
  
  ;; Compile the expression
  (let* ((ret-thread (c-gen-threaded-return-final))
         (main-thread (c-gen-expr-final expr ret-thread)))
    
    ;; Sort functions by dependency order
    (let ((sorted-funcs (compute-output-order)))
      
      ;; Generate forward declarations
      (println "/* Forward declarations */")
      (list-do func sorted-funcs
        (print "oop ") (print (<thread-function>-name func)) 
        (println "(thread_context *ctx);"))
      (println)
      
      ;; Generate implementations
      (println "/* Thread implementations */")
      (list-do func sorted-funcs
        ((<thread-function>-body func))
        (println))
      
      ;; Generate main function
      (println "int main() {")
      (println "    thread_context ctx = {0};")
      (println "    ctx.sp = ctx.stack;")
      (println "    ctx.env = NULL;")
      (println)
      (print "    oop result = ") (print main-thread) (println "(&ctx);")
      (println "    printf(\"Result: %ld\\n\", is_long(result) ? getLong(result) : -1);")
      (println "    return 0;")
      (println "}"))))

;;; Test the final implementation

(define-function test-final-compilation ()
  "Test final two-pass compilation"
  (println "=== Testing Final Two-Pass Compilation ===")
  (println)
  
  ;; Test 1: Simple arithmetic
  (println "Test 1: (+ 40 2)")
  (compile-threaded-final '(+ 40 2))
  (println)
  
  ;; Test 2: Nested operations
  (println "Test 2: (* (+ 10 5) 2)")
  (set *thread-functions* ())
  (set *c-thread-counter* 0)
  (compile-threaded-final '(* (+ 10 5) 2))
  (println)
  
  ;; Test 3: Conditional
  (println "Test 3: (if (+ 1 1) 42 0)")
  (set *thread-functions* ())
  (set *c-thread-counter* 0)
  (compile-threaded-final '(if (+ 1 1) 42 0)))

(println "emit-c-threaded-final.l loaded")