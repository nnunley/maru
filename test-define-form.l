;;; Test if define-form works at all

(define-form test-compile-begin ()  `(set *globals* (environment *globals*)))
(println "test-compile-begin defined: " (if (defined? 'test-compile-begin) "yes" "no"))

;;; Now let's manually execute the same code that's at the end of emit.l
(define-form compile-begin ()	`(set *globals* (environment *globals*)))
(println "compile-begin defined: " (if (defined? 'compile-begin) "yes" "no"))

(define-form compile-end ()	(let ((env *globals*))
				  (set *globals* (<env>-parent env))
				  (println "compile-end called!")))
(println "compile-end defined: " (if (defined? 'compile-end) "yes" "no"))