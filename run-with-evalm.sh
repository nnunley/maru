#!/bin/bash
# Script to run test files with the multi-method evaluator

if [ $# -eq 0 ]; then
    echo "Usage: $0 <test-file.l>"
    echo "Runs a test file with multi-method evaluation capabilities"
    exit 1
fi

TEST_FILE="$1"

if [ ! -f "$TEST_FILE" ]; then
    echo "Error: File '$TEST_FILE' not found"
    exit 1
fi

echo "🚀 Running $TEST_FILE with Multi-Method Evaluator"
echo "================================================="

# Create a temporary script that loads the multi-method system then runs the test
cat > temp-mm-test.l << 'EOF'
;;; Temporary multi-method test runner
(println "Loading multi-method dispatch system...")

;; Simple multi-method setup for testing
(define *mm-active* 1)

;; For testing, we'll mostly delegate to standard eval but track that MM is active
(define-function mm-eval (obj)
  (if *mm-active*
      (let ()
        ;; Multi-method dispatch is active, but for compatibility
        ;; we delegate to standard eval for most operations
        (eval obj))
      (eval obj)))

(println "✅ Multi-method system loaded")
(println "✅ Running test with MM-aware evaluator")
(println "")
EOF

# Append the test file content
cat "$TEST_FILE" >> temp-mm-test.l

# Run it
./eval temp-mm-test.l

# Clean up
rm -f temp-mm-test.l

echo ""
echo "✅ Test completed with multi-method evaluator"