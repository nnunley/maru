# Getting Started with Maru

## Building Maru

### Prerequisites
- C compiler (gcc or clang)
- Make
- libffi (for FFI support)

### Basic Build
```bash
make eval        # Build the evaluator
./eval boot.l    # Test the bootstrap
```

### Running the REPL
```bash
./eval
> (+ 2 3)
5
> (define hello (lambda (name) (print "Hello, " name "!\n")))
hello
> (hello "World")
Hello, World!
()
```

## Language Basics

### Two Syntax Styles

#### 1. Lisp Syntax (.l files)
Traditional S-expressions:
```lisp
(define factorial (lambda (n)
  (if (<= n 1)
      1
      (* n (factorial (- n 1))))))

(factorial 5) ; => 120
```

#### 2. Maru Syntax (.k files)
Structured syntax with types:
```
define factorial (n : int) -> int
{
    if (n <= 1) 1
    else n * factorial(n - 1)
}
```

## Core Concepts

### 1. Forms and Macros
```lisp
(define-form when (condition . body)
  `(if ,condition (begin ,@body)))

(when (> x 0)
  (print "positive\n")
  (process x))
```

### 2. Structures
```lisp
;; Lisp style
(define-structure point (x y))
(define p (new point 10 20))
(set-point-x p 30)

;; Maru style
define-structure <point> (x y)
let p = new <point> { x: 10, y: 20 }
p.x = 30
```

### 3. Methods
```lisp
(define-method distance (p1 <point>) (p2 <point>)
  (let ((dx (- (point-x p2) (point-x p1)))
        (dy (- (point-y p2) (point-y p1))))
    (sqrt (+ (* dx dx) (* dy dy)))))
```

## Example Programs

### Hello World
```lisp
;; hello.l
(print "Hello, Maru!\n")
```

Run: `./eval hello.l`

### Simple Calculator
```lisp
;; calc.l
(define calculate (op a b)
  (cond
    ((= op '+) (+ a b))
    ((= op '-) (- a b))
    ((= op '*) (* a b))
    ((= op '/) (/ a b))
    (else (error "Unknown operation"))))

(print (calculate '+ 10 5) "\n")  ; 15
(print (calculate '* 3 7) "\n")   ; 21
```

### Object-Oriented Example
```
;; shapes.k
define-structure <shape> ()
define-structure <circle> <shape> (radius)
define-structure <rectangle> <shape> (width height)

define-method area <circle> (c)
{
    let r = c.radius;
    3.14159 * r * r
}

define-method area <rectangle> (r)
{
    r.width * r.height
}

;; Usage
let c = new <circle> { radius: 5 }
let r = new <rectangle> { width: 4, height: 3 }

print "Circle area: " (area c) "\n"
print "Rectangle area: " (area r) "\n"
```

## Exploring the System

### 1. Read the Bootstrap
Start with `boot.l` to understand how the language builds itself:
```bash
less boot.l  # See fundamental definitions
```

### 2. Examine Core Libraries
- `list.l`: List manipulation functions
- `printing.l`: Output formatting
- `parsing.l`: Parser combinators

### 3. Study the Compiler
- `ir.k`: Intermediate representation
- `ir-gen-c.k`: C code generation
- `compiler.l`: Compilation pipeline

### 4. Run Tests
```bash
./eval test.l
./eval test-message.l
```

## Advanced Features

### Foreign Function Interface
```lisp
;; Call C functions
(define-alien-function puts (char*) -> int)
(puts "Hello from C!")

;; Access C variables
(define-alien-variable errno int)
(print "errno = " errno "\n")
```

### Compilation
```lisp
;; Compile to C
(compile-file "myprogram.l" "myprogram.c")

;; Then build with gcc
;; gcc myprogram.c -o myprogram
```

## Historical Note

As part of the VPRI STEPS project, Maru demonstrates how a powerful programming system can be built with minimal code. The entire evaluator is ~1000 lines of C, and the language bootstraps itself to provide a full programming environment.

## Next Steps

1. **Read the Architecture**: See `ARCHITECTURE.md` for deep design details
2. **Explore Examples**: Look at test files and existing .l/.k files
3. **Experiment**: Try implementing small programs
4. **Extend**: Add new primitives or language features
5. **Study STEPS**: Research other STEPS components like OMeta and Nile

## Resources

- VPRI STEPS reports: Historical documentation
- Source code comments: Inline documentation
- Test files: Working examples
- Community: Historical mailing list archives