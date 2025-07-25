;;; test-evalm-direct.l - Test direct compilation of eval-multimethod.k

(println "Testing direct .k file compilation...")

;; First test if we can load the basic IR infrastructure
(println "Loading IR infrastructure...")

(catch (load "core/compiler/ir.k")
  (println "IR loaded successfully!")
  (catch (load "core/maru.k") 
    (println "Maru compiler loaded successfully!")
    
    ;; Now try to load our eval-multimethod.k
    (catch (load "core/eval-multimethod.k")
      (println "eval-multimethod.k loaded successfully!")
      
      ;; Test if we can call the test function
      (catch (test-eval)
        (println "Multi-method evaluator test completed!")
        (println "SUCCESS: Direct .k compilation works!")))))))

;; If we get here, something failed - show what happened
(println "Direct compilation test finished.")