;;; show-externs.l - Show available extern functions

(println "=== Checking extern functions from eval.l ===")
(println)

;; These are defined in eval.l as externs
(println "Basic system functions:")
(if (defined? 'abort) (println (format "  abort: %s" abort)))
(if (defined? 'exit) (println (format "  exit: %s" exit)))
(if (defined? 'malloc) (println (format "  malloc: %s" malloc)))
(if (defined? 'free) (println (format "  free: %s" free)))

(println "\nString functions:")
(if (defined? 'strlen) (println (format "  strlen: %s" strlen)))
(if (defined? 'strcmp) (println (format "  strcmp: %s" strcmp)))
(if (defined? 'strdup) (println (format "  strdup: %s" strdup)))

(println "\nI/O functions:")
(if (defined? 'putc) (println (format "  putc: %s" putc)))
(if (defined? 'getc) (println (format "  getc: %s" getc)))
(if (defined? 'fopen) (println (format "  fopen: %s" fopen)))
(if (defined? 'fclose) (println (format "  fclose: %s" fclose)))
(if (defined? 'printf) (println (format "  printf: %s" printf)))
(if (defined? 'fprintf) (println (format "  fprintf: %s" fprintf)))

;; Try calling exit to see if it works
(println "\nTesting exit function:")
(println "If you see 'Exit called!', then extern functions are available")
(println "Exit called!")
(exit 0)