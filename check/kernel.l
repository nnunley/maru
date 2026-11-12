;;; The kernel (doc/kernel.md) natively: each check unit in check/kernel/, after maru-gc.k (less its main) and kernel.k,
;;; compiled by native.l and its main run in a child.  Runs on eval2.  Prints each unit's last line, then "kernel ok".
(require "native.l")
(require "check/native-child.l")
(require "check/native-run.l")

;; the unit for a check file: maru-gc.k up to its real main, then kernel.k's sections, then the check's main
(define-function kernel-unit (check)
  (let* ((gc (contents-of-file-named "maru-gc.k"))
	 (main (let ((i 0)) (while (not (prefix-at? "\n(define-function main " gc i)) (set i (+ i 1))) i))
	 (path (concat-string check-tmp "/kernel-unit.k")))
    (contents-to-file-named (concat-string (concat-string (string-copy gc 0 main) "\n(load \"kernel.k\")\n")
					   (contents-of-file-named check))
			    path)
    path))

(define-function kernel-run (check args)
  (let* ((path (kernel-unit check))
	 (out (native-run-main (native-install (native-compile-file path)) args)))
    ((subr "unlink" "s>i") path)
    out))

(let ((out (kernel-run "check/kernel/objects.k" ())))
  (expect "check/kernel/objects.k" (last out) "kernel objects ok"))

;; the lines eval3 -b boot2.l prints for the same structures
(define kernel-lists-printed
  '("(he\"l\\lo sym -42 3.500000 () Array<3>(1 () s) (1 . 2) Array<0>())"
  "(\"he\\\"l\\\\lo\" sym -42 3.500000 () Array<3>(1 () \"s\") (1 . 2) Array<0>())"
  "\"tab\\011here\"" "((quote . 7))" "kernel lists ok"))
(expect "check/kernel/lists.k" (kernel-run "check/kernel/lists.k" ()) kernel-lists-printed)

(println (if ok "kernel ok" "kernel FAILED"))
