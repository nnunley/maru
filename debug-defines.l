;; Debug tool to track define-* statements and their scopes
;; This will help us understand the structure of emit.l

;; Load the port system for output
(require "lib/stream/port.l")

;; Track current define context
(define *current-define* ())
(define *define-stack* ())
(define *line-number* 1)
(define *paren-depth* 0)
(define *in-string* ())
(define *define-info* ())

;; Define patterns to match
(define define-patterns (list
  "define-function"
  "define-method" 
  "define-selector"
  "define-form"
  "define-structure"
  "define-operand"
  "define-instruction"
  "define-emit"
  "define-generic"
  "define-multimethod"
  "define "  ; catch plain define
))

;; Function to check if a line starts a define
(define-function starts-define? (line)
  (let ((found ()))
    (list-do pattern define-patterns
      (if (and (not found) (string-search line (concat-string "(" pattern)))
          (set found pattern)))
    found))

;; Function to analyze a single line
(define-function analyze-line (line line-num)
  (let ((open-count 0)
        (close-count 0)
        (in-string ())
        (i 0)
        (len (string-length line))
        (define-type (starts-define? line)))
    
    ;; Count parentheses, handling strings and comments
    (while (< i len)
      (let ((c (string-at line i)))
        (cond
          ;; Handle strings
          ((and (= c #\") (not in-string))
           (set in-string 1))
          ((and (= c #\") in-string)
           (set in-string ()))
          ;; Handle comments
          ((and (= c #\;) (not in-string))
           (set i len)) ; Skip rest of line
          ;; Count parens outside strings
          ((and (= c #\() (not in-string))
           (set open-count (+ open-count 1)))
          ((and (= c #\)) (not in-string))
           (set close-count (+ close-count 1))))
        (set i (+ i 1)))))
    
    ;; Update global state
    (set *paren-depth* (+ *paren-depth* (- open-count close-count)))
    
    ;; Track define statements
    (if define-type
        (let ()
          (push *define-stack* (list define-type line-num *paren-depth*))
          (set *current-define* define-type)
          (push *define-info* (list line-num define-type open-count close-count *paren-depth* line))))
    
    ;; Check if we're closing a define
    (if (and *current-define* (= *paren-depth* 0))
        (let ()
          (set *current-define* ())
          (if *define-stack* (pop *define-stack*))))
    
    ;; Return analysis
    (list line-num define-type open-count close-count *paren-depth* *current-define*))))

;; Main analysis function
(define-function analyze-file (filename)
  (println "Analyzing file: " filename)
  (println)
  
  ;; Reset state
  (set *current-define* ())
  (set *define-stack* ())
  (set *line-number* 1)
  (set *paren-depth* 0)
  (set *define-info* ())
  
  ;; Read and analyze file
  (let ((lines (file-lines filename)))
    (list-do line lines
      (let ((analysis (analyze-line line *line-number*)))
        ;; Print interesting lines
        (let ((line-num (car analysis))
              (define-type (cadr analysis))
              (open (caddr analysis))
              (close (cadddr analysis))
              (depth (car (cddddr analysis)))
              (current (cadr (cddddr analysis))))
          
          (if (or define-type (> (+ open close) 2) (< depth 0))
              (println "Line " line-num ": " 
                      (if define-type (concat-string "[" (concat-string define-type "]")) "")
                      " open=" open " close=" close " depth=" depth
                      (if current (concat-string " in-" current) "")
                      (if (< depth 0) " *** NEGATIVE DEPTH ***" ""))))
        
        (set *line-number* (+ *line-number* 1))))
  
  (println)
  (println "Final paren depth: " *paren-depth*)
  (println "Unclosed defines:")
  (list-do info *define-stack*
    (println "  Line " (cadr info) ": " (car info)))
  
  (println)
  (println "All define statements found:")
  (list-do info (reverse *define-info*)
    (let ((line-num (car info))
          (type (cadr info))
          (open (caddr info))
          (close (cadddr info))
          (depth (car (cddddr info)))
          (line-text (cadr (cddddr info))))
      (println "Line " line-num ": " type " (open=" open " close=" close " depth=" depth ")")
      (println "  " line-text))))

;; Helper function to read file lines
(define-function file-lines (filename)
  (let ((lines ())
        (input (open-input-file filename)))
    (if input
        (let ((line (read-line input)))
          (while line
            (push lines line)
            (set line (read-line input)))
          (close-input-port input)
          (reverse lines))
      (let ()
        (println "Error: Could not open file " filename)
        ()))))

;; Simple file reading functions (if not available)
(if (not (defined? 'open-input-file))
    (let ()
      (println "Note: Using simplified file reading")
      (define-function open-input-file (filename) filename)
      (define-function read-line (file) ())
      (define-function close-input-port (file) ())))

;; Run the analysis
(analyze-file "core/compiler/emit.l")