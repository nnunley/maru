; TODO ask Ian about including these in maru?

(define-method ++ <undefined> (b) b)
(define-method ++ <string>    (b) (concat-string self b))
(define-method ++ <pair>      (b) (concat-list   self b))

(define-function replicate (n x)
  (if (< n 1) '() (cons x (replicate (- n 1) x))))

(define-function all? (l) (if l (foldr and 't l)))

(define-function is-a? (obj type) (= (type-of obj) type))

(define-function list-reverse (l)
  (if (pair? l)
    (concat-list (list-reverse (cdr l)) (list (car l)))))

(define-function list-at (l i)
  (if (and (pair? l) (>= i 0))
    (if (= 0 i)
      (car l)
      (list-at (cdr l) (- i 1)))))

(define-function flatten (l)
  (if (pair? l)
    (concat-list (flatten (car l)) (flatten (cdr l)))
    (if l (list l) l)))

(define-function filter (predicate l)
  (if (pair? l)
    (if (predicate (car l))
      (cons (car l) (filter predicate (cdr l)))
      (filter predicate (cdr l)))))

(define-method to-upper-case <string> ()
  (let ((uppered (array)))
    (string-do char self
      (array-append uppered
        (if (and (<= ?a char) (<= char ?z))
            (- char 32)
            char)))
     (array->string uppered)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
