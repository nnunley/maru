# Maru Tutorial

Maru is a Lisp-like language with some unique features, particularly its object system and method dispatch. This tutorial will walk you through writing some basic programs and highlight key differences from other Lisp dialects.

## Hello World

Let's start with the classic "Hello World" program. In Maru, you can write this in a few different ways:

```lisp
;; Method 1: Using print directly
(print "Hello, World!\n")

;; Method 2: Using println (which automatically adds newline)
(println "Hello, World!")

;; Method 3: Using formatted output
(printf "%s\n" "Hello, World!")
```

Note that unlike some Lisp dialects:
- Maru uses `print` and `println` instead of Common Lisp's `format t`
- String formatting is done through `printf` which is similar to C's printf
- The print functions are variadic - they can take multiple arguments which are printed in sequence

## Fibonacci Numbers

Here's a program to calculate Fibonacci numbers in different ways:

```lisp
;; Recursive version
(define-function fib-recursive (n)
  (if (< n 2)
      n
    (+ (fib-recursive (- n 1))
       (fib-recursive (- n 2)))))

;; Iterative version using Maru's loop construct
(define-function fib-iterative (n)
  (if (< n 2)
      n
    (let ((a 0)
          (b 1))
      (for (i 2 (+ n 1))
        (let ((temp b))
          (set b (+ a b))
          (set a temp)))
      b)))

;; Using it:
(println "Fibonacci of 10 (recursive): " (fib-recursive 10))
(println "Fibonacci of 10 (iterative): " (fib-iterative 10))
```

Key differences from other Lisps:
1. Function definition uses `define-function` instead of `defun`
2. Variable mutation uses `set` instead of `setq` or `setf`
3. The `for` loop is more C-like than Lisp-like
4. Local variables are created with `let` similar to other Lisps

## Object-Oriented Programming

Maru has a unique object system that combines features of prototype-based and class-based OOP. Here's an example:

```lisp
;; Define a basic structure type
(define-structure <point> (x y))

;; Define methods for the type
(define-method do-print <point> ()
  (print "<point x=" self.x " y=" self.y ">"))

;; Create and use instances
(define p1 (new <point>))
(set (<point>-x p1) 10)
(set (<point>-y p1) 20)
(println p1)  ;; Will use do-print method

;; Using the make form for cleaner initialization
(define p2 (make <point> 
  (x 30)
  (y 40)))
```

Key features of Maru's object system:
1. Types are defined using `define-structure`
2. Methods are added using `define-method`
3. The `self` variable is automatically bound in methods
4. Field access can be done through generated accessors or dot notation in methods
5. Objects can be created with `new` or `make`

## Working with Collections

Maru provides several ways to work with collections:

```lisp
;; Lists
(define my-list (list 1 2 3 4 5))
(list-do item my-list
  (println item))

;; Arrays
(define my-array (array 5))  ;; Create array of size 5
(for (i 0 5)
  (set-array-at my-array i (* i i)))
(array-do item my-array
  (println item))

;; Using higher-order functions
(define squares 
  (map (lambda (x) (* x x)) 
       my-list))
```

Collection features:
1. Lists are created with `list` or `cons`
2. Arrays are fixed-size and created with `array`
3. Iteration can use `list-do`, `array-do`, or `for`
4. Higher-order functions like `map` and `foldr` are available

## Error Handling

Maru provides basic error handling:

```lisp
;; Basic error reporting
(define-function safe-divide (a b)
  (if (= b 0)
      (error "division by zero")
    (/ a b)))

;; Using assertions in unit tests
(unit-test "division"
  (unit-assert (= 2 (safe-divide 4 2)))
  (unit-assert (error? (safe-divide 4 0))))
```

Error handling features:
1. Use `error` to signal errors
2. Unit testing framework with `unit-test` and `unit-assert`
3. No built-in exception handling like try/catch

## Tips and Best Practices

1. Use `let` for local variables instead of nested `set` expressions
2. Take advantage of Maru's object system for organizing code
3. Use the iteration constructs that best fit your needs:
   - `for` for numeric iteration
   - `list-do`/`array-do` for collection iteration
   - `map`/`foldr` for functional style
4. Make use of selectors and multi-methods for extensible behavior

## Common Gotchas

1. Remember to use `set` for variable mutation, not `setq` or `setf`
2. Method dispatch is done through selectors, not generic functions
3. Arrays are fixed-size - plan your data structures accordingly
4. String operations are more C-like than Lisp-like

## Further Reading

- See `boot.l` for core language features
- Check `boot2.l` for additional library functions
- Look at `eval.l` for understanding the evaluation model
- Examine `emit.l` for code generation capabilities 