;;; erosion-attribute-run.l -- ./eval erosion-attribute-run.l [REV]: how the working copy's change against REV (HEAD, or @-
;;; under jj) moved erosion and verbosity, callable by callable (erosion-attribute.l).  Advisory: it writes nothing.
(require "erosion-vcs.l")
(define rev (if *arguments* (next-argument) (if (= 'jj (vcs-kind ".")) "@-" "HEAD")))
(set *arguments* ())
(if (vcs-revision? "." rev)
    (list-do l (attribution-command-lines "." rev) (println l))
  (let () (println "erosion: no revision " rev) (exit 1)))
