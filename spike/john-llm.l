;;; THROWAWAY SPIKE.  John's objects and values read the replicated store and ask a model, by define-john-builtin, so John's core
;;; is unchanged.  "question" ask answers from the store if anyone has answered it, else asks the model and records the answer.
(require "spike/john-chain.l")
(require "spike/llm.l")
(define *john-replica* ())
(define-john-builtin ask john-ask)
(define-method john-ask <string> () (replica-ask *john-replica* self))
(define-john-builtin shared john-shared)
(define-method john-shared <string> () (or (replica-read *john-replica* self) (john-fail "nothing is stored at " self)))
(define-john-builtin answers john-answers)	; every answer not overwritten: concurrent asks keep theirs
(define-method john-answers <string> () (replica-values *john-replica* (llm-key self)))
