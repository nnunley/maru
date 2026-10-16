;;; Memory that holds executable code, allocated and filled through C calls.
;;;
;;;   (code-region-allocate size)          => region, a list (base size next)
;;;   (code-region-next region)            the next free address, 16-byte aligned
;;;   (code-region-fits? region buffer)    whether a buffer fits at its origin, past installed code
;;;   (code-region-install region buffer)  copy it there and make it runnable => its origin
;;;   (code-callable address signature)    a subr that calls address through the C ABI
;;;
;;; Assemble into a buffer whose origin is (code-region-next region), then
;;; install it.  Needs osdefs.k for PROT_* and MAP_*.  On macOS the region is
;;; MAP_JIT and writes are bracketed by pthread_jit_write_protect_np; the
;;; instruction cache is flushed with sys_icache_invalidate or __clear_cache
;;; where the system has one (x86 keeps its caches coherent and needs neither).

(define code-region-mmap	(subr "mmap" "pliiil>p"))
(define code-region-dlsym	(subr "dlsym" "ps>p"))

;; The C function name as a subr with signature sig, or () if this system lacks it.
(define-function code-region-optional (name sig)
  (let ((a (code-region-dlsym RTLD_DEFAULT name)))
    (and (!= 0 a) (subr a sig))))

(define code-region-write-protect (code-region-optional "pthread_jit_write_protect_np" "i"))
(define code-region-flush
  (or (code-region-optional "sys_icache_invalidate" "pl")
      (let ((clear (code-region-optional "__clear_cache" "pp")))
	(and clear (lambda (start length) (clear start (+ start length)))))))

(define-function code-region-allocate (size)
  (let ((base (code-region-mmap 0 size (| PROT_READ (| PROT_WRITE PROT_EXEC))
				(| MAP_PRIVATE (| MAP_ANON MAP_JIT)) -1 0)))
    (and (= base -1) (error "code region: mmap failed"))
    (list base size base)))

(define-function code-region-next (region)	(& (+ (caddr region) 15) -16))

(define-function code-region-fits? (region buffer)
  (let ((from (asm-buffer-origin buffer)) (to (asm-buffer-pc buffer)))
        (and (<= (caddr region) from) (<= to (+ (car region) (cadr region))))))

(define-function code-region-install (region buffer)
  (or (code-region-fits? region buffer) (error "code region: buffer at " (asm-buffer-origin buffer) " does not fit"))
  (let ((origin (asm-buffer-origin buffer)) (bytes (asm-buffer-bytes buffer)))
    (and code-region-write-protect (code-region-write-protect 0))
    (for (i 0 (array-length bytes)) (set-byte-at origin i (array-at bytes i)))
    (and code-region-write-protect (code-region-write-protect 1))
    (and code-region-flush (code-region-flush origin (array-length bytes)))
    (set-car (cddr region) (+ origin (array-length bytes)))
    origin))

(define-function code-callable (address signature)	(subr address signature))
