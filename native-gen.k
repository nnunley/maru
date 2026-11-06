;;; native-gen.k -- typed Maru's IR to intents (draft-ndn-maru-native-ir2-00): the generator maru.k's compile-namespace
;;; drives, as it drives ir-gen-c.k, collecting a unit of functions as lists of intents instead of writing C.  Every value
;;; has a frame slot (ir2's ir-frame-allocate, as ir-gen-x86.k uses it), and an operation loads its operands into scratch
;;; registers s0, s1 …, operates, and stores its result.  Nothing here names a register, an instruction or a calling
;;; convention: those are the lowering grammars' (native-arm64.g).
;;;
;;; Intents (slots are byte offsets in the frame):
;;;   (enter size) (leave size) (return)          the frame, and returning from it
;;;   (arg i slot)                                 the ith argument, as it arrives, into its slot
;;;   (load slot s) (store slot s)                 a slot to or from a scratch register
;;;   (constant s value) (result-from s)           a value into a scratch register; a scratch register as the result
;;;   (op kind d a b)                              d := a kind b, kind add or sub
(require "ir2.k")

(define-structure <native-gen> (frame intents functions))
(define-structure <native-unit> (functions))	; ((name intents frame-size) …)
(define *native-unit* ())

(define-function ir-gen-new () (new <native-gen> () () ()))

(define-function native-emit (gen intent) (set (<native-gen>-intents gen) (cons intent (<native-gen>-intents gen))))
(define-function native-slot (gen type) (ir-frame-allocate (<native-gen>-frame gen) type))
(define-function native-offset (location) (<ir-location>-offset location))

;;; slots: each instruction's value gets one, a variable read uses the variable's, a let's value is its last operand's
(define-selector native-allocate (insn gen) (error "native: no slots for " insn))
(define-method native-allocate <ir-insn> (gen)
  (list-do opd self.operands (native-allocate opd gen))
  (or (= IR-VOID self.type) (set self.location (native-slot gen self.type))))
(define-method native-allocate <ir-get-var> (gen) (set self.location (<ir-variable>-location self.parameters)))
(define-method native-allocate <ir-set-var> (gen)
  (native-allocate (car self.operands) gen)
  (set self.location (<ir-variable>-location self.parameters)))
(define-method native-allocate <ir-let> (gen)
  (list-do bind self.parameters (set (<ir-variable>-location (cdr bind)) (native-slot gen (<ir-variable>-type (cdr bind)))))
  (let ((last ()))
    (list-do expr self.operands (native-allocate (set last expr) gen))
    (set self.location (and last (<ir-insn>-location last)))))
(define-method native-allocate <ir-return> (gen) (list-do opd self.operands (native-allocate opd gen)))

;;; intents
(define-selector native-lower (insn gen) (error "native: no lowering for " insn))
(define-function native-into (gen insn s) (native-emit gen (list 'load (native-offset (<ir-insn>-location insn)) s)))
(define-function native-out (gen insn s) (native-emit gen (list 'store (native-offset (<ir-insn>-location insn)) s)))

(define-method native-lower <ir-lit> (gen)
  (native-emit gen (list 'constant 's0 (car self.parameters)))
  (native-out gen self 's0))
(define-method native-lower <ir-get-var> (gen) ())
(define-method native-lower <ir-set-var> (gen)
  (let ((value (car self.operands)))
    (native-lower value gen)
    (native-into gen value 's0)
    (native-out gen self 's0)))
(define-method native-lower <ir-let> (gen) (list-do expr self.operands (native-lower expr gen)))
(define-function native-binary (gen insn kind)
  (let ((a (car (<ir-insn>-operands insn))) (b (cadr (<ir-insn>-operands insn))))
    (native-lower a gen) (native-lower b gen)
    (native-into gen a 's0) (native-into gen b 's1)
    (native-emit gen (list 'op kind 's0 's0 's1))
    (native-out gen insn 's0)))
(define-method native-lower <ir-add> (gen) (native-binary gen self 'add))
(define-method native-lower <ir-sub> (gen) (native-binary gen self 'sub))
(define-method native-lower <ir-neg> (gen)
  (let ((a (car self.operands)))
    (native-lower a gen)
    (native-into gen a 's1)
    (native-emit gen '(constant s0 0))
    (native-emit gen '(op sub s0 s0 s1))
    (native-out gen self 's0)))
(define-method native-lower <ir-return> (gen)
  (let ((value (car self.operands)))
    (when value
      (native-lower value gen)
      (native-into gen value 's0)
      (native-emit gen '(result-from s0)))
    (native-emit gen (list 'leave '*frame*))
    (native-emit gen '(return))))

;;; the generator protocol
(define-method ir-gen-header <native-gen> () (set *native-unit* (new <native-unit> ())))
(define-method ir-gen-declare-struct <native-gen> args ())
(define-method ir-gen-global-declaration <native-gen> args ())
(define-method ir-gen-local-declaration <native-gen> args ())
(define-method ir-gen-preamble <native-gen> () ())
(define-method ir-gen-initialisation <native-gen> args ())
(define-method ir-gen-postamble <native-gen> () ())
(define-method ir-gen-output <native-gen> () ())

(define-method ir-gen-function-implementation <native-gen> (value)
  (let* ((name (car (<ir-function>-parameters value)))
	 (params (<ir-scope>-bindings (<ir-function>-scope value)))
	 (body (<ir-function>-operands value))
	 (i 0))
    (set self.frame (ir-frame-new))
    (set self.intents ())
    (list-do bind params (set (<ir-variable>-location (cdr bind)) (native-slot self (<ir-variable>-type (cdr bind)))))
    (list-do insn body (native-allocate insn self))
    (let ((size (align (ir-frame-finalise self.frame 0) 16)) (last ()))
      (native-emit self (list 'enter size))
      (list-do arg (cadr (<ir-function>-parameters value))	; in order: a scope's bindings are most recent first
	(native-emit self (list 'arg i (native-offset (<ir-variable>-location (cdr (assq arg params))))))
	(set i (+ i 1)))
      (list-do insn body (native-lower (set last insn) self))
      (unless (and last (ir-returns? last)) (native-emit self (list 'leave '*frame*)) (native-emit self '(return)))
      (set (<native-unit>-functions *native-unit*)
	   (cons (list name (map (lambda (x) (if (and (pair? x) (= '*frame* (cadr x))) (list (car x) size) x))
				 (list-reverse! self.intents))
		       size)
		 (<native-unit>-functions *native-unit*))))))
