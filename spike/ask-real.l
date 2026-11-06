;;; THROWAWAY SPIKE.  One question to a real model through Ollama, asked from John, then read back on a second replica with no call.
;;; Send only public text: whatever goes in a prompt leaves this machine for a cloud model.
(require "spike/john-llm.l")
(define q "Reply with one word and nothing else: what is the capital of France?")
(define program (john-read-text (concat-strings
  "create City name. make City Paris \"Paris\".
   qualify City is-the-answer if its name = \"" q "\" ask.")))
(define a (replica-new 'a))
(set *john-replica* a)
(define c (chain-new a program))
(println "John on replica a: " (chain-ask c (concat-strings "\"" q "\" ask. Paris is-the-answer.")))
(println "calls after the first ask: " *llm-calls*)
(chain-ask c (concat-strings "\"" q "\" ask."))
(println "calls after asking again: " *llm-calls*)
(define b (replica-new 'b))
(replica-sync-into a b)
(set *john-replica* b)
(println "John on replica b: " (chain-ask c (concat-strings "\"" q "\" ask.")))
(println "calls after b asked: " *llm-calls*)
(exit (if (= 1 *llm-calls*) 0 1))
