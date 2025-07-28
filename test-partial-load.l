;; Test loading emit.l in parts to find where it breaks

;; Function to test loading first N lines
(define-function test-lines (n)
  (println "Testing first " n " lines...")
  (let ((input (open-input-file "core/compiler/emit.l"))
        (output (open-output-file "temp-partial.l"))
        (count 0))
    (if (and input output)
        (let ((line (read-line input)))
          (while (and line (< count n))
            (println line output)
            (set line (read-line input))
            (set count (+ count 1)))
          (close-input-port input)
          (close-output-port output)
          
          ;; Try to load the partial file
          (let ((result (catch (lambda () (load "temp-partial.l") 1) (lambda (err) ()))))
            (if result
                (println "SUCCESS: First " n " lines load correctly")
                (println "FAILURE: First " n " lines failed to load"))))
        (println "Error: Could not open files"))))

;; Test progressively larger chunks
(test-lines 100)
(test-lines 200)
(test-lines 300)
(test-lines 400)
(test-lines 500)
(test-lines 600)