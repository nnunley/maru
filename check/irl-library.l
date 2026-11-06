;;; compile-irl.l --library compiles two irl files into one shared library (built by make), its exported
;;; functions called by address from untyped Maru; a top-level statement in library mode
;;; is an error.  Prints "irl library ok".
(define system (subr "system" "s>i"))
(define dlopen (subr "dlopen" "si>p"))
(define dlsym (subr "dlsym" "ps>p"))
(define ok 1)
(define-function expect (what c)
  (or c
      (let ()
	(set ok ())
	(println "FAIL " what))))
(define-function has? (str sub)
  (let ((i 0) (n (- (string-length str) (string-length sub))))
    (while (and (<= i n) (not (= sub (string-copy str i (string-length sub))))) (incr i))
    (<= i n)))
(require "check/temp.l")
(define dir check-tmp)
(system (concat-strings "mkdir -p " dir))
;; make builds build/irl-lib.dylib (make check's CHECK_LIBS) from check/irl-lib-a.irl and -b.irl
(define shlib (if (= 0 (system "test `uname` = Darwin")) "dylib" "so"))
(let ((lib (dlopen (concat-string "build/irl-lib." shlib) 2)))	; RTLD_NOW
  (expect "the library opens by absolute path" (not (= 0 lib)))
  (or (= 0 lib)
      (let ((twice (dlsym lib "twice")) (add3 (dlsym lib "add3")))
	(expect "twice is exported" (not (= 0 twice)))
	(expect "add3 is exported" (not (= 0 add3)))
	(and (not (= 0 twice)) (expect "twice 21 is 42" (= 42 ((subr twice "l>l") 21))))
	(and (not (= 0 add3)) (expect "add3 1 2 3 is 6" (= 6 ((subr add3 "lll>l") 1 2 3))))
	;; cast(e, type) and sizeof(type)
	(let ((size (dlsym lib "pair_size")) (view (dlsym lib "view")))
	  (expect "sizeof a two-long struct is 16" (and (not (= 0 size)) (= 16 ((subr size ">l")))))
	  (expect "a cast view of malloc's memory"
		  (and (not (= 0 view)) (= 13 ((subr view "l>l") 5)))))
	;; globals initialised by literals, casts and sizeof: 42 - 5 + 8 + 1 + 'i'
	(let ((init (dlsym lib "initialised")))
	  (expect "globals keep their initialisers" (and (not (= 0 init)) (= (+ 46 ?i) ((subr init ">l")))))))))
;; a library has no main, so a statement at its top level would never run
(system (concat-strings "printf 'printf(\"x\");\\n' > " dir "/irl-lib-bad.irl"))
(system (concat-strings "./eval compile-irl.l --library "
			dir
			"/irl-lib-bad.irl > "
			dir
			"/irl-lib-bad.out 2>&1"))
(expect "a top-level statement in library mode is an error"
	(has? (contents-of-file-named (concat-string dir "/irl-lib-bad.out"))
	      "irl library: top-level statement in"))
(and ok (println "irl library ok"))
