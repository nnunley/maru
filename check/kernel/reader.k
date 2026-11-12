;;; The kernel's reader (doc/kernel.md), as eval3's: every datum in check/kernel/read.txt, dumped one a line, on the
;;; poisoning collector with a collection on every allocation; check/kernel.l and check.l compare the lines with
;;; check/kernel/read.expected, what ./eval3 -b boot2.l prints for the same file.  Then "kernel reader ok".

(define (fopen (void * char * char *) *) (extern fopen))

(define-function main int ((argc int) (argv char * *))
  (gc_initialise)
  (set gc_poison 165)
  (set gc_frequency 1)
  (k_initReader)
  (let (((fp void *) (fopen "check/kernel/read.txt" "r"))
	((obj oop) nil))
    (if (= fp (cast 0 void *)) (let () (printf "FAIL can't open check/kernel/read.txt\n") (exit 1)))
    (gc-protect (obj)
      (k_beginSource "check/kernel/read.txt")
      (set obj (k_readExpr fp))
      (while (!= obj k_done)
	(k_dumpln obj)
	(set obj (k_readExpr fp)))
      (k_endSource)))
  (printf "kernel reader ok\n")
  (return 0))
