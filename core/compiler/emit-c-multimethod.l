;;; emit-c-multimethod.l -- Proper C backend using multimethod dispatch
;;;
;;; This shows how the C backend should override the same gen- methods
;;; that assembly backends use, but generate C code instead of assembly instructions.

(require "lib/stream/port.l")

;;; For the C backend, we override the gen- methods directly
;;; instead of generating assembly-like instructions

;;; Override gen-if to generate C if statements
(define-method gen-if <expr> (expr comp)
  ;; Check if we're in C backend mode
  (if (= 'c *emit-backend*)
      (let ()
        ;; Generate C if statement
        (emit-write "if (")
        (gen (cadr expr) comp)  ; Generate condition
        (emit-writeln ") {")
        (gen (caddr expr) comp) ; Generate then branch
        (when (cdddr expr)
          (emit-writeln "} else {")
          (list-do stmt (cdddr expr)
            (gen stmt comp)))   ; Generate else branch
        (emit-writeln "}"))
      ;; Otherwise use the default assembly-oriented implementation
      (let ((a (LABEL (temp-label-name)))
            (b (LABEL (temp-label-name))))
        (gen (cadr expr) comp)
        (gen comp BF a)
        (gen (caddr expr) comp)
        (gen comp BR b)
        (gen comp DEFLABEL a)
        (list-do stmt (cdddr expr) (gen stmt comp))
        (gen comp DEFLABEL b))))

;;; Override gen-while to generate C while loops
(define-method gen-while <expr> (expr comp)
  (if (= 'c *emit-backend*)
      (let ()
        ;; Generate C while loop
        (emit-write "while (")
        (gen (cadr expr) comp)  ; Generate condition
        (emit-writeln ") {")
        (list-do stmt (cddr expr)
          (gen stmt comp))      ; Generate body
        (emit-writeln "}"))
      ;; Otherwise use the default assembly-oriented implementation
      (let ((body (LABEL (temp-label-name)))
            (test (LABEL (temp-label-name))))
        (gen comp BR test)
        (gen comp DEFLABEL body)
        (list-do stmt (cddr expr) (gen stmt comp))
        (gen comp DEFLABEL test)
        (gen (cadr expr) comp)
        (gen comp BT body))))

;;; For the C backend, gen on expressions should generate C expressions
;;; that evaluate to a value (stored in the accumulator pattern)
(define-method gen <long> (comp)
  (if (= 'c *emit-backend*)
      (emit-write "_acc = " self "L")
      ;; Default: generate LOAD instruction
      (gen comp LOAD (LI32 self))))

(define-method gen <string> (comp)
  (if (= 'c *emit-backend*)
      (let ()
        (emit-write "_acc = \"")
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
      ;; Default: generate label and LOAD
      (let ((label (LABEL (temp-label-name))))
        (gen comp DATA)
        (gen comp DEFLABEL label)
        (gen comp ASCIZ self)
        (gen comp TEXT)
        (gen comp LOAD label))))

;;; Override binary operations for C
(define-method gen-binary-op <symbol> (op arg1 arg2 comp)
  (if (= 'c *emit-backend*)
      (let ((op-str (cond
                      ((= op '+) "+")
                      ((= op '-) "-")
                      ((= op '*) "*")
                      ((= op '/) "/")
                      ((= op '<) "<")
                      ((= op '>) ">")
                      ((= op '<=) "<=")
                      ((= op '>=) ">=")
                      ((= op '=) "==")
                      ((= op '!=) "!=")
                      (else (error "Unknown operator: " op)))))
        ;; Generate: _tmp0 = arg1; _acc = _tmp0 op arg2;
        (emit-write "{ long _tmp = ")
        (gen arg1 comp)
        (emit-write "; _acc = _tmp " op-str " ")
        (gen arg2 comp)
        (emit-writeln "; }"))
      ;; Default: use assembly instructions
      (let ((tmp (gen-tmp arg2 comp)))
        (gen arg1 comp)
        (free-temp comp tmp)
        (gen comp (cond
                    ((= op '+) ADD)
                    ((= op '-) SUB)
                    ((= op '*) MUL)
                    ((= op '/) DIV)
                    ((= op '<) LT)
                    ((= op '>) GT)
                    ((= op '<=) LE)
                    ((= op '>=) GE)
                    ((= op '=) EQ)
                    ((= op '!=) NE)
                    (else (error "Unknown operator: " op)))
             tmp))))

;;; This approach allows the same compiler infrastructure to generate
;;; either assembly or C code based on the backend selection, while
;;; keeping the high-level structure of the compiler the same.