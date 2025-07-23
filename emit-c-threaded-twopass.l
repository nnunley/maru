;;; emit-c-threaded-twopass.l -- Two-Pass Threaded C Backend with Forward Declarations
;;;
;;; This version handles circular dependencies by using a two-pass compilation:
;;; Pass 1: Collect all function signatures and generate forward declarations
;;; Pass 2: Generate the actual function implementations

(load "emit-c-threaded-fixed.l")

;;; Global state for two-pass compilation
(define *thread-signatures* ())      ; List of (name . signature) pairs
(define *thread-implementations* ()) ; List of (name . implementation) pairs
(define *forward-refs* ())          ; List of threads that need forward declaration
(define *compilation-pass* 1)       ; Current pass (1 or 2)

;;; Modified thread generation to support two passes
(define-function c-gen-thread-wrapper (name params body)
  "Generate thread with two-pass support"
  (if (= *compilation-pass* 1)
      ;; Pass 1: Collect signature
      (let ((sig (concat-string "oop " (concat-string name "(thread_context *ctx);"))))
        (set *thread-signatures* (cons (cons name sig) *thread-signatures*))
        name)
      ;; Pass 2: Generate implementation
      (let ((impl (with-output-to-string
                    (lambda ()
                      (print "oop ") (print name) (println "(thread_context *ctx) {")
                      (body)
                      (println "}")
                      (println)))))
        (set *thread-implementations* (cons (cons name impl) *thread-implementations*))
        name)))

(define-function with-output-to-string (thunk)
  "Capture output to string (simplified version)"
  ;; In real implementation, would redirect output
  ;; For now, just execute and return placeholder
  (thunk)
  "[implementation]")

;;; Enhanced thread generators with two-pass support

(define-function c-gen-threaded-literal-2p (value next)
  "Two-pass version of literal generation"
  (let ((thread-name (c-fresh-thread)))
    (c-gen-thread-wrapper thread-name ()
      (lambda ()
        (set *c-indent-level* 1)
        (c-indent)
        (if (long? value)
            (println "ctx->acc = LONG(" value ");")
            (println "ctx->acc = nil;"))
        (c-indent)
        (println "return " next "(ctx);")
        (set *c-indent-level* 0)))))

(define-function c-gen-threaded-binop-2p (op-str left right next)
  "Two-pass version of binary operation"
  (let ((thread-name (c-fresh-thread)))
    (c-gen-thread-wrapper thread-name ()
      (lambda ()
        (set *c-indent-level* 1)
        (c-emit "long left = ") (print left) (println ";")
        (c-emit "long right = ") (print right) (println ";")
        (c-emit "ctx->acc = LONG(left ") (print op-str) (print " right);") (println)
        (c-emit "return ") (print next) (println "(ctx);")
        (set *c-indent-level* 0)))))

(define-function c-gen-threaded-return-2p ()
  "Two-pass version of return"
  (let ((thread-name (c-fresh-thread)))
    (c-gen-thread-wrapper thread-name ()
      (lambda ()
        (set *c-indent-level* 1)
        (c-emit-line "return ctx->acc;")
        (set *c-indent-level* 0)))))

;;; Forward declaration management

(define-function add-forward-ref (thread-name)
  "Add thread to forward reference list"
  (if (not (member? thread-name *forward-refs*))
      (set *forward-refs* (cons thread-name *forward-refs*))))

(define-function member? (item lst)
  "Check if item is in list"
  (if lst
      (if (equal? item (car lst))
          1
          (member? item (cdr lst)))
      ()))

(define-function equal? (a b)
  "Simple equality test"
  (= a b))

;;; Topological sort for dependencies

(define-structure <thread-node> (name deps generated))

(define-function create-thread-node (name)
  (let ((node (new <thread-node>)))
    (set (<thread-node>-name node) name)
    (set (<thread-node>-deps node) ())
    (set (<thread-node>-generated node) ())
    node))

(define-function add-dependency (node dep-name)
  "Add dependency to thread node"
  (set (<thread-node>-deps node) 
       (cons dep-name (<thread-node>-deps node))))

(define-function topological-sort (nodes)
  "Sort threads in dependency order"
  (let ((sorted ())
        (visited ()))
    
    (define-function visit (node)
      (if (not (member? (<thread-node>-name node) visited))
          (let ()
            ;; Visit dependencies first
            (list-do dep-name (<thread-node>-deps node)
              (let ((dep-node (find-node dep-name nodes)))
                (if dep-node (visit dep-node))))
            ;; Mark as visited
            (set visited (cons (<thread-node>-name node) visited))
            ;; Add to sorted list
            (set sorted (cons node sorted)))))
    
    ;; Visit all nodes
    (list-do node nodes
      (visit node))
    
    sorted))

(define-function find-node (name nodes)
  "Find node by name"
  (if nodes
      (if (equal? name (<thread-node>-name (car nodes)))
          (car nodes)
          (find-node name (cdr nodes)))
      ()))

;;; Two-pass compilation orchestrator

(define-function compile-with-two-passes (generator-thunk)
  "Execute compilation in two passes"
  ;; Pass 1: Collect signatures
  (set *compilation-pass* 1)
  (set *thread-signatures* ())
  (set *thread-implementations* ())
  (set *forward-refs* ())
  (set *c-thread-counter* 0)
  
  (generator-thunk)
  
  ;; Pass 2: Generate implementations
  (set *compilation-pass* 2)
  (set *c-thread-counter* 0)
  
  (generator-thunk)
  
  ;; Output forward declarations
  (println "/* Forward declarations */")
  (list-do sig-pair (reverse *thread-signatures*)
    (println (cdr sig-pair)))
  (println)
  
  ;; Output implementations
  (println "/* Thread implementations */")
  (list-do impl-pair (reverse *thread-implementations*)
    (print (cdr impl-pair))))

;;; Complete example with circular dependencies

(define-function generate-circular-example ()
  "Generate example with circular thread dependencies"
  
  ;; Standard header
  (generate-threaded-c-header)
  
  ;; Use two-pass compilation
  (compile-with-two-passes
    (lambda ()
      ;; Generate threads that may have circular deps
      (let* ((ret-thread (c-gen-threaded-return-2p))
             (add-thread (c-gen-threaded-binop-2p "+" 40 2 ret-thread)))
        
        ;; Main function (only in pass 2)
        (if (= *compilation-pass* 2)
            (let ()
              (println "int main() {")
              (set *c-indent-level* 1)
              (c-emit-line "thread_context ctx = {0};")
              (c-emit-line "ctx.sp = ctx.stack;")
              (c-emit "return ") (print add-thread) (println "(&ctx) == LONG(42) ? 0 : 1;")
              (set *c-indent-level* 0)
              (println "}")))))))

;;; Expression compiler with dependency tracking

(define-structure <compilation-context> (threads deps))

(define-function create-compilation-context ()
  (let ((ctx (new <compilation-context>)))
    (set (<compilation-context>-threads ctx) ())
    (set (<compilation-context>-deps ctx) ())
    ctx))

(define-function c-gen-expr-with-deps (expr next ctx)
  "Generate expression tracking dependencies"
  (cond
    ((long? expr)
     (let ((thread (c-gen-threaded-literal-2p expr next)))
       (add-thread-to-context ctx thread (list next))
       thread))
    
    ((pair? expr)
     (let ((op (car expr)))
       (cond
         ((= op '+)
          (let* ((left (cadr expr))
                 (right (caddr expr))
                 (thread (c-gen-threaded-binop-2p "+" left right next)))
            (add-thread-to-context ctx thread (list next))
            thread))
         
         (else
          (error "Unsupported operation in two-pass compiler")))))
    
    (else
     (error "Unsupported expression type"))))

(define-function add-thread-to-context (ctx thread-name deps)
  "Add thread and its dependencies to context"
  (let ((node (create-thread-node thread-name)))
    (list-do dep deps
      (add-dependency node dep))
    (set (<compilation-context>-threads ctx)
         (cons node (<compilation-context>-threads ctx)))))

;;; Test the two-pass system

(define-function test-two-pass-compilation ()
  "Test two-pass compilation with forward declarations"
  (println "=== Two-Pass Threaded C Compilation Test ===")
  (println)
  
  (generate-circular-example))

(println "emit-c-threaded-twopass.l loaded")