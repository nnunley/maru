(println "Before loading emit.l")
(handler-case
  (require "emit.l")
  (error (e) (println "Error loading emit.l: " e)))
(println "After loading emit.l")