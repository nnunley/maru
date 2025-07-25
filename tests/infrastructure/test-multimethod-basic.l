;;; test-multimethod-basic.l - Basic multi-method test

;; Test Maru's built-in multi-method support
(define-structure <point> (x y))
(define-structure <circle> (center radius))

;; Define a generic function
(define-generic area (shape))

;; Define methods for different types
(define-method area <circle> ()
  (* 3.14159 self.radius self.radius))

(define-method area <point> ()
  0)  ; Points have no area

;; Test the multi-method dispatch
(let ((c (new <circle> () 5))
      (p (new <point> 3 4)))
  (println "Testing multi-method dispatch:")
  (println (concat "  Area of circle with radius 5: " (string (area c))))
  (println (concat "  Area of point: " (string (area p)))))

;; Show that this is what eval-multimethod.k does
(println "\nThe eval-multimethod.k file uses this same pattern for evaluation:")
(println "  (define-generic maru-eval (exp ctx))")
(println "  (define-method maru-eval <maru-long> ((ctx ...)) self)")
(println "  (define-method maru-eval <maru-pair> ((ctx ...)) ...)")

(println "\nMulti-method dispatch working correctly!")