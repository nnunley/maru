;;; native-link.l -- a unit of intents (native-gen.k) to machine code in a code region: each function's intents lowered
;;; by its instruction set's grammar (native-arm64.g), encoded by the checked encoders (asm-table.l), and installed.
;;;   (native-install unit)   => ((name . address) …), each function callable by subr
(define native-region (code-region-allocate 1048576))
(define native-lowerings (list (cons 'arm64 (lambda (intents) (parse-source <native-arm64> $program intents)))))

(define-function native-install (unit)
  (let ((isa (stub-isa)) (image ()))
    (list-do f (<native-unit>-functions unit)
      (let ((lower (or (cdr (assq isa native-lowerings)) (error "native: no lowering for " isa)))
	    (buffer (asm-buffer (code-region-next native-region))))
	(list-do forms (lower (cadr f)) (list-do form forms (asm isa buffer form)))
	(push image (cons (car f) (code-region-install native-region buffer)))))
    image))
