;;; gen-multimethod.l -- Convert gen functions to multimethods for backend dispatch
;;;
;;; This redesigns the compiler to use multimethod dispatch on backend objects
;;; instead of having gen- as plain functions.

(require "lib/stream/port.l")

;;; Define backend types
(define-structure <asm-backend> ())
(define-structure <c-backend> ())

;;; Create singleton backend instances
(define asm-backend (new <asm-backend>))
(define c-backend (new <c-backend>))

;;; Current backend (default to assembly)
(or (defined? '*current-backend*) (define *current-backend* asm-backend))

;;; Convert gen-if to a multimethod

;; First, save the original function
(define gen-if-original gen-if)

;; Undefine the existing function
(set gen-if ())

;; Define selector
(define-selector gen-if)

;; Assembly backend - use original implementation
(define-method gen-if <asm-backend> (expr comp)
  (let ((a (LABEL (temp-label-name)))
        (b (LABEL (temp-label-name))))
    (gen (cadr expr) comp)
    (gen comp BF a)
    (gen (caddr expr) comp)
    (gen comp BR b)
    (gen comp DEFLABEL a)
    (list-do stmt (cdddr expr) (gen stmt comp))
    (gen comp DEFLABEL b)))

;; C backend - generate C if statement
(define-method gen-if <c-backend> (expr comp)
  (emit-write "if (")
  (gen (cadr expr) comp)
  (emit-writeln ") {")
  (gen (caddr expr) comp)
  (and (cdddr expr)
       (let ()
         (emit-writeln "} else {")
         (list-do stmt (cdddr expr)
           (gen stmt comp))))
  (emit-writeln "}"))

;;; Convert gen-while to a multimethod

(define gen-while-original gen-while)
(set gen-while ())
(define-selector gen-while)

;; Assembly backend
(define-method gen-while <asm-backend> (expr comp)
  (let ((body (LABEL (temp-label-name)))
        (test (LABEL (temp-label-name))))
    (gen comp BR test)
    (gen comp DEFLABEL body)
    (list-do stmt (cddr expr) (gen stmt comp))
    (gen comp DEFLABEL test)
    (gen (cadr expr) comp)
    (gen comp BT body)))

;; C backend
(define-method gen-while <c-backend> (expr comp)
  (emit-write "while (")
  (gen (cadr expr) comp)
  (emit-writeln ") {")
  (list-do stmt (cddr expr)
    (gen stmt comp))
  (emit-writeln "}"))

;;; Convert gen-let to a multimethod

(define gen-let-original gen-let)
(set gen-let ())
(define-selector gen-let)

;; Assembly backend
(define-method gen-let <asm-backend> (expr comp)
  (let ((temps (map-with gen-let-binding (caddr expr) comp)))
    (list-do stmt (cdddr expr) (gen stmt comp))
    (list-do temp temps (free-temp comp temp))))

;; C backend
(define-method gen-let <c-backend> (expr comp)
  (let ((bindings (caddr expr))
        (body (cdddr expr)))
    (emit-writeln "{")
    ;; Generate variable declarations
    (list-do binding bindings
      (let ((var (car binding))
            (init-exprs (cdr binding)))
        (emit-write "  long ")
        (emit-write (mangle-label (<variable>-name var)))
        (emit-write " = ")
        ;; Handle multiple init expressions
        (if (pair? init-exprs)
            (let ()
              (list-do init (butlast init-exprs)
                (gen init comp)
                (emit-write ", "))
              (gen (last init-exprs) comp))
            (emit-write "0"))
        (emit-writeln ";")))
    ;; Generate body
    (list-do stmt body
      (emit-write "  ")
      (gen stmt comp)
      (emit-writeln ";"))
    (emit-writeln "}")))

;;; Convert gen-set to a multimethod

(define gen-set-original gen-set)
(set gen-set ())
(define-selector gen-set)

;; Assembly backend
(define-method gen-set <asm-backend> (expr comp)
  (let* ((var (cadr expr))
         (val (<variable>-value var)))
    (gen (caddr expr) comp)
    (if (temp? val)
        (gen comp STORE val)
        (gen comp STORE (GI32 (LABEL (<variable>-name var)))))))

;; C backend
(define-method gen-set <c-backend> (expr comp)
  (let ((var (cadr expr))
        (value (caddr expr)))
    (emit-write (mangle-label (<variable>-name var)))
    (emit-write " = ")
    (gen value comp)))

;;; Update forms list to use new multimethod dispatchers
(set forms (list
  (cons let    (lambda (expr comp) (gen-let *current-backend* expr comp)))
  (cons and    (lambda (expr comp) (gen-and expr comp)))
  (cons or     (lambda (expr comp) (gen-or expr comp)))
  (cons if     (lambda (expr comp) (gen-if *current-backend* expr comp)))
  (cons while  (lambda (expr comp) (gen-while *current-backend* expr comp)))
  (cons set    (lambda (expr comp) (gen-set *current-backend* expr comp)))
  (cons return (lambda (expr comp) (gen-return expr comp)))
  (cons address-of (lambda (expr comp) (gen-address-of expr comp)))))

;;; Now extend gen methods for different backends

;; Save original gen methods
(define gen-methods-original (oop-at (%typecheck <selector> gen) 1))

;; Create backend-aware gen method
(define-method gen <long> (comp)
  (if (= *current-backend* c-backend)
      (emit-write self "L")
      ;; Call original method
      ((array-at gen-methods-original (type-of self)) self comp)))

(define-method gen <string> (comp)
  (if (= *current-backend* c-backend)
      (let ()
        (emit-write "\"")
        (for-each self (lambda (c)
          (cond
            ((= c ?\") (emit-write "\\\""))
            ((= c ?\\) (emit-write "\\\\"))
            ((= c ?\n) (emit-write "\\n"))
            ((= c ?\r) (emit-write "\\r"))
            ((= c ?\t) (emit-write "\\t"))
            ((< c 32) (emit-write "\\" (format "%03o" c)))
            (else (emit-write (format "%c" c))))))
        (emit-write "\""))
      ;; Call original method
      ((array-at gen-methods-original (type-of self)) self comp)))

(define-method gen <variable> (comp)
  (if (= *current-backend* c-backend)
      (emit-write (mangle-label (<variable>-name self)))
      ;; Call original method
      ((array-at gen-methods-original (type-of self)) self comp)))

;; Special handling for pairs (expressions)
(define-method gen <pair> (comp)
  (if (= *current-backend* c-backend)
      ;; C backend - handle binary ops and function calls directly
      (let ((head (car self))
            (args (cdr self)))
        (cond
          ;; Binary operations
          ((and (member? head '(+ - * / < > <= >= = !=))
                (= 2 (list-length args)))
           (emit-write "(")
           (gen (car args) comp)
           (emit-write (cond
                         ((= head '+) " + ")
                         ((= head '-) " - ")
                         ((= head '*) " * ")
                         ((= head '/) " / ")
                         ((= head '<) " < ")
                         ((= head '>) " > ")
                         ((= head '<=) " <= ")
                         ((= head '>=) " >= ")
                         ((= head '=) " == ")
                         ((= head '!=) " != ")))
           (gen (cadr args) comp)
           (emit-write ")"))
          ;; Check if it's a special form
          ((assq head forms)
           ;; Call the original gen <pair> to handle forms
           ((array-at gen-methods-original (type-of self)) self comp))
          ;; Function calls
          (else
           (if (variable? head)
               (emit-write (mangle-label (<variable>-name head)))
               (emit-write (mangle-label head)))
           (emit-write "(")
           (let ((first t))
             (list-do arg args
               (if first
                   (set first ())
                   (emit-write ", "))
               (gen arg comp)))
           (emit-write ")"))))
      ;; Assembly backend - use original
      ((array-at gen-methods-original (type-of self)) self comp)))

;;; Helper functions
(define-function butlast (lst)
  (if (or (not lst) (not (cdr lst)))
      ()
      (cons (car lst) (butlast (cdr lst)))))

(define-function last (lst)
  (if (cdr lst)
      (last (cdr lst))
      (car lst)))

(println "; Multimethod code generator loaded")
(println "; Set *current-backend* to c-backend or asm-backend")