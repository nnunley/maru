;;; emit-c-proper.l -- Proper C backend that generates idiomatic C code
;;;
;;; This is a proof-of-concept for how the C backend should work,
;;; generating structured C code instead of assembly-in-C.

(require "lib/stream/port.l")

;;; C-specific compiler state
(define-structure <c-compiler> 
  (parent temp-counter local-vars current-function return-type indent-level))

(define-function c-compiler (parent)
  (let ((self (new <c-compiler>)))
    (set (<c-compiler>-parent self) parent)
    (set (<c-compiler>-temp-counter self) 0)
    (set (<c-compiler>-local-vars self) ())
    (set (<c-compiler>-indent-level self) 0)
    self))

;;; Indentation helper
(define-function c-indent (comp)
  (port-indent *emit-output-port* (* (<c-compiler>-indent-level comp) 2)))

(define-function c-indent++ (comp)
  (set (<c-compiler>-indent-level comp) (+ (<c-compiler>-indent-level comp) 1)))

(define-function c-indent-- (comp)
  (set (<c-compiler>-indent-level comp) (- (<c-compiler>-indent-level comp) 1)))

;;; Generate C temporary variable names
(define-function c-new-temp (comp)
  (let ((n (<c-compiler>-temp-counter comp)))
    (set (<c-compiler>-temp-counter comp) (+ n 1))
    (concat-string "tmp" (long->string n))))

;;; Define selectors first
(define-selector gen-c-expr)
(define-selector gen-c-statement)

;;; C-specific gen-if function
(define-function c-gen-if (expr comp)
  (c-indent comp) (emit-write "if (")
  (let ((test-var (gen-c-expr (cadr expr) comp)))
    (emit-write test-var)
    (emit-writeln ") {")
    (c-indent++ comp)
    (gen-c-statement (caddr expr) comp)
    (c-indent-- comp)
    (and (cdddr expr)
      (let ()
        (c-indent comp) (emit-writeln "} else {")
        (c-indent++ comp)
        (list-do stmt (cdddr expr)
          (gen-c-statement stmt comp))
        (c-indent-- comp)))
    (c-indent comp) (emit-writeln "}")))

;;; C-specific gen-while function
(define-function c-gen-while (expr comp)
  (c-indent comp) (emit-write "while (")
  (let ((test-var (gen-c-expr (cadr expr) comp)))
    (emit-write test-var)
    (emit-writeln ") {")
    (c-indent++ comp)
    (list-do stmt (cddr expr)
      (gen-c-statement stmt comp))
    (c-indent-- comp)
    (c-indent comp) (emit-writeln "}")))

;;; Generate C expressions (return temporary variable name)

(define-method gen-c-expr <long> (comp)
  (let ((temp (c-new-temp comp)))
    (c-indent comp)
    (emit-writeln "long " temp " = " self "L;")
    temp))

(define-method gen-c-expr <string> (comp)
  (let ((temp (c-new-temp comp)))
    (c-indent comp)
    (emit-write "char *" temp " = ")
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
    (emit-writeln "\";")
    temp))

(define-method gen-c-expr <variable> (comp)
  ;; For now, just return the variable name
  (mangle-label (<variable>-name self)))

;;; Generate binary operations
(define-function gen-c-binary-op (op-str arg1 arg2 comp)
  (let ((temp (c-new-temp comp))
        (a (gen-c-expr arg1 comp))
        (b (gen-c-expr arg2 comp)))
    (c-indent comp)
    (emit-writeln "long " temp " = " a " " op-str " " b ";")
    temp))

;;; Generate C statements (for side effects)

(define-method gen-c-statement <pair> (comp)
  (let ((head (car self)))
    (cond
      ((= head '+) (gen-c-binary-op "+" (cadr self) (caddr self) comp))
      ((= head '-) (gen-c-binary-op "-" (cadr self) (caddr self) comp))
      ((= head '*) (gen-c-binary-op "*" (cadr self) (caddr self) comp))
      ((= head '/) (gen-c-binary-op "/" (cadr self) (caddr self) comp))
      ((= head '<) (gen-c-binary-op "<" (cadr self) (caddr self) comp))
      ((= head '>) (gen-c-binary-op ">" (cadr self) (caddr self) comp))
      ((= head 'if) (c-gen-if self comp))
      ((= head 'while) (c-gen-while self comp))
      (else
        ;; Function call or other expression
        (let ((result (gen-c-expr self comp)))
          result)))))

(define-method gen-c-statement <long> (comp)
  (gen-c-expr self comp))

(define-method gen-c-statement <string> (comp)
  (gen-c-expr self comp))

;;; Override gen-definition for functions
(define-method gen-definition <expr> (name comp)
  (let* ((c-comp (c-compiler comp))
         (defn (<expr>-defn self))
         (params (cadr defn))
         (body (cddr defn))
         (main? (= 'main name)))
    
    ;; Function signature
    (if main?
        (emit-writeln "int main(int argc, char **argv) {")
        (let ()
          (emit-write "long ")
          (emit-write (mangle-label name))
          (emit-write "(")
          (let ((first t))
            (list-do param params
              (if first
                  (set first ())
                  (emit-write ", "))
              (emit-write "long " (mangle-label (<variable>-name param)))))
          (emit-writeln ") {")))
    
    ;; Function body
    (c-indent++ c-comp)
    (let ((last-result ()))
      (list-do stmt body
        (set last-result (gen-c-statement stmt c-comp))))
    
    ;; Return statement
    (if main?
        (progn
          (c-indent c-comp) (emit-writeln "return 0;"))
        (progn
          (c-indent c-comp) (emit-write "return ")
          (emit-write (or last-result "0"))
          (emit-writeln ";")))
    
    (c-indent-- c-comp)
    (emit-writeln "}")
    (emit-writeln)))

;;; Example of how this generates better C code:
;;; Input: (define (add x y) (+ x y))
;;; Current backend generates:
;;;   oop add(oop _param0, oop _param1) {
;;;     oop _acc = nil;
;;;     _acc = _param0;
;;;     oop _tmp0 = _acc;
;;;     _acc = _param1;
;;;     _acc = LONG(getLong(_tmp0) + getLong(_acc));
;;;     return _acc;
;;;   }
;;;
;;; This backend would generate:
;;;   long add(long x, long y) {
;;;     long tmp0 = x + y;
;;;     return tmp0;
;;;   }