;; Backend selection - Ian & Dan style

(define *emit-backend* 'asm)
(define *c-backend-active* ())
(define *arm64-backend-active* ())
(define *ir-backend-active* ())

(define-function use-c-backend ()
  (set *emit-backend* 'c)
  (set *c-backend-active* 1)
  (set *arm64-backend-active* ())
  (set *ir-backend-active* ()))

(define-function use-arm64-backend ()
  (set *emit-backend* 'arm64)
  (set *arm64-backend-active* 1)
  (set *c-backend-active* ())
  (set *ir-backend-active* ())
  (load-arm64-emit-mappings))

(define-function use-ir-backend ()
  (set *emit-backend* 'ir)
  (set *ir-backend-active* 1)
  (set *c-backend-active* ())
  (set *arm64-backend-active* ()))

(define-function select-backend (name)
  (let ((backend (if name (string->symbol name) ())))
    (cond
      ((= backend 'c)     (use-c-backend))
      ((= backend 'arm64) (use-arm64-backend))
      ((= backend 'ir)    (use-ir-backend))
      (else
        (cond
          ((defined? '__arm64__)     (use-arm64-backend))
          ((defined? '__x86_64__)    (set *emit-backend* 'asm))
          ((defined? '__i386__)      (set *emit-backend* 'asm))
          (else                      (use-c-backend)))))))

(define-function auto-select-backend ()
  (let ((getenv-fn (and (defined? 'extern) (extern 'getenv))))
    (select-backend (and getenv-fn (getenv-fn "MARU_EMIT_BACKEND")))))

;; Initialize backend
(auto-select-backend)