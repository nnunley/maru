;;; erosion-run.l -- ./eval erosion-run.l [--ledger FILE] [--unread FILE... --] FILE... measures the files (erosion.l) and prints
;;; their erosion and verbosity, per mille, then the ten callables of greatest mass.  With --ledger, each metric must equal
;;; the sum of the ledger's entries (erosion-ledger), and the last line says whether they do.
;;; Each file is read by its own reader (erosion-read-file): a .g file by tpeg, a script tpeg-repl.l reads by it, any other
;;; by Maru's.  A file after --unread is one it can't read whole, as a file that changes language partway (test-pepsi.l)
;;; or is broken on purpose (check/tpeg-broken.g) can't: it's not measured, and it must still fail to read, so the list
;;; doesn't outlive its reason.
(require "erosion.l")
(require "recover.l")
(define ledger ())
(when (and *arguments* (= "--ledger" (car *arguments*))) (next-argument) (set ledger (next-argument)))
(define unread ())
(when (and *arguments* (= "--unread" (car *arguments*)))
  (next-argument)
  (while (and *arguments* (not (= "--" (car *arguments*)))) (push unread (next-argument)))
  (next-argument))
(list-do path unread
  (and (try (let () (erosion-read-file path) 't) (lambda (c) ()))
       (error "erosion: " path " reads whole now: measure it (take it off --unread)")))
(define sources ())
(while *arguments*
  (let ((path (next-argument)))
    (push sources (cons path (erosion-read-file path)))))
(let ((m (erosion-of (list-reverse! sources))) (ranked ()))
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
