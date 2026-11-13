;;; The kernel (doc/kernel.md) natively: each check unit in check/kernel/, after maru-gc.k (less its main) and kernel.k,
;;; compiled by native.l and its main run in a child.  Runs on eval2.  Prints each unit's last line, then "kernel ok".
(require "native.l")
(require "check/native-child.l")
(require "check/native-run.l")

;; one unit for all the check files, so the kernel compiles once a mode: maru-gc.k up to its real main, the integers'
;; mode (kernel-tagged-int, boxed unless the prefix says), kernel.k's sections, then each check with its main renamed
;; main_NAME, and a main that runs the one its first argument names
(define kernel-units '("objects" "longs" "lists" "reader" "eval"))
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

;; a file's lines, then a unit's last line: what ./eval3 -b boot2.l prints, kept in check/kernel/*.expected
(define-function kernel-expected (path last-line)
  (let ((text (contents-of-file-named path)) (out ()) (start 0) (i 0))
    (while (< i (string-length text))
      (and (= 10 (string-at text i)) (let () (push out (string-copy text start (- i start))) (set start (+ i 1))))
      (set i (+ i 1)))
    (list-reverse! (cons last-line out))))
(define kernel-reader-printed (kernel-expected "check/kernel/read.expected" "kernel reader ok"))
(define kernel-eval-printed (kernel-expected "check/kernel/eval.expected" "kernel eval ok"))

;; a unit's lines less maru-gc.k's "N collections" progress lines (its gcdebug, on as Piumarta left it), which a unit
;; that collects on every allocation prints, until kernel-gc.k replaces maru-gc.k in the kernel
(define-function kernel-gc-line? (l)
  (let ((i 0))
    (while (and (< i (string-length l)) (<= ?0 (string-at l i)) (<= (string-at l i) ?9)) (set i (+ i 1)))
    (and (< 0 i) (= (- (string-length l) i) 12) (prefix-at? " collections" l i))))
(define-function kernel-run (image unit)
  (let ((out ())) (list-do l (native-run-main image (list unit)) (or (kernel-gc-line? l) (push out l))) (list-reverse! out)))

;; each unit with integers boxed (eval3 as built), then tagged (its TAG_INT)
(list-do mode '(("" . "boxed") ("\n(define kernel-tagged-int 1)" . "tagged"))
  (let ((tag (concat-string " " (cdr mode)))
	(image (kernel-image (car mode))))
    (expect (concat-string "check/kernel/objects.k" tag) (last (native-run-main image '("objects"))) "kernel objects ok")
    (expect (concat-string "check/kernel/longs.k" tag) (last (native-run-main image '("longs"))) "kernel longs ok")
    (expect (concat-string "check/kernel/lists.k" tag) (native-run-main image '("lists")) kernel-lists-printed)
    (expect (concat-string "check/kernel/reader.k" tag) (native-run-main image '("reader")) kernel-reader-printed)
    (expect (concat-string "check/kernel/eval.k" tag) (kernel-run image "eval") kernel-eval-printed)))

(println (if ok "kernel ok" "kernel FAILED"))
