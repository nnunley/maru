# Maru API Reference

*Complete API documentation for the Maru metacircular language workbench*

## Table of Contents

1. [Core Language Forms](#core-language-forms)
2. [Function Definitions](#function-definitions)
3. [Data Structures](#data-structures)
4. [Control Flow](#control-flow)
5. [Macro System](#macro-system)
6. [Object System](#object-system)
7. [Compiler API](#compiler-api)
8. [Parser API](#parser-api)
9. [I/O and Streams](#io-and-streams)
10. [Type System (.k files)](#type-system-k-files)
11. [Foreign Function Interface](#foreign-function-interface)
12. [Standard Library](#standard-library)

---

## Core Language Forms

### Special Forms (Primitives)

```lisp
;; Variable binding
(set symbol value)                    ; Set global variable
(let ((var val) ...) body ...)       ; Local bindings
(let* ((var val) ...) body ...)      ; Sequential local bindings

;; Function application
(function arg1 arg2 ...)              ; Apply function to arguments
(apply function arg-list)             ; Apply with argument list

;; Quotation
(quote expr)                          ; Prevent evaluation
'expr                                 ; Shorthand for quote

;; Evaluation control
(eval expr [env])                     ; Evaluate expression
```

### Environment Operations

```lisp
(define symbol value [env])           ; Define in environment
(set symbol value [env])              ; Mutate in environment
(lookup symbol [env])                 ; Look up symbol
(environment-define env sym val)      ; Explicit environment mutation
```

## Function Definitions

### Basic Functions

```lisp
;; Define named function
(define-function name (param ...) body ...)

;; Anonymous functions  
(lambda (param ...) body ...)
(λ (param ...) body ...)              ; Unicode alias

;; Examples
(define-function factorial (n)
  (if (< n 2)
      1
      (* n (factorial (- n 1)))))

(define map2
  (lambda (f xs ys)
    (if (or (null? xs) (null? ys))
        ()
        (cons (f (car xs) (car ys))
              (map2 f (cdr xs) (cdr ys))))))
```

### Function Utilities

```lisp
(function? expr)                      ; Test if function
(closure? expr)                       ; Test if closure
(primitive? expr)                     ; Test if primitive
(apply fn args)                       ; Apply function to list
(compose f g)                         ; Function composition
```

## Data Structures

### Lists

```lisp
;; Construction
(cons head tail)                      ; Construct pair
(list elem ...)                       ; Construct list
'(elem ...)                          ; List literal

;; Access
(car list)                           ; First element
(cdr list)                           ; Rest of list
(caar list)                          ; (car (car list))
(cadr list)                          ; (car (cdr list))
;; ... all combinations up to 4 deep

;; Predicates
(null? expr)                         ; Test for empty list
(pair? expr)                         ; Test for cons pair
(list? expr)                         ; Test for proper list

;; Operations
(length list)                        ; List length
(append list ...)                    ; Concatenate lists
(reverse list)                       ; Reverse list
(member elem list)                   ; Find element
(assoc key alist)                    ; Association list lookup
```

### Arrays

```lisp
(make-array size [init])             ; Create array
(array-ref array index)              ; Get element
(array-set array index value)        ; Set element
(array-length array)                 ; Get size
(array? expr)                        ; Test if array
```

### Structures

```lisp
;; Define structure type
(define-structure name (field ...))

;; Auto-generates:
;; - Constructor: make-name
;; - Predicate: name?
;; - Accessors: name-field
;; - Mutators: set-name-field

;; Example
(define-structure point (x y))
(define p (make-point 10 20))
(point-x p)                          ; => 10
(set-point-y p 30)
(point? p)                           ; => true
```

## Control Flow

### Conditionals

```lisp
(if test then [else])                ; Basic conditional
(when test body ...)                 ; One-armed if
(unless test body ...)               ; Inverted when
(cond (test1 expr1)                  ; Multi-way conditional
      (test2 expr2)
      ...
      (else default))
(case key                            ; Dispatch on value
  ((val ...) expr)
  ...
  (else default))
```

### Iteration

```lisp
(while test body ...)                ; While loop
(for ((var init step) ...) test body ...) ; For loop
(do ((var init step) ...)            ; Do loop
    (test result ...)
  body ...)
```

### Sequencing

```lisp
(begin expr ...)                     ; Sequential evaluation
(prog1 expr1 expr ...)              ; Return first value
(progn expr ...)                    ; Return last value
```

### Non-local Control

```lisp
(call/cc proc)                       ; Call with current continuation
(throw tag value)                    ; Non-local exit
(catch tag body ...)                 ; Establish catch point
```

## Macro System

### Macro Definition

```lisp
;; Define macro
(define-macro name (param ...) body ...)

;; Define form (simpler macro)
(define-form name (param ...) body ...)

;; Quasiquote for macro construction
`(list ,expr ,@list-expr)

;; Example
(define-form when (condition . body)
  `(if ,condition (begin ,@body)))

(define-macro swap (a b)
  `(let ((temp ,a))
     (set ,a ,b)
     (set ,b temp)))
```

### Macro Utilities

```lisp
(macro? expr)                        ; Test if macro
(macroexpand expr)                   ; Expand macro once
(macroexpand-1 expr)                 ; Full expansion
(gensym [prefix])                    ; Generate unique symbol
```

## Object System

### Generic Functions

```lisp
;; Define generic function
(define-generic name (param ...))

;; Define method
(define-method name Type (self param ...) body ...)

;; Multi-methods
(define-multimethod name (type ...) (param ...) body ...)

;; Example
(define-generic print (obj))

(define-method print String (s)
  (print-string s))

(define-method print Number (n)
  (print-number n))

(define-method print List (l)
  (print "(")
  (print-list-elements l)
  (print ")"))
```

### Class-like Structures

```lisp
;; Define class-like structure with methods
(define-class name super (field ...)
  (method-name (self param ...) body ...) ...)

;; Sends message to object
(send object message arg ...)

;; Field access with dot notation
object.field                         ; Get field
(set object.field value)             ; Set field
```

## Compiler API

### Main Compilation

```lisp
;; From emit.l
(encode expr)                        ; Compile expression to C
(encode-body exprs)                  ; Compile sequence
(gen-init expr)                      ; Generate initializer
(gen-definition expr)                ; Generate definition
(gen-declare-struct name fields)     ; Declare C struct
```

### Code Generation

```lisp
;; Expression compilation
(gen expr)                           ; Generate expression code
(gen-id name)                        ; Generate identifier
(gen-literal value)                  ; Generate literal
(gen-lambda args body)               ; Generate function
(gen-apply fn args)                  ; Generate application

;; C output functions
(emit-c-declaration type name)       ; Emit declaration
(emit-c-statement stmt)              ; Emit statement
(emit-c-expression expr)             ; Emit expression
```

### Compiler Configuration

```lisp
*input-name*                         ; Current input file
*output-name*                        ; Current output file
*globals*                            ; Global environment
*forms*                              ; Special forms table
```

## Parser API

### PEG Parser Generator

```lisp
;; Define parser from grammar
(define-parser name
  rule ...)

;; Grammar rule syntax
(rule name pattern)

;; Pattern operators
(match-one pattern)                  ; Match exactly once
(match-zero-or-more pattern)         ; *
(match-one-or-more pattern)          ; +
(match-zero-or-one pattern)          ; ?
(match-sequence pattern ...)         ; Sequence
(match-choice pattern ...)           ; Ordered choice
(match-rule name)                    ; Reference rule
(match-char char)                    ; Match character
(match-string string)                ; Match string
(match-class name)                   ; Character class
(match-any)                          ; Any character
```

### Parser Actions

```lisp
;; Semantic actions in grammar
(-> pattern action)                  ; Apply action to match

;; Parser invocation
(parse parser input)                 ; Parse input
(parser-error? result)               ; Check for error

;; Example
(define-parser calc
  (expr (match-choice 
         (-> (match-sequence expr "+" term) 
             (lambda (e _ t) (+ e t)))
         term))
  (term (match-rule number))
  (number (-> (match-one-or-more (match-class digit))
              string->number)))
```

## I/O and Streams

### Port System

```lisp
;; Port creation
(string-port)                        ; Create string output port
(console-port)                       ; Create console port
(file-port filename mode)            ; Create file port

;; Port operations
(port-write port string)             ; Write to port
(port-write-char port char)          ; Write character
(port-read port)                     ; Read from port
(port-read-char port)                ; Read character
(port-contents port)                 ; Get accumulated contents
(port-flush port)                    ; Flush buffers
(port-close port)                    ; Close port

;; Standard ports
*standard-input*                     ; stdin
*standard-output*                    ; stdout
*standard-error*                     ; stderr
```

### File Operations

```lisp
(open-file filename mode)            ; Open file
(close-file file)                    ; Close file
(read-file filename)                 ; Read entire file
(write-file filename content)        ; Write entire file
(file-exists? filename)              ; Test existence
```

### Printing

```lisp
(print expr ...)                     ; Print expressions
(println expr ...)                   ; Print with newline
(printf format arg ...)              ; Formatted print
(pp expr)                            ; Pretty print
(pretty-print expr [port])           ; Pretty print to port
```

## Type System (.k files)

### Type Annotations

```lisp
;; Typed function definition
(define-function name (type param) ... -> return-type
  body ...)

;; Type declarations
(define-type name type-expr)         ; Type alias
(define-structure name (type field) ...) ; Typed structure

;; Basic types
int                                  ; Integer
long                                 ; Long integer
float                                ; Float
double                               ; Double
char                                 ; Character
bool                                 ; Boolean
void                                 ; No value
void*                                ; Generic pointer
```

### Type Expressions

```lisp
;; Pointer types
(* type)                             ; Pointer to type
([] type)                            ; Array of type

;; Function types
(-> (type ...) return-type)          ; Function type

;; Structure types
(struct name)                        ; Named structure
{type field ...}                     ; Anonymous structure

;; Examples
(define-function add (int a) (int b) -> int
  (+ a b))

(define-structure point (double x) (double y))

(define-type int-array (* int))
```

## Foreign Function Interface

### C Integration

```lisp
;; Import C function
(define-alien-function name (param-type ...) -> return-type)

;; Import C variable
(define-alien-value name type)

;; C structure access
(define-c-struct name
  (field type) ...)

;; Examples
(define-alien-function malloc (long) -> void*)
(define-alien-function free (void*) -> void)
(define-alien-function printf (char* ...) -> int)

(define-alien-value errno int)

(define-c-struct timeval
  (tv_sec long)
  (tv_usec long))
```

### System Calls

```lisp
;; Direct system call
(syscall number arg ...)

;; Platform constants (from osdefs)
(define-constant name value)         ; Define system constant
%O_RDONLY                           ; File open flags
%SIGINT                             ; Signal numbers
```

## Standard Library

### List Operations

```lisp
(map function list ...)              ; Map function over lists
(filter predicate list)              ; Filter list
(reduce function init list)          ; Fold/reduce
(for-each proc list ...)            ; Side-effecting iteration
(find predicate list)                ; Find first match
(find-if predicate list)             ; Alias for find
(every? predicate list)              ; All satisfy?
(some? predicate list)               ; Any satisfy?
(take n list)                        ; First n elements
(drop n list)                        ; Remove first n
```

### String Operations

```lisp
(string? expr)                       ; Test if string
(string-length string)               ; String length
(string-ref string index)            ; Get character
(string-append string ...)           ; Concatenate
(substring string start [end])       ; Extract substring
(string->list string)                ; Convert to char list
(list->string char-list)             ; Convert from chars
(string->symbol string)              ; Convert to symbol
(symbol->string symbol)              ; Convert from symbol
```

### Numeric Operations

```lisp
;; Arithmetic
(+ num ...)                          ; Addition
(- num ...)                          ; Subtraction
(* num ...)                          ; Multiplication
(/ num ...)                          ; Division
(% num divisor)                      ; Modulo
(expt base power)                    ; Exponentiation

;; Comparison
(< num ...)                          ; Less than
(<= num ...)                         ; Less or equal
(> num ...)                          ; Greater than
(>= num ...)                         ; Greater or equal
(= num ...)                          ; Equal
(!= num ...)                         ; Not equal

;; Bitwise
(& num ...)                          ; Bitwise AND
(| num ...)                          ; Bitwise OR
(^ num ...)                          ; Bitwise XOR
(~ num)                              ; Bitwise NOT
(<< num shift)                       ; Left shift
(>> num shift)                       ; Right shift

;; Math functions
(abs num)                            ; Absolute value
(min num ...)                        ; Minimum
(max num ...)                        ; Maximum
(floor num)                          ; Floor
(ceiling num)                        ; Ceiling
(round num)                          ; Round
(sqrt num)                           ; Square root
```

### Type Predicates

```lisp
(null? expr)                         ; Test for ()
(pair? expr)                         ; Test for cons cell
(list? expr)                         ; Test for proper list
(symbol? expr)                       ; Test for symbol
(string? expr)                       ; Test for string
(number? expr)                       ; Test for number
(function? expr)                     ; Test for function
(array? expr)                        ; Test for array
(struct? expr)                       ; Test for structure
```

### Utilities

```lisp
;; General utilities
(error message)                      ; Signal error
(exit [code])                        ; Exit program
(load filename)                      ; Load file
(require filename)                   ; Load if not loaded
(time expr)                          ; Time expression
(gc)                                 ; Force garbage collection

;; Debugging
(trace function)                     ; Trace function calls
(untrace function)                   ; Stop tracing
(break)                              ; Enter debugger
(backtrace)                          ; Show call stack
```

---

*This API reference covers the core Maru language. For architecture-specific APIs, see the files in `arch/`. For language-specific extensions like Nile, see `compilers/` and `runtimes/`.*