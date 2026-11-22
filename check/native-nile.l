;;; The Nile runtime and Gezira's kernels compiled natively in one unit and made a code image, on eval2.  LOADER loads
;;; the unit's files in order (nile.osdefs measured for this host, the runtime, gezira.k, gezira-image.k, gezira-api.k).
;;; The last line is "native nile ok" once the image holds every entry point gezira-api.k exports; check.l bounds the time
;;; against the C back end's on the same files.
;;; With IMAGE, the image is saved there too (native-save), for check/gezira-pixels.l to draw with.
;;;   ./eval2 check/native-nile.l LOADER [IMAGE]
(define loader (pop *arguments*))	; before native.l: maru.k loads any arguments left
(define save-to (and *arguments* (pop *arguments*)))	; IMAGE: where to save the image, for check/gezira-pixels.l
(require "native.l")
(define unit (native-compile-file loader))
(define image (native-image-of unit))
(and save-to (native-save unit save-to))
(define functions (car (cddr (cdddr image))))
(println "native nile: " (list-length (cadddr image)) " bytes, " (list-length functions) " functions")
(list-do name '(gezira_start gezira_stop gezira_image_new gezira_image_free gezira_image_clear gezira_pixel gezira_fill
		gezira_fill_image gezira_downsample gezira_premultiply)
  (or (long? (cdr (assq name functions))) (error "native-nile: the image has no " name)))
(println "native nile ok")
