;;; Each unit compiled natively and saved as its image's text to DIR/NAME.image, so native code can be compared across a
;;; change byte for byte: the units check/native.l compiles that aren't meant to be refused, and, given a loader (as
;;; native_nile writes one), the Nile runtime and Gezira as DIR/gezira.image.  --no-sites lowers without staged sites.
;;; The last line is "images N".
;;;   ./eval2 check/native-images.l [--no-sites] DIR [LOADER]
(define no-sites (and *arguments* (equal "--no-sites" (car *arguments*)) (pop *arguments*)))
(define dir (pop *arguments*))
(define loader (and *arguments* (pop *arguments*)))	; before native.l: maru.k loads any arguments left
(require "native.l")
(load "check/native-image-units.l")
(define count 0)
(define-function save (unit name)
  (native-save unit (concat-string dir (concat-string "/" (concat-string name ".image"))))
  (set count (+ count 1)))
(native-image-each (lambda (path name) (save (native-compile-file path) name)))
(and loader (save (native-compile-file loader) "gezira"))
(println "images " count)
