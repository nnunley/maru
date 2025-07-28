;;; emit-c-struct-extern-design.l - Structure mapping for external calls
;;;
;;; Based on analysis of Maru's GL support and FFI patterns

(println "=== STRUCTURE MAPPING FOR EXTERNAL CALLS ===")
(println)

;;; ================================================================
;;; CURRENT MARU APPROACH - MANUAL BUFFER MANAGEMENT
;;; ================================================================

(println "=== 1. CURRENT MARU PATTERN ===")
(println)
(println "Maru uses manual buffer allocation and pointer arithmetic:")
(println)

(println "Example from test-gl-texbuf.k:")
(println "  ;; Allocate buffer for output parameters")
(println "  (let ((winw (data sizeof-int))")
(println "        (winh (data sizeof-int)))")
(println "    ;; Pass pointers to function")
(println "    (glfwGetWindowSize winw winh)")
(println "    ;; Extract values manually")
(println "    (let ((w (long-at winw 0))")
(println "          (h (long-at winh 0)))")
(println "      ...))")
(println)

(println "This works but is:")
(println "• Verbose and error-prone")
(println "• No type safety")
(println "• Manual memory management")
(println "• Platform-dependent sizes")
(println)

;;; ================================================================
;;; PROPOSED STRUCTURE MAPPING SYSTEM
;;; ================================================================

(println "=== 2. PROPOSED STRUCTURE MAPPING ===")
(println)

;;; Structure declaration syntax
(println "=== 2.1 STRUCTURE DECLARATION ===")
(println)
(println "(define-c-struct <point>")
(println "  (x int)")
(println "  (y int))")
(println)
(println "(define-c-struct <rect>")
(println "  (origin <point>)   ; Nested struct")
(println "  (width  float)")
(println "  (height float))")
(println)
(println "(define-c-struct <window-size>")
(println "  (width  int)")
(println "  (height int))")
(println)

;;; Automatic accessor generation
(println "=== 2.2 AUTOMATIC ACCESSORS ===")
(println)
(println "Generates:")
(println "  ;; Allocation")
(println "  (define-function make-point ()")
(println "    (data (sizeof <point>)))")
(println "  ")
(println "  ;; Field access")
(println "  (define-function point-x (ptr)")
(println "    (int-at ptr (offsetof <point> x)))")
(println "  ")
(println "  (define-function set-point-x (ptr val)")
(println "    (set-int-at ptr (offsetof <point> x) val))")
(println)

;;; Integration with extern
(println "=== 2.3 EXTERN INTEGRATION ===")
(println)
(println "Enhanced extern syntax:")
(println "  ;; Simple output parameter")
(println "  (extern glfwGetWindowSize void (pointer<int> pointer<int>))")
(println "  ")
(println "  ;; Structure parameter")
(println "  (extern glfwGetWindowRect void (pointer<rect>))")
(println "  ")
(println "  ;; Return structure by value (small structs)")
(println "  (extern make_point <point> (int int))")
(println)

;;; ================================================================
;;; EMIT-C CODE GENERATION
;;; ================================================================

(println "=== 3. EMIT-C GENERATION ===")
(println)

(println "=== 3.1 STRUCTURE DEFINITION ===")
(println)
(println "(define-method compile-to-c <c-struct-definition>")
(println "  '(self backend)")
(println "  '((let ((port (<c-backend>-output-port backend))")
(println "          (name (<c-struct-definition>-name self))")
(println "          (fields (<c-struct-definition>-fields self)))")
(println "      ;; Generate C struct")
(println "      (port-write port \"typedef struct \" name \" {\\n\")")
(println "      (list-do field fields")
(println "        (port-write port \"    \")")
(println "        (compile-c-type (field-type field) port)")
(println "        (port-write port \" \" (field-name field) \";\\n\"))")
(println "      (port-write port \"} \" name \";\\n\"))))")
(println)

(println "=== 3.2 CLEAN FUNCTION CALLS ===")
(println)
(println "Input Maru:")
(println "  (let ((size (make-window-size)))")
(println "    (glfwGetWindowSize (address-of (window-size-width size))")
(println "                       (address-of (window-size-height size)))")
(println "    (println \"Window: \" (window-size-width size) ")
(println "             \"x\" (window-size-height size)))")
(println)
(println "Generated C:")
(println "  window_size size;")
(println "  glfwGetWindowSize(&size.width, &size.height);")
(println "  printf(\"Window: %d x %d\\n\", size.width, size.height);")
(println)

;;; ================================================================
;;; SMART STRUCTURE PASSING
;;; ================================================================

(println "=== 4. SMART STRUCTURE PASSING ===")
(println)

(println "=== 4.1 PASS-BY-VALUE VS POINTER ===")
(println)
(println "(define-c-struct <vec2> :pass-by-value")
(println "  (x float)")
(println "  (y float))")
(println)
(println "(define-c-struct <matrix4> :pass-by-pointer  ; Too big for value")
(println "  (m float 16))  ; Array of 16 floats")
(println)
(println "Maru:")
(println "  (extern vec2_add <vec2> (<vec2> <vec2>))       ; By value")
(println "  (extern matrix4_multiply void (<matrix4>* <matrix4>* <matrix4>*)) ; By pointer")
(println)

;;; ================================================================
;;; RUNTIME vs COMPILE-TIME HANDLING
;;; ================================================================

(println "=== 5. CONTEXT-BASED STRUCTURE HANDLING ===")
(println)

(println "=== 5.1 EMIT-C (COMPILE TIME) ===")
(println)
(println "Direct C struct mapping:")
(println "  ;; Maru")
(println "  (let ((p (make-point)))")
(println "    (set (point-x p) 10)")
(println "    (set (point-y p) 20))")
(println)
(println "  /* Generated C */")
(println "  point p;")
(println "  p.x = 10;")
(println "  p.y = 20;")
(println)

(println "=== 5.2 RUNTIME (INTERPRETER) ===")
(println)
(println "Dynamic struct creation with FFI:")
(println "  ;; Create FFI type dynamically")
(println "  (define point-ffi-type")
(println "    (make-ffi-struct-type")
(println "      (list (cons 'x ffi-type-int)")
(println "            (cons 'y ffi-type-int))))")
(println)

;;; ================================================================
;;; PRACTICAL EXAMPLES
;;; ================================================================

(println "=== 6. PRACTICAL EXAMPLES ===")
(println)

(println "=== 6.1 OPENGL EXAMPLE ===")
(println)
(println "(define-c-struct <GLFWvidmode>")
(println "  (width       int)")
(println "  (height      int)")
(println "  (redBits     int)")
(println "  (greenBits   int)")
(println "  (blueBits    int)")
(println "  (refreshRate int))")
(println)
(println "(extern glfwGetVideoMode <GLFWvidmode>* (pointer<GLFWmonitor>))")
(println)
(println ";; Usage")
(println "(let ((monitor (glfwGetPrimaryMonitor))")
(println "      (mode (glfwGetVideoMode monitor)))")
(println "  (println \"Resolution: \" (GLFWvidmode-width mode)")
(println "           \"x\" (GLFWvidmode-height mode)")
(println "  (println \"Refresh: \" (GLFWvidmode-refreshRate mode) \"Hz\"))")
(println)

(println "=== 6.2 SYSTEM CALLS ===")
(println)
(println "(define-c-struct <stat> :match-platform  ; Platform-specific layout")
(println "  (st_dev     dev_t)")
(println "  (st_ino     ino_t)")
(println "  (st_mode    mode_t)")
(println "  (st_size    off_t)")
(println "  ; ... other fields ...")
(println "  )")
(println)
(println "(extern stat int (string pointer<stat>))")
(println)
(println "(let ((st (make-stat)))")
(println "  (when (= 0 (stat \"/etc/passwd\" st))")
(println "    (println \"File size: \" (stat-st_size st))))")
(println)

;;; ================================================================
;;; IMPLEMENTATION STRATEGY
;;; ================================================================

(println "=== 7. IMPLEMENTATION STRATEGY ===")
(println)

(println "Phase 1: Basic Structure Support")
(println "• define-c-struct macro")
(println "• Automatic accessor generation")
(println "• Size and offset calculation")
(println "• Integration with data/long-at pattern")
(println)

(println "Phase 2: Emit-C Integration")
(println "• Direct struct member access in C")
(println "• Proper type declarations")
(println "• Clean function call generation")
(println "• Nested structure support")
(println)

(println "Phase 3: Advanced Features")
(println "• Union support")
(println "• Bit fields")
(println "• Packed structures")
(println "• Platform-specific layouts")
(println)

;;; ================================================================
;;; BENEFITS
;;; ================================================================

(println "=== 8. BENEFITS ===")
(println)
(println "🎯 TYPE SAFETY:")
(println "• Compile-time structure validation")
(println "• Automatic size calculations")
(println "• Platform-aware layouts")
(println)
(println "✨ CLEAN CODE:")
(println "• No manual offset calculations")
(println "• Readable accessor names")
(println "• Natural C mapping")
(println)
(println "⚡ PERFORMANCE:")
(println "• Zero overhead in emit-c")
(println "• Direct struct member access")
(println "• Optimal C code generation")
(println)
(println "🔧 COMPATIBILITY:")
(println "• Works with existing FFI")
(println "• Supports both compilation and interpretation")
(println "• Backward compatible with data/long-at")
(println)

(println "=== CONCLUSION ===")
(println)
(println "This structure mapping system provides:")
(println "• Clean abstraction over manual buffer management")
(println "• Type-safe external function interfaces")
(println "• Optimal code generation for emit-c")
(println "• Natural C interoperability")
(println)
(println "The design follows Maru's philosophy:")
(println "• Simple, powerful abstractions")
(println "• Context-aware execution")
(println "• Zero overhead when compiled")
(println "==================================================")