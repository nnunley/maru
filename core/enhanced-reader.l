;;; enhanced-reader.l -- Enhanced reader with source location tracking
;;;
;;; This module patches the existing reader to automatically capture
;;; source locations in all parsed expressions.

;;; Source location tracking state
(define *current-filename* "<stdin>")
(define *current-line* 1)
(define *current-column* 1)
(define *source-tracking-enabled* 1)

;;; Create source location object
(define-function make-source-info (filename line column)
  (and *source-tracking-enabled*
       (let ((info (cons filename (cons line column))))
         info)))

;;; Get current source location
(define-function current-source-info ()
  (make-source-info *current-filename* *current-line* *current-column*))

;;; Enhanced cons that adds source tracking
(define original-cons cons)

(define-function cons-with-source (head tail)
  "Create pair with automatic source location tracking"
  (let ((pair (original-cons head tail)))
    (and *source-tracking-enabled*
         (pair? pair)
         (set (<pair>-source pair) (current-source-info)))
    pair))

;;; Override the global cons function
(set cons cons-with-source)

;;; Source position update functions
(define-function update-position-for-char (c)
  "Update line/column based on character"
  (cond
    ((= c ?\n)  ; newline
     (set *current-line* (+ *current-line* 1))
     (set *current-column* 1))
    ((= c ?\t)  ; tab (assume 8-char tabs)
     (let ((tab-size 8))
       (set *current-column* 
            (+ *current-column* 
               (- tab-size (% (- *current-column* 1) tab-size))))))
    (else
     (set *current-column* (+ *current-column* 1)))))

;;; Source-aware error reporting
(define-function format-source-location (source)
  "Format source location as string"
  (if source
      (concat-string (car source)
        (concat-string ":" 
          (concat-string (long->string (car (cdr source)))
            (concat-string ":" (long->string (cdr (cdr source)))))))
    "<unknown>"))

(define-function source-error (obj message)
  "Report error with source location"
  (let ((source (and (pair? obj) (<pair>-source obj))))
    (print "Error")
    (if source
        (print " at " (format-source-location source)))
    (print ": " message)
    (println)
    (error "Compilation failed")))

(define-function source-warning (obj message)
  "Report warning with source location"
  (let ((source (and (pair? obj) (<pair>-source obj))))
    (print "Warning")
    (if source
        (print " at " (format-source-location source)))
    (print ": " message)
    (println)))

;;; Debug utilities
(define-function show-source (obj)
  "Display source information for debugging"
  (let ((source (and (pair? obj) (<pair>-source obj))))
    (if source
        (println "Source: " (format-source-location source))
      (println "No source information"))))

(define-function trace-expr (expr label)
  "Trace expression with source location"
  (let ((source (and (pair? expr) (<pair>-source expr))))
    (print "[" label "]")
    (if source
        (print " at " (format-source-location source))
      (print " <no source>"))
    (print ": ")
    (dump expr)
    (println)))

;;; Enhanced file reading with source tracking
(define-function read-file-with-source (filename)
  "Read file with source location tracking"
  (let ((old-filename *current-filename*)
        (old-line *current-line*)
        (old-column *current-column*)
        (stream (open filename)))
    
    (if (not stream)
        (error "Could not open file: " filename)
      (let ()
        ;; Set up source context
        (set *current-filename* filename)
        (set *current-line* 1)
        (set *current-column* 1)
        
        ;; Read all expressions
        (let ((expressions ())
              (expr nil))
          (while (!= 'EOF (set expr (read stream)))
            (set expressions (cons expr expressions)))
          (close stream)
          
          ;; Restore previous context
          (set *current-filename* old-filename)
          (set *current-line* old-line)
          (set *current-column* old-column)
          
          (reverse expressions)))))

;;; Stack trace utilities
(define-function print-backtrace-with-source (stack depth)
  "Print stack trace with source locations"
  (println "Stack trace:")
  (let ((i 0))
    (while (< i depth)
      (let ((frame (array-at stack i))
            (source (and (pair? frame) (<pair>-source frame))))
        (print "  " i ": ")
        (if source
            (print (format-source-location source) " ")
          (print "<no source> "))
        (dump frame)
        (println)
        (set i (+ i 1))))))

;;; Integration with existing system
(define-function enable-source-tracking ()
  "Enable source location tracking"
  (set *source-tracking-enabled* 1)
  (set cons cons-with-source)
  (println "Source location tracking enabled"))

(define-function disable-source-tracking ()
  "Disable source location tracking for performance"
  (set *source-tracking-enabled* 0)
  (set cons original-cons)
  (println "Source location tracking disabled"))

;;; Test the enhanced reader
(define-function test-source-tracking ()
  "Test source location tracking functionality"
  (println "=== Testing Source Location Tracking ===")
  
  ;; Test basic pair creation
  (set *current-filename* "test.l")
  (set *current-line* 10)
  (set *current-column* 5)
  
  (let ((test-pair (cons 'hello 'world)))
    (println "Test pair: ")
    (dump test-pair)
    (show-source test-pair))
  
  ;; Test error reporting
  (println "\nTesting source-aware error reporting:")
  (let ((problematic-expr (cons 'bad-function (cons 'arg1 'arg2))))
    (source-warning problematic-expr "This is a test warning")
    ;; Uncomment to test error reporting (will exit):
    ;; (source-error problematic-expr "This is a test error")
    )
  
  (println "\n=== Source Tracking Test Complete ==="))

;;; Initialize
(enable-source-tracking)
(println "Enhanced reader with source location tracking loaded.")
(println "Use (test-source-tracking) to run tests.")