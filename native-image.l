;;; native-image.l -- a code image (native-link.l makes one) loaded into a code region, on any evaluator: no maru.k and
;;; no grammars.  An image is a Maru form:
;;;   (native-image ISA BYTES (TABLE-OFFSET ENTRY …) ((NAME . OFFSET) …) ((NAME SIZE ALIGNMENT) …))
;;; BYTES is the code, position-independent, then a table of 8-byte slots at TABLE-OFFSET; the code reaches each global,
;;; C function and string literal through its slot.  An ENTRY is (global NAME), (extern NAME) or (string BYTE …), and
;;; loading writes each slot's address into the bytes, installs them, and runs __init, which sets the globals.
;;;   (native-load-image image)   => ((name . address) …), each function callable by subr
;;;   (native-load path)          the image a file holds
(require "osdefs.k")
(require "asm-table.l")	; the buffer a code region installs
(require "code-region.l")

(define native-region (code-region-allocate 4194304))

;; the globals' storage: (name . address) …, in one zeroed block the image keeps
(define-function native-data (globals)
  (let ((at 0) (offsets ()))
    (list-do g globals
      (set at (align at (max 1 (caddr g))))
      (push offsets (cons (car g) at))
      (set at (+ at (max 1 (cadr g)))))
    (let ((block ((subr "calloc" "ll>p") (+ at 16) 1)))
      (map (lambda (o) (cons (car o) (+ block (cdr o)))) offsets))))

;; an entry's address: a global's storage, a C function in this process, or a string's bytes copied out (NUL-ended)
(define-function native-entry-address (entry data)
  (let ((kind (car entry)))
    (cond ((= kind 'global) (or (cdr (assq (cadr entry) data)) (error "native: no global " (cadr entry))))
	  ((= kind 'extern)
	   (let ((a ((subr "dlsym" "ps>p") RTLD_DEFAULT (symbol->string (cadr entry)))))
	     (if (= 0 a) (error "native: no C function " (cadr entry)) a)))
	  ((= kind 'string)
	   (let* ((bytes (cdr entry)) (p ((subr "calloc" "ll>p") (+ 1 (list-length bytes)) 1)) (k 0))
	     (list-do b bytes (set-byte-at p k b) (set k (+ k 1)))
	     p))
	  (else (error "native: no image entry " entry)))))

(define-function native-load-image (image)
  (or (= 'native-image (car image)) (error "native: not a code image"))
  (let* ((bytes (let ((a (array))) (list-do b (caddr image) (array-append a b)) a))
	 (table (cadddr image))
	 (functions (car (cddddr image)))
	 (data (native-data (cadr (cddddr image))))
	 (slot (car table)))
    (list-do entry (cdr table)	; every address is found before anything is installed
      (let ((a (native-entry-address entry data)))
	(for (k 0 8) (set-array-at bytes (+ slot k) (& 255 (>> a (* 8 k)))))
	(set slot (+ slot 8))))
    (let* ((origin (code-region-install native-region (cons (code-region-next native-region) bytes)))	; an asm buffer: origin, bytes
	   (loaded (map (lambda (f) (cons (car f) (+ origin (cdr f)))) functions)))
      (let ((init (assq '__init loaded))) (and init ((subr (cdr init) ">l"))))
      loaded)))

(define-function native-load (path)
  (let ((forms (read path)))
    (or forms (error "native: no image in " path))
    (native-load-image (car forms))))
