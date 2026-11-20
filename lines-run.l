;;; lines-run.l -- ./eval lines-run.l [LEDGER]: the source lines the lines check counts (erosion-files.l) against the sum of
;;; the ledger's lines entries (check/ledger, ledger.l, includes read).  Prints the count, or a FAIL line naming the
;;; difference, which the lines check raises.
(require "erosion-files.l")
(require "ledger.l")
(define ledger (if *arguments* (next-argument) "check/ledger"))
(set *arguments* ())
(define counted (counted-lines "."))
(define read (ledger-read (contents-of-file-named ledger)))	; (sums . notes): an include's file that moved since its summary
(list-do n (cdr read) (println "note: " n))
(define accounted (car (car read)))
(if (= counted accounted)
    (println "lines: " counted ", tests included; the budget of 20000 is soft")
  (println "FAIL lines: " counted " source lines, but " ledger " accounts for " accounted "; add an entry for "
	   (- counted accounted) " saying why"))
