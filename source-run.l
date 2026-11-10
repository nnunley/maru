;;; source-run.l -- ./eval source-run.l FILE [ARG...] runs FILE as ./eval FILE would, but through load, after source.l, so its
;;; own definitions keep their sources too (the evaluator reads the file it's given itself, before any hook; Ian named boot.l
;;; on the command line the same way: ./eval boot.l emit.l eval.l).  The arguments after FILE are its *arguments*.
(require "source.l")
(load (next-argument))
