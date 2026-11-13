;;; The files Maru's own reader can't read whole (each changes language partway, or is broken): erosion doesn't measure
;;; them, and they must still fail to read.  The erosion case and the plans' Erosion measure (notes/plan/probes.l) use it.
(define erosion-unread '("compile.l" "gen-asm-x86.k" "maruby.l" "net/structure-diagram.k" "test-pepsi.l" "test-recursion.l"
			 "test-repl.l" "test.l"))
