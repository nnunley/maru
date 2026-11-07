;;; schedule.law's support: stand-ins with the runtime's shapes, so the law's claim is the one written for the runtime.
(define-function sched_width (k) (if (equal k "words") 12 5))
(define-function rt_glyphs (n s) (list n s))
(define-function layout (k w lw g) (list k w lw g))
(define-function scheduled (k w lw g s) (law-record "contracts" (list 0 0 0 0) "output" (layout k 1 lw g)))
