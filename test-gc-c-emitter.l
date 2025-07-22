#!/usr/bin/env eval
;;; test-gc-c-emitter.l -- Test the high-fidelity GC-integrated C emitter

(load "emit.l")      ; Core emit framework
(load "emit-gc-c.l") ; High-fidelity GC-integrated C backend

;;; Simple test function to compile
(define test-add
  (lambda (a b)
    (+ a b)))

(define test-pair-creation  
  (lambda (x y)
    (cons x y)))

(define test-string-creation
  (lambda (len)
    (string len)))

;;; Test the emitter by generating a simple program
(define-function test-gc-emitter ()
  (println ";;; Testing High-Fidelity GC C Emitter")
  (println)
  
  ;; Create a minimal environment for testing
  (let ((test-env (environment ())))
    (environment-define test-env 'test-add test-add)
    (environment-define test-env 'test-pair-creation test-pair-creation)
    (environment-define test-env 'test-string-creation test-string-creation)
    
    ;; Generate the C code
    (gen-env-gc-c test-env)
    
    ;; Generate main function that uses GC properly
    (println)
    (println "int main(int argc, char **argv)")
    (println "{")
    (println "  GC_init();")
    (println "  setlocale(LC_ALL, \"\");  /* UTF-8 support */")
    (println)
    (println "  /* Initialize global variables with GC protection */") 
    (println "  initialize_globals();")
    (println)
    (println "  /* Test basic arithmetic */")
    (println "  oop result1= test_add(newLong(5), newLong(3));")
    (println "  printf(\"5 + 3 = %ld\\n\", getLong(result1));")
    (println)
    (println "  /* Test pair creation with GC protection */")  
    (println "  oop result2= test_pair_creation(newLong(42), newLong(17));")
    (println "  printf(\"Pair: (%ld . %ld)\\n\", getLong(get(result2, Pair,head)), getLong(get(result2, Pair,tail)));")
    (println)
    (println "  /* Test string allocation */")
    (println "  oop result3= test_string_creation(newLong(10));")
    (println "  printf(\"Created string of length: %ld\\n\", getLong(get(result3, String,size)));")
    (println)
    (println "  /* Force GC to test our generated objects survive */")
    (println "  GC_gcollect();")
    (println "  printf(\"GC completed - objects still accessible\\n\");")
    (println)
    (println "  return 0;")
    (println "}")
    (println)))

;;; Execute the test
(test-gc-emitter)