;; Simple test to detect if stdin is interactive
;; We can try using input characteristics or other indicators

(println "Testing interactive detection...")

;; Method 1: Check if we can get info about stdin
(define stdin-fd 0)

;; Method 2: Try to detect based on available functions
(if (defined? 'input-stream)
    (println "input-stream available")
    (println "input-stream not available"))

;; Method 3: Check what *input* contains
(if (defined? '*input*)
    (println "*input* defined:" *input*)
    (println "*input* not defined"))

(println "Simple check complete")