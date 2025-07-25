;;; test-system.l - Test if system() function works

(println "Testing system function...")

(define system (extern 'system))

(println "Creating test directory...")
(system "mkdir -p /tmp/maru-test")

(println "Creating test file...")
(system "echo 'Hello from Maru JIT' > /tmp/maru-test/hello.txt")

(println "Listing contents...")
(system "ls -la /tmp/maru-test/")

(println "Test complete - if you see the file listing above, system() works!")