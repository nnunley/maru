;;; simple-x86-test.l - Simple test to understand the parsing issue

(require "text-parser.l")

;; Simple manual test
(define-function test-manual-parsing ()
  "Test basic string matching manually"
  (println "=== Manual Parsing Test ===")
  
  ;; Test basic string matching
  (let ((parser (text-parser-for-on <text-parser> "%rax")))
    (println "Testing manual string match for '%rax':")
    (if (text-parser-match-string parser "%rax" 4)
        (println "  SUCCESS: Manual string match worked")
      (println "  FAILED: Manual string match failed")))
  
  ;; Test with whitespace
  (let ((parser (text-parser-for-on <text-parser> "%rax ")))
    (println "Testing manual string match for '%rax ' (with space):")
    (if (and (text-parser-match-string parser "%rax" 4)
             (text-parser-match-char parser 32)) ; space
        (println "  SUCCESS: Manual string + space match worked")
      (println "  FAILED: Manual string + space match failed"))))

(test-manual-parsing)

;; Simple x86 class test  
(define-class <simple-x86> <text-parser> ())

(define-method $simple-register <simple-x86> ()
  "Test simple register matching"
  (or (and (text-parser-match-string self "%rax" 4) (set self.result 'rax))
      (and (text-parser-match-string self "%rbx" 4) (set self.result 'rbx))))

(define-function test-simple-class ()
  "Test simple class"
  (println "\n=== Simple Class Test ===")
  (let ((parser (text-parser-for-on <simple-x86> "%rax")))
    (if ($simple-register parser)
        (println "SUCCESS: Simple register parse: " (<simple-x86>-result parser))
      (println "FAILED: Simple register parse failed"))))

(test-simple-class)