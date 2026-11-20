;;; Code images: check/native/add.k, flow.k and image.k compiled on eval2 and saved to DIR/add.image, flow.image and
;;; image.image, for check/native-image.l to load on any evaluator.   ./eval2 check/native-image-save.l DIR
;;; An image's text is written in time linear in its size: one of 100,000 bytes (the Nile runtime's is 144,820) is
;;; written to DIR/long.text and reads back equal, inside the case's two minutes.
(define dir (pop *arguments*))	; before native.l: maru.k loads any arguments left
(require "native.l")
(native-save (native-compile-file "check/native/add.k") (concat-string dir "/add.image"))
(native-save (native-compile-file "check/native/flow.k") (concat-string dir "/flow.image"))
(native-save (native-compile-file "check/native/image.k") (concat-string dir "/image.image"))
(let ((bytes ()) (path (concat-string dir "/long.text")))
  (for (i 0 100000) (push bytes (& i 255)))
  (let ((image (list 'native-image 'arm64 'Darwin bytes '(0) () ())))
    (contents-to-file-named (native-form-text image) path)
    (or (equal (find-and-read path) (list image)) (error "native-image-save: a long image's text reads back changed"))))
;; Finding a table entry's slot and a label's address takes no longer however many there are: four times the string
;; literals, or the labels, take less than eight times as long (a list searched for each made them quadratic, and
;; the Nile runtime's image spent seconds there)
(define clock (subr "clock" ">l"))
(define-function strings-unit (n)	; one function reading n distinct string literals: n entries in the table
  (let ((intents ()))
    (for (i 0 n) (push intents (list 'string-address 's0 (concat-string "s" (long->string i)))))
    (list (list 'f intents))))
(define-function labels-forms (n)	; n labels, each the target of a branch
  (let ((forms ()))
    (for (i 0 n)
      (let ((l (string->symbol (concat-string "L" (long->string i)))))
	(push forms (list (list 'B (list 'label l))))
	(push forms (list (list 'at l)))))
    forms))
(define-function cpu-time-of (thunk) (let ((t (clock))) (thunk) (- (clock) t)))
(define-function grows-linearly (what n f)
  (f n)	; warm: the grammars' and tables' first use
  (let ((small (cpu-time-of (lambda () (f n)))) (large (cpu-time-of (lambda () (f (* 4 n))))))
    (or (< large (* 8 (+ small 1000)))
	(error "native-image-save: " what " for " (* 4 n) " took " large " us, for " n " " small " us"))))
(grows-linearly "native-symbols" 200 (lambda (n) (native-symbols (strings-unit n))))
(grows-linearly "native-assemble" 500 (lambda (n) (native-assemble (stub-isa) (asm-buffer 0) (labels-forms n) 0)))
(println "saved")
