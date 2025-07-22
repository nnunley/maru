;;; source-tracking.l -- Source location tracking for debugging
;;;
;;; This module adds comprehensive source location tracking to help with debugging.
;;; It tracks file names, line numbers, and column positions for all parsed expressions.

;;; Source location structure
(define-structure <source-location> (filename line column))

;;; Global source tracking state
(define *current-filename* "")
(define *current-line* 1)
(define *current-column* 1)
(define *track-source* 1)  ; Enable/disable source tracking

;;; Create a new source location
(define-function new-source-location (filename line column)
  (let ((loc (new <source-location>)))
    (set (<source-location>-filename loc) filename)
    (set (<source-location>-line loc) line)
    (set (<source-location>-column loc) column)
    loc))

;;; Get current source location
(define-function current-source-location ()
  (and *track-source*
       (new-source-location *current-filename* *current-line* *current-column*)))

;;; Enhanced pair creation with source tracking
(define-function cons-with-source (head tail)
  "Create a pair with current source location attached"
  (let ((pair (cons head tail)))
    (and *track-source*
         (pair? pair)
         (set (<pair>-source pair) (current-source-location)))
    pair))

;;; Enhanced pair creation with explicit source
(define-function cons-at-source (head tail filename line column)
  "Create a pair with explicit source location"
  (let ((pair (cons head tail)))
    (and *track-source*
         (pair? pair)
         (set (<pair>-source pair) (new-source-location filename line column)))
    pair))

;;; Update source position for character-by-character tracking
(define-function update-source-position (char)
  "Update line/column position based on character"
  (cond
    ((= char ?\n)  ; newline
     (set *current-line* (+ *current-line* 1))
     (set *current-column* 1))
    ((= char ?\t)  ; tab - assume 8-char tabs
     (set *current-column* (+ *current-column* (- 8 (% (- *current-column* 1) 8)))))
    (else
     (set *current-column* (+ *current-column* 1)))))

;;; Source location utilities
(define-function source-location-string (source)
  "Convert source location to readable string"
  (and source
       (concat-string
         (<source-location>-filename source)
         (concat-string ":"
           (concat-string (long->string (<source-location>-line source))
             (concat-string ":"
               (long->string (<source-location>-column source))))))))

;;; Get source location from any object
(define-function get-source-location (obj)
  "Extract source location from an object"
  (cond
    ((pair? obj) (<pair>-source obj))
    (else nil)))

;;; Source-aware error reporting
(define-function source-error (obj message . args)
  "Report an error with source location context"
  (let ((loc (get-source-location obj)))
    (and loc
         (let ()
           (print "Error at " (source-location-string loc) ": ")
           (apply print (cons message args))
           (println)))
    (or loc
        (let ()
          (print "Error: ")
          (apply print (cons message args))
          (println)))
    (error "Compilation failed")))

;;; Source-aware warning reporting  
(define-function source-warning (obj message . args)
  "Report a warning with source location context"
  (let ((loc (get-source-location obj)))
    (and loc
         (let ()
           (print "Warning at " (source-location-string loc) ": ")
           (apply print (cons message args))
           (println)))
    (or loc
        (let ()
          (print "Warning: ")
          (apply print (cons message args))
          (println)))))

;;; Enhanced reader with source tracking
(define-function read-with-source (stream filename)
  "Read expressions with source location tracking"
  (let ((old-filename *current-filename*)
        (old-line *current-line*)
        (old-column *current-column*))
    
    ;; Set up source context
    (set *current-filename* filename)
    (set *current-line* 1)
    (set *current-column* 1)
    
    (let ((result (read-expressions-with-tracking stream)))
      ;; Restore previous source context
      (set *current-filename* old-filename)
      (set *current-line* old-line)
      (set *current-column* old-column)
      result)))

;;; Read multiple expressions with source tracking
(define-function read-expressions-with-tracking (stream)
  "Read all expressions from stream with source tracking"
  (let ((expressions ())
        (expr nil))
    (while (!= 'EOF (set expr (read-expr-with-tracking stream)))
      (set expressions (cons expr expressions)))
    (reverse expressions)))

;;; Read single expression with source tracking
(define-function read-expr-with-tracking (stream)
  "Read one expression with source location tracking"
  ;; This is a placeholder - in a real implementation, this would
  ;; integrate with the actual reader to track positions
  (let ((start-line *current-line*)
        (start-column *current-column*)
        (expr (read stream)))
    (and (not (= 'EOF expr))
         (pair? expr)
         (set (<pair>-source expr) 
              (new-source-location *current-filename* start-line start-column)))
    expr))

;;; Source-aware macro expansion
(define-function expand-with-source (expr env)
  "Expand macros while preserving source information"
  (let ((expanded (expand expr env)))
    ;; Propagate source information from original to expanded form
    (and (pair? expr) (pair? expanded) (not (<pair>-source expanded))
         (set (<pair>-source expanded) (<pair>-source expr)))
    expanded))

;;; Debug utilities for source tracking

(define-function show-source-info (obj)
  "Display source information for an object"
  (let ((loc (get-source-location obj)))
    (if loc
        (let ()
          (print "Source: " (source-location-string loc))
          (println))
      (println "No source location available"))))

(define-function trace-with-source (expr)
  "Print expression with source location for debugging"
  (let ((loc (get-source-location expr)))
    (if loc
        (print "[" (source-location-string loc) "] ")
      (print "[no source] "))
    (dump expr)
    (println)))

;;; Stack trace with source locations
(define-function print-source-backtrace (stack depth)
  "Print stack trace with source locations"
  (let ((i 0))
    (println "Stack trace:")
    (while (< i depth)
      (let ((frame (array-at stack i))
            (loc (get-source-location frame)))
        (print "  " i ": ")
        (if loc
            (print (source-location-string loc) " ")
          (print "<no source> "))
        (dump frame)
        (println)
        (set i (+ i 1))))))

;;; Integration hooks for the reader and evaluator

;;; Override cons to use source tracking by default
(define original-cons cons)
(set cons cons-with-source)

;;; Utility to temporarily disable source tracking
(define-function without-source-tracking (thunk)
  "Execute thunk with source tracking disabled"
  (let ((old-track *track-source*))
    (set *track-source* 0)
    (let ((result (thunk)))
      (set *track-source* old-track)
      result)))

;;; Utility to enable detailed source tracking
(define-function with-detailed-source-tracking (filename thunk)
  "Execute thunk with detailed source tracking for filename"
  (let ((old-filename *current-filename*)
        (old-line *current-line*) 
        (old-column *current-column*)
        (old-track *track-source*))
    (set *current-filename* filename)
    (set *current-line* 1)
    (set *current-column* 1) 
    (set *track-source* 1)
    (let ((result (thunk)))
      (set *current-filename* old-filename)
      (set *current-line* old-line)
      (set *current-column* old-column)
      (set *track-source* old-track)
      result)))

(println "Source location tracking system loaded.")
(println "Key functions:")
(println "  - cons-with-source: Create pairs with source info")
(println "  - source-error: Error reporting with location")
(println "  - source-warning: Warning reporting with location") 
(println "  - show-source-info: Display source info for objects")
(println "  - trace-with-source: Debug trace with source locations")