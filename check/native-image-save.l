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
(println "saved")
