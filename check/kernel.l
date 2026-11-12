;;; The kernel (doc/kernel.md) natively: each check unit in check/kernel/, after maru-gc.k (less its main) and kernel.k,
;;; compiled by native.l and its main run in a child.  Runs on eval2.  Prints each unit's last line, then "kernel ok".
(require "native.l")
(require "check/native-child.l")
(require "check/native-run.l")

;; one unit for all the check files, so the kernel compiles once a mode: maru-gc.k up to its real main, the integers'
;; mode (kernel-tag-int, boxed unless the prefix says), kernel.k's sections, then each check with its main renamed
;; main_NAME, and a main that runs the one its first argument names
(define kernel-units '("objects" "longs" "lists"))
(define-function kernel-unit (prefix)
  (let* ((gc (contents-of-file-named "maru-gc.k"))
	 (main (let ((i 0)) (while (not (prefix-at? "\n(define-function main " gc i)) (set i (+ i 1))) i))
	 (text (concat-string (concat-string (string-copy gc 0 main) prefix) "\n(load \"kernel.k\")\n"))
	 (path (concat-string check-tmp "/kernel-unit.k")))
    (list-do u kernel-units
      (let* ((src (contents-of-file-named (concat-string (concat-string "check/kernel/" u) ".k")))
	     (at (let ((i 0)) (while (not (prefix-at? "(define-function main " src i)) (set i (+ i 1))) i)))
	(set text (concat-strings text (string-copy src 0 at) "(define-function main_" u " "
				  (string-copy src (+ at 21) (- (string-length src) (+ at 21))) "\n"))))
    (set text (concat-string text "(define (strcmp (int char * char *) *) (extern strcmp))\n(define-function main int ((argc int) (argv char * *))\n"))
    (list-do u kernel-units
      (set text (concat-strings text "  (if (= 0 (strcmp (indir argv 1) \"" u "\")) (return (main_" u " argc argv)))\n")))
    (contents-to-file-named (concat-string text "  (return 2))\n") path)
    path))

;; each unit's lines, from one image
(define-function kernel-image (prefix)
  (let* ((path (kernel-unit prefix))
	 (image (native-install (native-compile-file path))))
    ((subr "unlink" "s>i") path)
    image))

;; the lines eval3 -b boot2.l prints for check/kernel/lists.k's structures
(define kernel-lists-printed
  '("(he\"l\\lo sym -42 3.500000 () Array<3>(1 () s) (1 . 2) Array<0>())"
  "(\"he\\\"l\\\\lo\" sym -42 3.500000 () Array<3>(1 () \"s\") (1 . 2) Array<0>())"
  "\"tab\\011here\"" "((quote . 7))" "kernel lists ok"))

;; each unit with integers boxed (eval3 as built), then tagged (its TAG_INT)
(list-do mode '(("" . "boxed") ("\n(define kernel-tag-int 1)" . "tagged"))
  (let ((tag (concat-string " " (cdr mode)))
	(image (kernel-image (car mode))))
    (expect (concat-string "check/kernel/objects.k" tag) (last (native-run-main image '("objects"))) "kernel objects ok")
    (expect (concat-string "check/kernel/longs.k" tag) (last (native-run-main image '("longs"))) "kernel longs ok")
    (expect (concat-string "check/kernel/lists.k" tag) (native-run-main image '("lists")) kernel-lists-printed)))

(println (if ok "kernel ok" "kernel FAILED"))
