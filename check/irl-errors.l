;;; ./eval2 ir-gen-c.k check/irl-errors.l maru.k FILE.k
;;; Prints "irl errors ok" when compiling FILE.k stops at a type mismatch in an if.
(set ir-error-type-mismatch
     (lambda (ir insn)
       (println (if (= <ir-if> (type-of insn)) "irl errors ok" "type mismatch outside an if"))
       (exit 0)))
