;;; test-self-contained.l - Self-contained threaded test

;; Thread counter
(define *thread-counter* 0)

;; Generate unique thread name
(define-function fresh-thread ()
  (set *thread-counter* (+ *thread-counter* 1))
  (concat-string "thread_" *thread-counter*))

;; Test basic functionality
(println "Self-contained test starting...")
(println "Fresh thread: " (fresh-thread))
(println "Fresh thread: " (fresh-thread))
(println "Self-contained test complete.")