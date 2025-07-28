;;; multimethod-dispatch-demo.l - Demonstrate type-specialized C generation

(load "boot.l")

(println "=== MULTIMETHOD DISPATCH FOR C GENERATION ===")
(println)

(println "CONCEPT: Use Maru's multimethod system to specialize C generation")
(println "based on inferred or annotated types.")
(println)

(println "APPROACH 1: Context-based dispatch")
(println "  - Create context objects: <numeric-context>, <object-context>")
(println "  - Define multimethod: (emit-c-operation context op left right)")
(println "  - Let multimethod dispatch choose implementation")
(println)

(println "EXAMPLE SPECIALIZATIONS:")
(println)

(println "For <numeric-context>:")
(println "  (+ a b)  =>  LONG(a + b)          // Fast direct arithmetic")
(println "  (> a b)  =>  (a > b ? s_true : nil)  // Direct comparison")
(println)

(println "For <object-context>:")
(println "  (+ a b)  =>  add(a, b)            // Safe runtime dispatch")
(println "  (> a b)  =>  greater_than(a, b)   // Safe runtime dispatch")
(println)

(println "APPROACH 2: Type-based dispatch")
(println "  - Use actual Maru types: <long>, <double>, <string>")
(println "  - Define: (compile-binary-op type1 type2 op)")
(println "  - Generate specialized code for each type combination")
(println)

(println "TYPE COMBINATION EXAMPLES:")
(println "  compile-binary-op(<long>, <long>, +)   => direct C arithmetic")
(println "  compile-binary-op(<double>, <double>, +) => floating point")
(println "  compile-binary-op(<string>, <string>, +) => string concatenation")
(println "  compile-binary-op(<long>, <string>, +)   => error or conversion")
(println)

(println "BENEFITS:")
(println "1. Type safety - each combination explicitly handled")
(println "2. Performance - optimal code for known types")
(println "3. Extensibility - easy to add new types")
(println "4. Clarity - dispatch logic is explicit")
(println)

(println "IMPLEMENTATION STRATEGY:")
(println "1. Use type inference to determine operand types")
(println "2. Default to safe object context when types unknown")
(println "3. Specialize to numeric context when types proven")
(println "4. Generate different C based on dispatch result")
(println)