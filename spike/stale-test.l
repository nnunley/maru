;;; THROWAWAY SPIKE.  A John qualification reads the store; a merge changes the winner with no new event.  John keeps qualifications
;;; per world, so without care the old answer stays cached, and two replicas' answers would depend on when they asked.
(require "spike/john-llm.l")
(define failures 0)
(define-function check-that (name ok) (println (if ok "ok   " "FAIL ") name) (or ok (set failures (+ failures 1))))
(define program (john-read-text "create C x. make C A 1. qualify C mode \"mode\" shared."))
(define a (replica-new 'a))  (define z (replica-new 'z))
(set *john-replica* a)
(replica-write a "mode" "from a")
(define late (replica-write z "mode" "from z"))	; concurrent, same clock: z's wins on the tie
(define c (chain-new a program))
(chain-refresh c)
(check-that "before the merge, a reads its own write" (equal '("from a") (chain-ask c "A mode.")))
(replica-receive a late)
(chain-refresh c)
(check-that "after the merge, the same question reads the new winner" (equal '("from z") (chain-ask c "A mode.")))
(println "failures " failures)
(exit (if (= 0 failures) 0 1))
