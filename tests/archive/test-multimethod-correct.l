;;; test-multimethod-correct.l - Test multi-method dispatch

;; First, let's test with built-in types that already have methods
(println "Testing existing multi-method dispatch:")

;; The 'length' generic function has methods for strings and arrays
(let ((str "hello")
      (arr (array 1 2 3 4 5)))
  (println (concat "  Length of string \"hello\": " (string (length str))))
  (println (concat "  Length of array (1 2 3 4 5): " (string (length arr)))))

;; The 'at' generic function also works on both
(println (concat "  Third character of \"hello\": " (string (at "hello" 2))))
(println (concat "  Third element of array: " (string (at (array 10 20 30 40) 2))))

;; Now let's define our own generic function
(println "\nDefining custom generic function 'describe':")

(define-generic describe (obj))

;; Add methods for built-in types
(add-method describe <long> '(self) '((concat "number: " (string self))))
(add-method describe <string> '(self) '((concat "string of length " (string (string-length self)))))
(add-method describe <pair> '(self) '("a pair"))
(add-method describe <array> '(self) '((concat "array of length " (string (array-length self)))))

;; Test our custom generic function
(println "Testing custom multi-method dispatch:")
(println (concat "  describe 42: " (describe 42)))
(println (concat "  describe \"hello\": " (describe "hello")))
(println (concat "  describe '(a b c): " (describe '(a b c))))
(println (concat "  describe array: " (describe (array 1 2 3))))

(println "\nThis demonstrates how eval-multimethod.k works:")
(println "- Generic functions like 'maru-eval' dispatch on type")
(println "- Each type has its own method implementation")
(println "- No switch statements needed!")
(println "- Clean, extensible design")

(println "\nMulti-method dispatch test complete!")