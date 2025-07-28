;;; backend-dispatch.l -- Backend-aware code generation using multimethod dispatch
;;;
;;; Instead of modifying existing gen- functions, we create a parallel
;;; set of multimethods that dispatch on backend type.

(require "lib/stream/port.l")

;;; Define backend types
(define-structure <backend> ())
(define-structure <asm-backend> (<backend>))
(define-structure <c-backend> (<backend>))

;;; Create backend instances
(define asm-backend (new <asm-backend>))
(define c-backend (new <c-backend>))

;;; Define new multimethod selectors for backend-aware generation
(define-selector emit-if)
(define-selector emit-while)
(define-selector emit-let)
(define-selector emit-set)
(define-selector emit-value)
(define-selector emit-expr)

;;; Assembly backend implementations - delegate to original gen- functions

(define-method emit-if <asm-backend> (expr comp)
  (gen-if expr comp))

(define-method emit-while <asm-backend> (expr comp)
  (gen-while expr comp))

(define-method emit-let <asm-backend> (expr comp)
  (gen-let expr comp))

(define-method emit-set <asm-backend> (expr comp)
  (gen-set expr comp))

;;; C backend implementations - generate idiomatic C

(define-method emit-if <c-backend> (expr comp)
  (emit-write "if (")
  (emit-expr self (cadr expr) comp)
  (emit-writeln ") {")
  (emit-expr self (caddr expr) comp)
  (emit-writeln ";")
  (and (cdddr expr)
       (let ()
         (emit-writeln "} else {")
         (list-do stmt (cdddr expr)
           (emit-expr self stmt comp)
           (emit-writeln ";"))))
  (emit-writeln "}"))

(define-method emit-while <c-backend> (expr comp)
  (emit-write "while (")
  (emit-expr self (cadr expr) comp)
  (emit-writeln ") {")
  (list-do stmt (cddr expr)
    (emit-expr self stmt comp)
    (emit-writeln ";"))
  (emit-writeln "}"))

(define-method emit-let <c-backend> (expr comp)
  (let ((bindings (cadr expr))
        (body (cddr expr)))
    (emit-writeln "{")
    ;; Generate variable declarations
    (list-do binding bindings
      (let ((var (car binding))
            (init (cadr binding)))
        (emit-write "  long ")
        (emit-write (mangle-label (<variable>-name var)))
        (emit-write " = ")
        ;; Handle init expression
        (if init
            (emit-expr self init comp)
            (emit-write "0"))
        (emit-writeln ";")))
    ;; Generate body
    (list-do stmt body
      (emit-write "  ")
      (emit-expr self stmt comp)
      (emit-writeln ";"))
    (emit-writeln "}")))

(define-method emit-set <c-backend> (expr comp)
  (emit-write (mangle-label (<variable>-name (cadr expr))))
  (emit-write " = ")
  (emit-expr self (caddr expr) comp))

;;; Value emission methods

(define-method emit-value <asm-backend> (value comp)
  (gen value comp))

(define-method emit-value <c-backend> (value comp)
  (cond
    ((long? value) (emit-write value "L"))
    ((string? value)
     (emit-write "\"")
     (for-each value (lambda (c)
       (cond
         ((= c ?\") (emit-write "\\\""))
         ((= c ?\\) (emit-write "\\\\"))
         ((= c ?\n) (emit-write "\\n"))
         ((= c ?\r) (emit-write "\\r"))
         ((= c ?\t) (emit-write "\\t"))
         ((< c 32) (emit-write "\\" (format "%03o" c)))
         (else (emit-write (format "%c" c))))))
     (emit-write "\""))
    ((variable? value)
     (emit-write (mangle-label (<variable>-name value))))
    ((symbol? value)
     (emit-write (mangle-label value)))
    (else
     (error "emit-value: unknown value type: " value))))

;;; Expression emission - the main dispatcher

(define-method emit-expr <asm-backend> (expr comp)
  ;; For assembly backend, just delegate to gen
  ;; The gen function already handles all expression types
  (gen expr comp))

(define-method emit-expr <c-backend> (expr comp)
  (cond
    ;; Empty list
    ((not expr)
     (emit-write "0") ; Empty list is typically NULL/0 in C
     )
    ;; Literals
    ((or (long? expr) (string? expr) (variable? expr) (symbol? expr))
     (emit-value self expr comp))
    ;; Special forms
    ((pair? expr)
     (let ((head (car expr)))
       (cond
         ((= head 'if) (emit-if self expr comp))
         ((= head 'while) (emit-while self expr comp))
         ((= head 'let) (emit-let self expr comp))
         ((= head 'set) (emit-set self expr comp))
         ;; Binary operations
         ((and (member? head '(+ - * / < > <= >= = !=))
               (= 3 (list-length expr)))
          (emit-write "(")
          (emit-expr self (cadr expr) comp)
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
          (emit-expr self (caddr expr) comp)
          (emit-write ")"))
         ;; Function calls
         (else
          (if (variable? head)
              (emit-write (mangle-label (<variable>-name head)))
              (emit-write (mangle-label head)))
          (emit-write "(")
          (let ((first 1))
            (list-do arg (cdr expr)
              (if first
                  (set first ())
                  (emit-write ", "))
              (emit-expr self arg comp)))
          (emit-write ")")))))
    (else
     (error "emit-expr: unknown expression type: " expr))))

;;; Helper predicates
(define-function long? (x) (= <long> (type-of x)))
(define-function string? (x) (= <string> (type-of x)))
(define-function variable? (x) (= <variable> (type-of x)))
(define-function symbol? (x) (= <symbol> (type-of x)))
(define-function pair? (x) (= <pair> (type-of x)))

;;; Override gen-definition for C backend
(define gen-definition-original gen-definition)

(define-selector emit-definition)

(define-method emit-definition <asm-backend> (defn name comp)
  (gen-definition defn name comp))

(define-method emit-definition <c-backend> (defn name comp)
  ;; For now, just handle <expr> (function) definitions
  (if (= <expr> (type-of defn))
      (let* ((expr-defn (<expr>-defn defn))
             (params (cadr expr-defn))
             (body (cddr expr-defn))
             (main? (= 'main name)))
        ;; Function signature
        (if main?
            (emit-writeln "int main(int argc, char **argv) {")
            (let ()
              (emit-write "long ")
              (emit-write (mangle-label name))
              (emit-write "(")
              (let ((first 1))
                (list-do param params
                  (if first
                      (set first ())
                      (emit-write ", "))
                  (emit-write "long ")
                  (emit-write (mangle-label (<variable>-name param)))))
              (emit-writeln ") {")))
        
        ;; Function body
        (let ((last-expr ()))
          (list-do stmt body
            (emit-write "  ")
            (set last-expr stmt)
            (emit-expr self stmt comp)
            (emit-writeln ";"))
          
          ;; Return statement
          (emit-write "  return ")
          (if main?
              (emit-write "0")
              (if last-expr
                  (emit-expr self last-expr comp)
                  (emit-write "0")))
          (emit-writeln ";"))
        
        (emit-writeln "}")
        (emit-writeln))
      ;; For other definition types, fall back to assembly
      (gen-definition defn name comp)))

(println "; Backend dispatch system loaded")
(println "; Use (emit-expr <backend> expr comp) to generate code")