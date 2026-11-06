;;; native-link.l -- a unit of intents (native-gen.k) to a code image (native-image.l).  Each function's intents are
;;; lowered by its instruction set's grammar (native-arm64.g) and encoded by the checked encoders (asm-table.l) into one
;;; buffer, with branches and function addresses patched; a global's, C function's or string literal's address is read
;;; from a table of slots after the code, so the code is position-independent and loading only fills the table.
;;;   (native-image-of unit)     => an image, the form native-image.l loads
;;;   (native-install unit)      => ((name . address) …), each function callable by subr
;;;   (native-save unit path)    the image written to a file, for (native-load path) on any evaluator
(require "native-image.l")
(define native-lowerings (list (cons 'arm64 (lambda (intents) (parse-source <native-arm64> $program intents)))))

;; each intent's forms into the buffer: (at L) marks where L is, a (label L) operand is a placeholder patched to it, and
;; the table's labels name 8-byte slots from the first 8-byte boundary after the code; answers the labels, (L . address) …
(define-function native-table-label (k) (string->symbol (concat-string "tab." (long->string k))))
(define-function native-assemble (isa buffer intents nslots)
  (let ((labels ()) (fixups ()))
    (list-do forms intents
      (list-do form forms
	(if (= 'at (car form))
	    (push labels (cons (cadr form) (asm-buffer-pc buffer)))
	  (let* ((label (list-detect op (cdr form) (and (pair? op) (= 'label (car op)))))
		 (reports (asm isa buffer (if label (map (lambda (op) (if (= op label) '(reloc) op)) form) form))))
	    (and label (push fixups (cons (car reports) (cadr label))))))))
    (let ((table (align (asm-buffer-pc buffer) 8)))
      (for (k 0 nslots) (push labels (cons (native-table-label k) (+ table (* 8 k))))))
    (list-do f fixups
      (asm-patch isa buffer (car f) (or (cdr (assq (cdr f) labels)) (error "native: no label " (cdr f)))))
    labels))

;; a string literal's bytes; the table copies them out of Maru's heap
(define-function native-string-bytes (s)
  (let ((out ()))
    (for (i 0 (string-length s))
      (let ((c (string-at s i))) (if (< c 128) (push out c) (error "native: a string literal beyond ASCII: " s))))
    (list-reverse! out)))

;; an entry's slot number, if the table has it
(define-function native-entry-index (entry entries)
  (let ((k ())) (list-do e entries (and (equal (car e) entry) (set k (cdr e)))) k))
;; a symbol's address read from its table slot: (global NAME), (extern NAME) or (string BYTE …), each entry once;
;; answers the functions with their intents rewritten, and the table's entries in slot order
(define-function native-symbols (functions)
  (let ((entries ()) (n 0) (out ()))
    (list-do f functions
      (let ((intents ()))
	(list-do i (cadr f)
	  (let* ((op (car i))
		 (entry (cond ((= op 'global-address) (list 'global (caddr i)))
			      ((= op 'extern-address) (list 'extern (caddr i)))
			      ((= op 'string-address) (cons 'string (native-string-bytes (caddr i)))))))
	    (if entry
		(let ((k (native-entry-index entry entries)))
		  (unless k (push entries (cons entry n)) (set k n) (set n (+ n 1)))
		  (push intents (list 'label-address (cadr i) (native-table-label k)))
		  (push intents (list 'load-at 8 (cadr i) (cadr i))))
	      (push intents i))))
	(push out (list (car f) (list-reverse! intents)))))
    (let ((slots ())) (list-do e entries (push slots (car e))) (cons (list-reverse! out) slots))))

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
      (list 'native-image isa
	    (let ((l ())) (for (i 0 (array-length bytes)) (push l (array-at bytes i))) (list-reverse! l))
	    (cons table entries)
	    (let ((fs ())) (list-do f (<native-unit>-functions unit) (push fs (cons (car f) (cdr (assq (native-function-label (car f)) labels))))) fs)
	    (<native-unit>-globals unit)))))

(define-function native-install (unit) (native-load-image (native-image-of unit)))

;; an image as Maru text: numbers, symbols and lists are all it holds
(define-function native-form-text (x)
  (cond ((pair? x)
	 (let ((s "(") (first 1))
	   (while (pair? x)
	     (set s (concat-string s (concat-string (if first "" " ") (native-form-text (car x)))))
	     (set first ())
	     (set x (cdr x)))
	   (concat-string s (if x (concat-string " . " (concat-string (native-form-text x) ")")) ")"))))
	((= x ()) "()")
	((long? x) (long->string x))
	((symbol? x) (symbol->string x))
	(else (error "native: an image holds no " x))))
(define-function native-save (unit path) (contents-to-file-named (native-form-text (native-image-of unit)) path))
