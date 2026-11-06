;;; Code images: check/native/add.k, flow.k and image.k compiled on eval2 and saved to DIR/add.image, flow.image and
;;; image.image, for check/native-image.l to load on any evaluator.   ./eval2 check/native-image-save.l DIR
(define dir (pop *arguments*))	; before native.l: maru.k loads any arguments left
(require "native.l")
(native-save (native-compile-file "check/native/add.k") (concat-string dir "/add.image"))
(native-save (native-compile-file "check/native/flow.k") (concat-string dir "/flow.image"))
(native-save (native-compile-file "check/native/image.k") (concat-string dir "/image.image"))
(println "saved")
