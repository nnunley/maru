;;; compile-irl-library.l -- an irl library to C in one process (draft-ndn-maru-sat-00 [R-native])
;;;
;;;   ./eval2 compile-irl-library.l <a>.irl <b>.irl ... > <lib>.c
;;;
;;; The irl files are read to maru.k forms, which stay in memory; then the typed compiler
;;; (ir-gen-c.k and maru.k) is loaded and compiles those forms as one program with no main.
;;; Only the C compiler runs outside, after this.  The forms are read first: maru.k redefines
;;; forms (let*, define-function ...) that compile-irl.l's own code must not see.

(define *irl-library-files*
  (let ((out ()))
    (while *arguments* (push out (next-argument)))
    (list-reverse! out)))

(require "compile-irl.l")	; no arguments left: definitions only
(define *irl-library-program* (irl-library-forms *irl-library-files*))

(load "ir-gen-c.k")
(load "maru.k")			; likewise

(compile-begin)
(list-do form *irl-library-program* (eval form))
(compile-end)
