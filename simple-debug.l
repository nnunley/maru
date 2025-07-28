;; Simple debug tool to find parentheses issues in emit.l

;; Simple function to read lines and count parens
(define-function simple-analyze (filename)
  (println "Analyzing " filename " for parentheses balance...")
  (let ((total-depth 0)
        (line-num 0)
        (problems ()))
    
    ;; Simple line-by-line analysis
    (let ((input (open filename "r")))
      (if input
          (let ((line (read-line input)))
            (while line
              (set line-num (+ line-num 1))
              (let ((open-count 0)
                    (close-count 0)
                    (i 0)
                    (len (string-length line))
                    (in-string nil))
                
                ;; Count parens on this line
                (while (< i len)
                  (let ((c (string-at line i)))
                    (if (= c #\")
                        (set in-string (not in-string)))
                    (if (and (not in-string) (= c #\())
                        (set open-count (+ open-count 1)))
                    (if (and (not in-string) (= c #\)))
                        (set close-count (+ close-count 1)))
                    (set i (+ i 1))))
                
                (let ((line-balance (- open-count close-count)))
                  (set total-depth (+ total-depth line-balance))
                  
                  ;; Report significant imbalances
                  (if (or (> (+ open-count close-count) 5) (< total-depth 0))
                      (println "Line " line-num ": open=" open-count " close=" close-count " depth=" total-depth))))
              
              (set line (read-line input))))
        (println "Error: Could not open file")))
    
    (println)
    (println "Final parentheses depth: " total-depth)
    (if (not (= total-depth 0))
        (println "ERROR: File has unbalanced parentheses!"))))

;; Run the analysis
(simple-analyze "core/compiler/emit.l")