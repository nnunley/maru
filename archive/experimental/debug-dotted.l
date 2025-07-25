;;; Debug dotted symbol parsing

(println "Debugging string parsing...")

(define-function debug-split-at-dot (str)
  "Debug version of split-at-dot"
  (println "Input string: '" str "'")
  (println "String length: " (string-length str))
  
  (let ((len (string-length str))
        (pos 0)
        (found-dot ()))
    
    ;; Show each character
    (println "Characters:")
    (while (< pos len)
      (let ((ch (string-at str pos)))
        (println "  pos " pos ": " ch " (= " ch " 46: " (= ch 46) ")"))
      (set pos (+ pos 1)))
    
    ;; Find the dot
    (set pos 0)
    (while (and (< pos len) (not found-dot))
      (if (= (string-at str pos) 46)  ; 46 is ASCII for '.'
          (set found-dot pos)
          (set pos (+ pos 1))))
    
    (println "Found dot at position: " found-dot)
    
    (if found-dot
        (let ((before "")
              (after "")
              (i 0))
          ;; Build before string
          (while (< i found-dot)
            (let ((ch (string-at str i)))
              (println "Adding to before: " ch)
              (set before (concat-string before (string ch))))
            (set i (+ i 1)))
          ;; Build after string  
          (set i (+ found-dot 1))
          (while (< i len)
            (let ((ch (string-at str i)))
              (println "Adding to after: " ch)
              (set after (concat-string after (string ch))))
            (set i (+ i 1)))
          (println "Final before: '" before "'")
          (println "Final after: '" after "'")
          (cons before after))
        ())))

(debug-split-at-dot "env.x")
(debug-split-at-dot "test.field")