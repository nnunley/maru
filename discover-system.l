;;; discover-system.l - Discover available system functions in Maru

(println "=== Discovering Maru System Functions ===")
(println)

;; First, let's see if we have *globals*
(if (defined? '*globals*)
    (let ()
      (println "Found *globals* - listing all bindings:")
      (println)
      
      ;; Count entries and look for interesting ones
      (let ((total 0)
            (externs 0)
            (funcs 0)
            (g *globals*))
        
        ;; First pass - count and categorize
        (while (pair? g)
          (let ((binding (car g)))
            (if (pair? binding)
                (let ((name (car binding))
                      (value (cdr binding)))
                  ;; Check for interesting names
                  (cond ((= name 'system) (println (format "FOUND: system = %s" value)))
                        ((= name 'exit) (println (format "FOUND: exit = %s" value)))
                        ((= name 'abort) (println (format "FOUND: abort = %s" value)))
                        ((= name 'dlopen) (println (format "FOUND: dlopen = %s" value)))
                        ((= name 'dlsym) (println (format "FOUND: dlsym = %s" value)))
                        ((= name 'malloc) (println (format "FOUND: malloc = %s" value)))
                        ((= name 'free) (println (format "FOUND: free = %s" value)))
                        ((= name 'printf) (println (format "FOUND: printf = %s" value)))
                        ((= name 'sprintf) (println (format "FOUND: sprintf = %s" value)))
                        ((= name 'fopen) (println (format "FOUND: fopen = %s" value)))
                        ((= name 'fclose) (println (format "FOUND: fclose = %s" value)))
                        ((= name 'putc) (println (format "FOUND: putc = %s" value)))
                        ((= name 'getc) (println (format "FOUND: getc = %s" value))))))
            (set total (+ total 1))
            (set g (cdr g))))
        
        (println)
        (println (format "Total globals: %d" total))
        
        ;; Now let's try to call some if they exist
        (println "\nTesting discovered functions:")
        
        ;; Test malloc if found
        (if (defined? 'malloc)
            (let ()
              (println "malloc is defined - trying to allocate 100 bytes...")
              (let ((ptr (malloc 100)))
                (if ptr
                    (println "  Success! malloc returned a pointer")
                    (println "  malloc returned null"))))
            (println "malloc not found"))
        
        ;; Test printf if found  
        (if (defined? 'printf)
            (let ()
              (println "printf is defined - trying to print...")
              (printf "  Hello from printf!\\n"))
            (println "printf not found"))
        
        ;; Test exit if found
        (if (defined? 'exit)
            (println "exit is defined - would call (exit 0) to exit")
            (println "exit not found"))))
    (println "*globals* not accessible"))

(println "\n=== Checking specific functions ===")

;; Direct checks
(println (format "defined? exit: %s" (if (defined? 'exit) "yes" "no")))
(println (format "defined? abort: %s" (if (defined? 'abort) "yes" "no")))
(println (format "defined? malloc: %s" (if (defined? 'malloc) "yes" "no")))
(println (format "defined? system: %s" (if (defined? 'system) "yes" "no")))

;; If exit is defined, we can use it
(if (defined? 'exit)
    (let ()
      (println "\nCalling exit(0) to demonstrate it works...")
      (exit 0))
    (println "\nexit not available - program will end normally"))