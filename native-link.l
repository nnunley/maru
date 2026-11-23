;;; native-link.l -- a unit of intents (native-gen.k) to a code image (native-image.l).  Each function's intents are
;;; lowered by its instruction set's grammar (native-arm64.g) and encoded by the checked encoders (asm-table.l) into one
;;; buffer, with branches and function addresses patched; a global's, C function's or string literal's address is read
;;; from a table of slots after the code, so the code is position-independent and loading only fills the table.
;;;   (native-image-of unit)     => an image, the form native-image.l loads
;;;   (native-install unit)      => ((name . address) …), each function callable by subr
;;;   (native-save unit path)    the image written to a file, for (native-load path) on any evaluator
(require "native-image.l")
(define native-lowerings (list (cons 'arm64 (lambda (intents) (parse-source <native-arm64> $program intents)))
			       (cons 'x64 (lambda (intents) (parse-source <native-x64> $program intents)))))

;; a form's (label L) operand, or one that is a memory operand's displacement (x64's RIP-relative LEA), and the form
;; with it a placeholder
(define-function native-label? (op) (and (pair? op) (= 'label (car op))))
(define-function native-form-label (form)
  (let ((found ()))
    (list-do op (cdr form)
      (cond ((native-label? op) (set found op))
	    ((and (pair? op) (native-label? (cadr op))) (set found (cadr op)))))
    found))
(define-function native-form-reloc (form label)
  (cons (car form) (map (lambda (op) (cond ((= op label) '(reloc))
					   ((and (pair? op) (= (cadr op) label)) (cons (car op) (cons '(reloc) (cddr op))))
					   (else op)))
			(cdr form))))
;; each intent's forms into the buffer: (at L) marks where L is, a (label L) operand is a placeholder patched to it, and
;; the table's labels name 8-byte slots from the first 8-byte boundary after the code; answers the labels, a table by
;; identity from each label to its address (a list searched for each label and branch made a unit's assembly quadratic)
(define-function native-table-label (k) (string->symbol (concat-string "tab." (long->string k))))
(define-function native-place-form (isa buffer labels form)	; form into the buffer: a fixup (report . label), or ()
  (cond
    ((= 'data (car form))	; a site's bytes (asm-arm64.l's arm64-site), 0..255 as it made them: placed as they are
     (list-do b (cdr form) (array-append (asm-buffer-bytes buffer) b)))
    ((= 'label-data (car form))	; a label site's (label-data BYTES POSITION ROW INSN L): its bytes, and asm's report
     (let ((offset (array-length (asm-buffer-bytes buffer))) (more (cddddr form)))
       (list-do b (cadr form) (array-append (asm-buffer-bytes buffer) b))
       (cons (list (caddr form) offset (cadddr form) (car more)) (cadr more))))
    ((= 'at (car form))
     (if (hash-includes? labels (cadr form))
	 (error "native: label " (cadr form) " defined twice")
       (hash-at-put labels (cadr form) (asm-buffer-pc buffer)))
     ())
    (else
     (let* ((label (native-form-label form))
	    (reports (asm isa buffer (if label (native-form-reloc form label) form))))
       (and label (cons (car reports) (cadr label)))))))
(define-function native-assemble (isa buffer intents nslots)
  (let ((isa (asm-isa isa)) (labels (identity-hash-table)) (fixups ()))	; the instruction set found once, not per form
    (list-do forms intents
      (list-do form forms
	(let ((f (native-place-form isa buffer labels form))) (and f (push fixups f)))))
    (let ((table (align (asm-buffer-pc buffer) 8)))
      (for (k 0 nslots) (hash-at-put labels (native-table-label k) (+ table (* 8 k)))))
    (list-do f fixups
      (asm-patch isa buffer (car f) (or (hash-at labels (cdr f)) (error "native: no label " (cdr f)))))
    labels))

;; a string literal's bytes; the table copies them out of Maru's heap
(define-function native-string-bytes (s)
  (let ((out ()))
    (for (i 0 (string-length s))
      (let ((c (string-at s i))) (if (< c 128) (push out c) (error "native: a string literal beyond ASCII: " s))))
    (list-reverse! out)))

;; a symbol's address read from its table slot: (global NAME), (extern NAME) or (string BYTE …), each entry once, its slot
;; found by equal in a table (hash.l) where a list searched for each made a unit's strings and externs quadratic;
;; answers the functions with their intents rewritten, and the table's entries in slot order.  An extern the unit
;; defines (nile.k declares the runtime's interface, nile-builtins.k defines it) is the unit's own function, as C's
;; linker binds it, not a C symbol looked up as the image loads.
(define-function native-symbols (functions)
  (let ((slots (equal-hash-table)) (out ()) (own (identity-hash-table)))
    (list-do f functions (hash-at-put own (car f) 1))
    (list-do f functions
      (let ((intents ()))
	(list-do i (cadr f)
	  (let* ((op (car i))
		 (i (if (and (= op 'extern-address) (hash-at own (caddr i))) (list 'function-address (cadr i) (caddr i)) i))
		 (op (car i))
		 (entry (cond ((= op 'global-address) (list 'global (caddr i)))
			      ((= op 'extern-address) (list 'extern (caddr i)))
			      ((= op 'string-address) (cons 'string (native-string-bytes (caddr i)))))))
	    (if entry
		(let ((k (or (cdr (hash-entry slots entry)) (hash-at-put slots entry (hash-count slots)))))
		  (push intents (list 'label-address (cadr i) (native-table-label k)))
		  (push intents (list 'load-at 8 (cadr i) (cadr i))))
	      (push intents i))))
	(push out (list (car f) (list-reverse! intents)))))
    (cons (list-reverse! out) (array->list (hash-keys slots)))))

(define-function native-image-of (unit)
  (let* ((isa (stub-isa))
	 (lower (or (cdr (assq isa native-lowerings)) (error "native: no lowering for " isa)))
	 (symbols (native-symbols (<native-unit>-functions unit)))
	 (entries (cdr symbols))
	 (buffer (asm-buffer 0))
	 (table 0)
	 (forms ()))
    (list-do f (car symbols)
      (push forms (list (list 'at (native-function-label (car f)))))
      (list-do fs (lower (cadr f)) (push forms fs)))
    (let ((labels (native-assemble isa buffer (list-reverse! forms) (list-length entries)))
	  (bytes (asm-buffer-bytes buffer)))
      (set table (align (array-length bytes) 8))
      (while (< (array-length bytes) (+ table (* 8 (list-length entries)))) (array-append bytes 0))
      (list 'native-image isa (cdr native-host)
	    (let ((l ())) (for (i 0 (array-length bytes)) (push l (array-at bytes i))) (list-reverse! l))
	    (cons table entries)
	    (let ((fs ())) (list-do f (<native-unit>-functions unit) (push fs (cons (car f) (hash-at labels (native-function-label (car f)))))) fs)
	    (<native-unit>-globals unit)))))

(define-function native-install (unit) (native-load-image (native-image-of unit)))

;; an image as Maru text: numbers, symbols and lists are all it holds.  The characters go into one array, made a string
;; once, so the time is linear in the text: a string grown by concat-string is copied whole at every step, which for an
;; image's hundred thousand bytes is hours
(define-function native-text-append (out s)
  (for (i 0 (string-length s)) (array-append out (string-at s i))))
(define-function native-form-chars (x out)
  (cond ((pair? x)
	 (native-text-append out "(")
	 (native-form-chars (car x) out)
	 (set x (cdr x))
	 (while (pair? x)
	   (native-text-append out " ")
	   (native-form-chars (car x) out)
	   (set x (cdr x)))
	 (when x (native-text-append out " . ") (native-form-chars x out))
	 (native-text-append out ")"))
	((= x ()) (native-text-append out "()"))
	((long? x) (native-text-append out (long->string x)))
	((symbol? x) (native-text-append out (symbol->string x)))
	(else (error "native: an image holds no " x))))
(define-function native-form-text (x) (let ((out (array))) (native-form-chars x out) (array->string out)))
(define-function native-save (unit path) (contents-to-file-named (native-form-text (native-image-of unit)) path))
