;;; The Nile runtime and Gezira's kernels compiled natively in one unit and made a code image, on eval2.  LOADER loads
;;; the unit's files in order (nile.osdefs measured for this host, the runtime, gezira.k, gezira-image.k, gezira-api.k).
;;; The last line is "native nile ok" once the image holds every entry point gezira-api.k exports; check.l bounds the time
;;; against the C back end's on the same files.
;;;   ./eval2 check/native-nile.l LOADER
(define loader (pop *arguments*))	; before native.l: maru.k loads any arguments left
(require "native.l")
(define image (native-image-of (native-compile-file loader)))
(define functions (car (cddr (cdddr image))))
(println "native nile: " (list-length (cadddr image)) " bytes, " (list-length functions) " functions")
(list-do name '(gezira_start gezira_stop gezira_image_new gezira_image_free gezira_image_clear gezira_pixel gezira_fill
		gezira_fill_image gezira_downsample gezira_premultiply)
  (or (long? (cdr (assq name functions))) (error "native-nile: the image has no " name)))
(println "native nile ok")
