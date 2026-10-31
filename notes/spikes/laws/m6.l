(load "notes/spikes/laws/gen.l")
(load "notes/spikes/laws/nile-load.l")
(load "notes/spikes/laws/placeholders.l")
(set *parser-init* (lambda (p) (set (oop-at p 6) 0)))
(load "nile/compilers/maru/maru/print-structure.l")
(list-do s '("(u:Vector) ∙ (v:Vector) : Real\n   {e}\n"
	     "a:Number \\{op} b:Number : {t}\n"
	     "Scale (s:Real) : Real >> Real\n    ∀ x\n        >> x {f} s\n")
  (let ((r (parses <nile-parser> 'start (placeholders s))))
    (print "nile  ") (dump (placeholders s)) (println (if r "  parses" "  FAILS"))
    (and r (let () (print-structure (car r) 4) (println)))))
