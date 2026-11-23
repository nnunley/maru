;;; The profiler's report lists the 64 most sampled functions, and a run with more functions sampled than that ends
;;; cleanly: a native compile of check/native/add.k samples hundreds.  check.l runs it under eval2 -p and -P, and checks
;;; the exit status and the report's 64 lines.
;;;   ./eval2 -P check/profile.l
(require "native.l")
(native-image-of (native-compile-file "check/native/add.k"))
(println "profile ok")
