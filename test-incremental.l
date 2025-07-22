;;; Test loading emit.l incrementally

(println "Loading first 100 lines...")
(load-lines "emit.l" 1 100)
(println "Success")

(println "Loading lines 100-200...")
(load-lines "emit.l" 100 200)
(println "Success")

(println "Loading lines 200-300...")
(load-lines "emit.l" 200 300)
(println "Success")