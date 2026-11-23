;;; The units whose native images the checks compare (check/native-images.l, check/tpeg-direct.l): check/native.l's,
;;; by directory, but for those it requires refused.
(define native-image-units
  '(("" "maru-gc" "maru-check" "maru-label" "maru-test") ("check/" "ir2" "zero-global")
    ("check/native/" "add" "calls" "floats" "flow" "image" "labels" "memory" "objects-get-function" "stack" "structs")))
(define-function native-image-each (f)	; (f path name) for each unit
  (list-do d native-image-units
    (list-do name (cdr d) (f (concat-string (car d) (concat-string name ".k")) name))))
(define-function native-image-paths ()
  (let ((out ())) (native-image-each (lambda (path name) (push out path))) (list-reverse! out)))
