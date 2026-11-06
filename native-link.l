;;; native-link.l -- a unit of intents (native-gen.k) to machine code in a code region: each function's intents lowered
;;; by its instruction set's grammar (native-arm64.g), encoded by the checked encoders (asm-table.l), and installed.
;;;   (native-install unit)   => ((name . address) …), each function callable by subr
(define native-region (code-region-allocate 1048576))
(define native-lowerings (list (cons 'arm64 (lambda (intents) (parse-source <native-arm64> $program intents)))))

;; each intent's forms into the buffer: (at L) marks where L is, a (label L) operand is a placeholder patched to it
(define-function native-assemble (isa buffer intents)
  (let ((labels ()) (fixups ()))
    (list-do forms intents
      (list-do form forms
	(if (= 'at (car form))
	    (push labels (cons (cadr form) (asm-buffer-pc buffer)))
	  (let* ((label (list-detect op (cdr form) (and (pair? op) (= 'label (car op)))))
		 (reports (asm isa buffer (if label (map (lambda (op) (if (= op label) '(reloc) op)) form) form))))
	    (and label (push fixups (cons (car reports) (cadr label))))))))
    (list-do f fixups
      (asm-patch isa buffer (car f) (or (cdr (assq (cdr f) labels)) (error "native: no label " (cdr f)))))))

(define-function native-install (unit)
  (let ((isa (stub-isa)) (image ()))
    (list-do f (<native-unit>-functions unit)
      (let ((lower (or (cdr (assq isa native-lowerings)) (error "native: no lowering for " isa)))
	    (buffer (asm-buffer (code-region-next native-region))))
	(native-assemble isa buffer (lower (cadr f)))
	(push image (cons (car f) (code-region-install native-region buffer)))))
    image))
