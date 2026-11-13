;;; erosion-run.l -- ./eval erosion-run.l [--ledger FILE] [--unread FILE... --] FILE... measures the files (erosion.l) and prints
;;; their erosion and verbosity, per mille, then the ten callables of greatest mass.  With --ledger, each metric must equal
;;; the sum of the ledger's entries (erosion-ledger), and the last line says whether they do.
;;; Each file is read by Maru's own reader.  A file after --unread is one it can't read whole, as a file that changes
;;; language partway (test-pepsi.l) can't: it's not measured, and it must still fail to read, so the list doesn't outlive
;;; its reason.
;;; With --hotspots it prints only every callable over CC 10, `hotspot NAME FILE LINE CC MASS`, mass CC x sqrt(forms) to the
;;; nearest whole number: what the evidence plans minimize (doc/evidence-plan.md).
(require "erosion.l")
(require "recover.l")
(define hotspots ())
(when (and *arguments* (= "--hotspots" (car *arguments*))) (next-argument) (set hotspots 1))
(define ledger ())
(when (and *arguments* (= "--ledger" (car *arguments*))) (next-argument) (set ledger (next-argument)))
(define unread ())
(when (and *arguments* (= "--unread" (car *arguments*)))
  (next-argument)
  (while (and *arguments* (not (= "--" (car *arguments*)))) (push unread (next-argument)))
  (next-argument))
(list-do path unread
  (and (try (let () (find-and-read path) 't) (lambda (c) ()))
       (error "erosion: " path " reads whole now: measure it (take it off --unread)")))
(define sources ())
(while *arguments*
  (let ((path (next-argument)))
    (push sources (cons path (find-and-read path)))))
(define-function print-hotspots (m)
  (list-do c (<erosion-metrics>-callables m)
    (and (< 10 (<callable>-cc c))
	 (println "hotspot " (<callable>-name c) " " (<callable>-path c) " " (<callable>-line c) " " (<callable>-cc c) " "
		  (double->long (+ 0.5 (erosion-mass c)))))))
(let ((m (erosion-of (list-reverse! sources))) (ranked ()))
  (if hotspots (let () (print-hotspots m) (exit 0)))
  (println "erosion " (<erosion-metrics>-erosion m) " verbosity " (<erosion-metrics>-verbosity m))
  (println (list-length (<erosion-metrics>-callables m)) " callables, " (<erosion-metrics>-forms m) " forms, "
	   (<erosion-metrics>-flagged m) " verbose, " (list-length unread) " files not read")
  (list-do c (<erosion-metrics>-callables m)	; the ten heaviest, in order of mass
    (let ((r ()) (placed ()) (k 0))
      (list-do d ranked
	(and (not placed) (< (erosion-mass d) (erosion-mass c)) (let () (push r c) (set placed 1)))
	(push r d))
      (or placed (push r c))
      (set ranked ())
      (list-do d (list-reverse! r) (and (< k 10) (let () (push ranked d) (set k (+ k 1)))))
      (set ranked (list-reverse! ranked))))
  (list-do c ranked (println "  " c))
  (when ledger
    (let ((sums (erosion-ledger (contents-of-file-named ledger))))
      (println (if (erosion-matches? m sums)
		   "erosion matches its ledger"
		 (concat-strings ledger " accounts for erosion " (long->string (car sums)) " verbosity " (long->string (cdr sums))
				 "; add an entry for each that moved, saying why"))))))
