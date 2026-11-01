;;; compile-irl.l --library builds one shared library from two irl files, its exported
;;; functions called by address from untyped Maru; a top-level statement in library mode
;;; is an error.  Prints "irl library ok".
(define system (subr "system" "s"))
(define dlopen (subr "dlopen" "si>p"))
(define dlsym (subr "dlsym" "ps>p"))
(define ok 1)
(define-function expect (what c) (or c (let () (set ok ()) (println "FAIL " what))))
(define-function has? (str sub)
  (let ((i 0) (n (- (string-length str) (string-length sub))))
    (while (and (<= i n) (not (= sub (string-copy str i (string-length sub))))) (incr i))
    (<= i n)))
(define dir "/tmp/maru-check")
(system (concat-strings "mkdir -p " dir))
(system (concat-strings "./eval compile-irl.l --library check/irl-lib-a.irl check/irl-lib-b.irl > " dir "/irl-lib.k"
			" && ./eval2 ir-gen-c.k maru.k " dir "/irl-lib.k > " dir "/irl-lib.c"
			" && cc -shared -fPIC -fno-builtin -w -o " dir "/irl-lib.dylib " dir "/irl-lib.c"))
(let ((lib (dlopen (concat-string dir "/irl-lib.dylib") 2)))	; RTLD_NOW
  (expect "the library opens by absolute path" (not (= 0 lib)))
  (or (= 0 lib)
      (let ((twice (dlsym lib "twice")) (add3 (dlsym lib "add3")))
	(expect "twice is exported" (not (= 0 twice)))
	(expect "add3 is exported" (not (= 0 add3)))
	(and (not (= 0 twice)) (expect "twice 21 is 42" (= 42 ((subr twice "l>l") 21))))
	(and (not (= 0 add3)) (expect "add3 1 2 3 is 6" (= 6 ((subr add3 "lll>l") 1 2 3)))))))
;; a library has no main, so a statement at its top level would never run
(system (concat-strings "printf 'printf(\"x\");\\n' > " dir "/irl-lib-bad.irl"))
(system (concat-strings "./eval compile-irl.l --library " dir "/irl-lib-bad.irl > " dir "/irl-lib-bad.out 2>&1"))
(expect "a top-level statement in library mode is an error"
	(has? (contents-of-file-named (concat-string dir "/irl-lib-bad.out")) "irl library: top-level statement in"))
(and ok (println "irl library ok"))
