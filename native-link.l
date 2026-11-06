;;; native-link.l -- a unit of intents (native-gen.k) to machine code in a code region.  Globals get storage the image
;;; owns (zeroed), externs their addresses from dlsym, string literals their bytes; then each function's intents are
;;; lowered by its instruction set's grammar (native-arm64.g), encoded by the checked encoders (asm-table.l) into one
;;; buffer, with branches and function addresses patched, installed, and the globals' initialisations (__init) run.
;;;   (native-install unit)   => ((name . address) …), each function callable by subr
(define native-region (code-region-allocate 4194304))
(define native-lowerings (list (cons 'arm64 (lambda (intents) (parse-source <native-arm64> $program intents)))))

;; each intent's forms into the buffer: (at L) marks where L is, a (label L) operand is a placeholder patched to it;
;; answers the labels, (L . address) …
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
      (asm-patch isa buffer (car f) (or (cdr (assq (cdr f) labels)) (error "native: no label " (cdr f)))))
    labels))

;; the globals' storage: (name . address) …, in one zeroed block
(define-function native-data (globals)
  (let ((at 0) (offsets ()))
    (list-do g globals
      (set at (align at (max 1 (caddr g))))
      (push offsets (cons (car g) at))
      (set at (+ at (max 1 (cadr g)))))
    (let ((block ((subr "calloc" "ll>p") (+ at 16) 1)))
      (map (lambda (o) (cons (car o) (+ block (cdr o)))) offsets))))

;; symbols to addresses: a global's, a C function's, a literal's (copied out of Maru's heap, kept for the image)
(define-function native-resolve (intents data)
  (map (lambda (i)
	 (let ((op (car i)))
	   (cond ((= op 'global-address) (list 'constant (cadr i) (or (cdr (assq (caddr i) data)) (error "native: no global " (caddr i)))))
		 ((= op 'extern-address) (list 'constant (cadr i) (stub-symbol (symbol->string (caddr i)))))
		 ((= op 'string-address) (list 'constant (cadr i) ((subr "strdup" "s>p") (caddr i))))
		 (else i))))
       intents))

(define-function native-install (unit)
  (let* ((isa (stub-isa))
	 (lower (or (cdr (assq isa native-lowerings)) (error "native: no lowering for " isa)))
	 (data (native-data (<native-unit>-globals unit)))
	 (buffer (asm-buffer (code-region-next native-region)))
	 (forms ()))
    (list-do f (<native-unit>-functions unit)
      (push forms (list (list 'at (native-function-label (car f)))))
      (list-do fs (lower (native-resolve (cadr f) data)) (push forms fs)))
    (let* ((labels (native-assemble isa buffer (list-reverse! forms)))
	   (origin (asm-buffer-origin buffer))
	   (installed (code-region-install native-region buffer))
	   (image (map (lambda (f) (cons (car f) (+ installed (- (cdr (assq (native-function-label (car f)) labels)) origin))))
		       (<native-unit>-functions unit))))
      (let ((init (assq '__init image))) (and init ((subr (cdr init) ">l"))))
      image)))
