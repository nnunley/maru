;;; objects.law's driver natively, on eval2: check/objects-run.k, spliced after maru-gc.k and kernel.k into the unit
;;; OBJECTS_LAW_UNIT names, compiled by native.l once, and each program run in a forked child with the program on its
;;; stdin.  Loaded after objects-model.l, whose ol-real it replaces: the driver's lines, or (crash status).
(require "native.l")
(require "check/native-child.l")
(require "check/native-run.l")
(define ol-image (native-install (native-compile-file (ol-env "OBJECTS_LAW_UNIT"))))
(define-function ol-real (ops pace)
  (let* ((in (concat-strings (ol-env "OBJECTS_LAW_TMP") "/in"))
	 (f (ol-fopen in "w")))
    (or (and f (!= 0 f)) (error "objects: can't write " in))
    (list-do op ops
      (list-do x op (ol-fprintf f "%ld " x))
      (ol-fprintf f "\n"))
    (ol-fclose f)
    (let ((out (native-run-main-status ol-image (list (long->string pace)) in)))
      (if (= 0 (car out)) (cdr out) (list 'crash (car out))))))
