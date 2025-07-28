;;; gen-c-proper.l -- C code generation at the proper abstraction level
;;;
;;; This file shows how to intercept at the gen level to produce
;;; idiomatic C code instead of assembly-like instructions.

(require "lib/stream/port.l")

;;; Save the original gen functions before overriding
(define gen-if-asm gen-if)
(define gen-while-asm gen-while)
(define gen-let-asm gen-let)
(define gen-set-asm gen-set)

;;; Backend selection
(or (defined? '*gen-backend*) (define *gen-backend* 'asm))

;;; Override gen-if to check backend
(set gen-if (lambda (expr comp)
  (if (= *gen-backend* 'c)
      ;; Generate C if statement
      (let ()
        (emit-write "if (")
        (gen (cadr expr) comp)      ; condition
        (emit-writeln ") {")
        (gen (caddr expr) comp)     ; then branch
        (if (cdddr expr)
            (let ()
              (emit-writeln "} else {")
              (list-do stmt (cdddr expr)
                (gen stmt comp)))   ; else branch
            ())
        (emit-writeln "}"))
      ;; Use original assembly version
      (gen-if-asm expr comp))))

;;; Override gen-while to check backend
(set gen-while (lambda (expr comp)
  (if (= *gen-backend* 'c)
      ;; Generate C while loop
      (let ()
        (emit-write "while (")
        (gen (cadr expr) comp)      ; condition
        (emit-writeln ") {")
        (list-do stmt (cddr expr)
          (gen stmt comp))          ; body
        (emit-writeln "}"))
      ;; Use original assembly version
      (gen-while-asm expr comp))))

;;; Override gen-let to check backend
(set gen-let (lambda (expr comp)
  (if (= *gen-backend* 'c)
      ;; Generate C local variables
      (let ((bindings (caddr expr))
            (body (cdddr expr)))
        (emit-writeln "{")
        ;; Generate variable declarations
        (list-do binding bindings
          (let ((var (car binding))
                (init (cadr binding)))
            (emit-write "  long ")
            (emit-write (mangle-label (<variable>-name var)))
            (emit-write " = ")
            (gen init comp)
            (emit-writeln ";")))
        ;; Generate body
        (list-do stmt body
          (gen stmt comp))
        (emit-writeln "}"))
      ;; Use original assembly version
      (gen-let-asm expr comp))))

;;; Override gen-set to check backend
(set gen-set (lambda (expr comp)
  (if (= *gen-backend* 'c)
      ;; Generate C assignment
      (let ((var (cadr expr))
            (value (caddr expr)))
        (emit-write (mangle-label (<variable>-name var)))
        (emit-write " = ")
        (gen value comp)
        (emit-writeln ";"))
      ;; Use original assembly version
      (gen-set-asm expr comp))))

;;; For C backend, override how basic values are generated
(define gen-long-original ())
(define gen-string-original ())

;; Save original methods
(let ((gen-methods (oop-at (%typecheck <selector> gen) 1)))
  (set gen-long-original (array-at gen-methods (type-of 42)))
  (set gen-string-original (array-at gen-methods (type-of "hello"))))

(define-method gen <long> (comp)
  (if (= *gen-backend* 'c)
      (emit-write self "L")
      (gen-long-original self comp)))

(define-method gen <string> (comp)
  (if (= *gen-backend* 'c)
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
      (gen-string-original self comp)))

;;; Handle variables for C backend
(define gen-variable-original ())
(let ((gen-methods (oop-at (%typecheck <selector> gen) 1)))
  (set gen-variable-original (array-at gen-methods (type-of (<env>-bindings *globals*)))))

(define-method gen <variable> (comp)
  (if (= *gen-backend* 'c)
      (emit-write (mangle-label (<variable>-name self)))
      (gen-variable-original self comp)))

;;; For C backend, handle binary operations directly in gen <pair>
(define gen-pair-original ())
(let ((gen-methods (oop-at (%typecheck <selector> gen) 1)))
  (set gen-pair-original (array-at gen-methods (type-of '(+ 1 2)))))

(define-method gen <pair> (comp)
  (if (= *gen-backend* 'c)
      ;; Check if it's a binary operation we can handle
      (let ((head (car self))
            (args (cdr self)))
        (cond
          ;; Binary arithmetic operations
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
          ;; Let the form handlers deal with control structures
          ((assq head forms)
           (gen-pair-original self comp))
          ;; Function calls
          (else
           (emit-write (mangle-label head) "(")
           (let ((first t))
             (list-do arg args
               (if first
                   (set first ())
                   (emit-write ", "))
               (gen arg comp)))
           (emit-write ")"))))
      ;; Use original assembly version
      (gen-pair-original self comp)))

(println "; C code generator loaded - set *gen-backend* to 'c to enable")