;;; Behavior checks for the demos and the ir2 toolchain, in untyped Maru.
;;; Each case runs a program, then asserts what it should compute, using
;;; boot.l's unit-test (which stops at the first failure).
;;;
;;;   ./eval check/check.l              run every case
;;;   ./eval check/check.l pepsi ...    run the named cases

(define system (subr "system" "s"))
(define tmp "/tmp/maru-check")
(system (concat-strings "rm -rf " tmp " && mkdir -p " tmp))

(define-function split (str sep)
  (let ((out ()) (start 0) (n (string-length str)))
    (for (i 0 n)
      (when (= sep (string-at str i))
	(push out (string-copy str start (- i start)))
	(set start (+ i 1))))
    (and (< start n) (push out (string-copy str start (- n start))))
    (list-reverse! out)))

(define-function lines (str) (split str ?\n))
(define-function words (str) (let ((ws ())) (list-do w (split str 32) (or (= 0 (string-length w)) (push ws w))) (list-reverse! ws)))
(define-function starts (str prefix) (and (<= (string-length prefix) (string-length str)) (= 0 (string-compare str prefix 0 (string-length prefix)))))
(define-function last (list) (while (cdr list) (set list (cdr list))) (car list))
(define-function after (line list) (while (and list (not (= line (car list)))) (set list (cdr list))) (cdr list))
(define-function until-blank (list) (let ((out ())) (while (and list (< 0 (string-length (car list)))) (push out (car list)) (set list (cdr list))) (list-reverse! out)))
(define-function select (pred list) (let ((out ())) (list-do x list (and (pred x) (push out x))) (list-reverse! out)))
(define-function string-find (str sub)
  (let ((i 0) (n (- (string-length str) (string-length sub))))
    (while (and (<= i n) (not (= sub (string-copy str i (string-length sub))))) (incr i))
    (and (<= i n) i)))

;; Run a shell command with no input and a 120 s limit; keep its output in
;; tmp/NAME.out.  Returns the output's lines, or fails the current case.
(define-function run (name cmd)
  (let ((status (system (concat-strings "exec perl -e 'alarm shift; exec @ARGV' 120 sh -c '" cmd
					"' </dev/null >" tmp "/" name ".out 2>" tmp "/" name ".err"))))
    (or (= 0 status) (error "FAIL " name ": exit status " status " running: " cmd))
    (lines (contents-of-file-named (concat-strings tmp "/" name ".out")))))

;; Compile FILE through the ir2 C backend and return the command that runs it.
(define-function ir2-build (name file)
  (run (concat-strings name "-gen") (concat-strings "./eval2 ir-gen-c.k maru.k " file " > " tmp "/" name ".c"))
  (run (concat-strings name "-cc") (concat-strings "cc -fno-builtin -w -o " tmp "/" name " " tmp "/" name ".c -ldl"))
  (concat-strings tmp "/" name))

(define *selected* *arguments*)
(set *arguments* ())
(define-form check (name . body)
  `(when (or (not *selected*) (member? ,name *selected*))
     (unit-test ,name ,@body (println "PASS " ,name))))

;;; ---------------------------------------------------------------- osdefs

;; system.osdefs.c is the checked-in bootstrap: it must be current, and
;; compiling it alone must reproduce osdefs.k.
(check "osdefs_bootstrap"
  (run "grammar" "make -s osdefs.g.l")
  (run "regen" "./eval compile-osdefs.l system.osdefs")
  (unit-assert (equal (contents-of-file-named (concat-strings tmp "/regen.out")) (contents-of-file-named "system.osdefs.c")))
  (run "osdefs-cc" (concat-strings "cc -o " tmp "/osdefs system.osdefs.c"))
  (run "osdefs-run" (concat-strings tmp "/osdefs"))
  (unit-assert (equal (contents-of-file-named (concat-strings tmp "/osdefs-run.out")) (contents-of-file-named "osdefs.k"))))

;; Every "integer X?" probe in system.osdefs is defined in osdefs.k exactly
;; when the compiler predefines X, and the host architecture is probed.
(check "osdefs"
  (let ((predefined (map cadr (map words (run "macros" "cc -dM -E -x c /dev/null"))))
	(defined    (map cadr (map words (lines (contents-of-file-named "osdefs.k")))))
	(arch       (car (run "arch" "uname -m")))
	(probes     ()))
    (list-do line (lines (contents-of-file-named "system.osdefs"))
      (when (starts line "integer")
	(list-do w (cdr (words line))
	  (and (= ?? (string-at w (- (string-length w) 1)))
	       (push probes (string-copy w 0 (- (string-length w) 1)))))))
    (unit-assert (member? (if (equal arch "x86_64") "__x86_64__" "__aarch64__") probes))
    (list-do p probes
      (unit-assert (= (not (member? p predefined)) (not (member? p defined)))))))

;;; ---------------------------------------------------------------- demos

;; testFFT's signal is a cosine at bin 2 (amplitude 1.0) plus a sine at bin 6
;; (amplitude 0.75): the power spectrum peaks at 1.0 and 0.5625, else zero.
(check "pepsi"
  (let ((rows (after "correlated power spectrum:" (run "pepsi" "./eval repl.l test-pepsi.l")))
	(heights (array)))
    (for (c 0 33) (set-array-at heights c 0.0))
    (while (and rows (not (starts (car rows) "  0.000000")))
      (let ((row (car rows)) (bar (string-find (car rows) "|")))
	(when bar
	  (for (c 0 33)
	    (and (= ?* (string-at row (+ bar (+ 1 c))))
		 (set-array-at heights c (max (array-at heights c) (string->double (car (words row)))))))))
      (set rows (cdr rows)))
    (for (c 0 33)
      (let ((h (array-at heights c)) (want (cond ((= c 2) 1.0) ((= c 6) 0.5625))))
	(unit-assert (if want (and (<= (- want 0.075) h) (<= h (+ want 0.075))) (= h 0.0)))))))

;; Left recursion in PEG: Bryan Ford's grammars match or reject as listed
;; (the file's own OUTPUT comment predates the T case), and the expression
;; grammar builds a left-associative tree over 0..9.
(check "recursion"
  (let ((out (run "recursion" "./eval repl.l test-recursion.l"))
	(tree "0"))
    (for (d 1 10) (set tree (concat-strings "(add " tree " " (long->string d) ")")))
    (unit-assert (equal (select (lambda (l) (or (starts l "could not") (starts l "input matched"))) out)
			'("could not match input" "input matched: \"a\"" "input matched: \"\"" "input matched: \"a\""
			  "input matched: \"aaa\"" "input matched: \"aaaaaaaaaaaaa\"")))
    (unit-assert (equal (last out) tree))))

;; A language built at the REPL prints the 10x10 multiplication table, and
;; nfibs(n) = nfibs(n-1) + nfibs(n-2) + 1 is 2*fib(n+1) - 1.
(check "repl"
  (let* ((out (run "repl" "./eval repl.l test-repl.l"))
	 (table (cons "1\t2\t3\t4\t5\t6\t7\t8\t9\t10\t" (after "1\t2\t3\t4\t5\t6\t7\t8\t9\t10\t" out)))
	 (a 1) (b 1))
    (for (i 1 11)
      (let ((cells (split (car table) ?\t)))
	(for (j 1 11) (unit-assert (= (* i j) (string->long (car cells)))) (set cells (cdr cells))))
      (set table (cdr table)))
    (for (k 3 17) (let ((t (+ a b))) (set a b) (set b t)))
    (unit-assert (equal (last out) (concat-strings "nfibs(15) is " (long->string (- (* 2 b) 1)))))))

;; The generated PEG matcher stops at the "." (the first character outside its
;; grammar) and returns the text before it.
(check "pegen"
  (let* ((input "hello, (parsing) world.")
	 (stop  (string-find input "."))
	 (out   (run "pegen" "./eval test-pegen.k")))
    (unit-assert (member? (concat-strings "matched " (long->string stop)) out))
    (unit-assert (equal (last out) (string-copy input 0 stop)))))

;; Earley parsing of 1+2*3, with left- and right-recursive grammars: in each
;; derivation "+" is outermost, "*" sits under its right operand, and the
;; leaves are 1, 2, 3 in order.
(check "earley"
  (let ((rest (run "earley" "./eval test-earley.k")) (derivations 0))
    (while (set rest (after "derivation:" rest))
      (let ((leaves ()) (plus ()) (star ()) (one ()))
	(list-do l (until-blank rest)
	  (let ((col (string-find l (car (words l)))))
	    (cond ((string-find l "\"+\"") (set plus col))
		  ((string-find l "\"*\"") (and one (set star col)))
		  ((string-find l "T -> ") (push leaves (string-at l (+ 6 (string-find l "T -> "))))
		   (and (= ?1 (car leaves)) (set one 1))))))
	(unit-assert (equal (list-reverse! leaves) '(?1 ?2 ?3)))
	(unit-assert (and plus star (< plus star))))
      (incr derivations))
    (unit-assert (= 2 derivations))))

;; maruby evaluates Ruby, not its @( ... ) Lisp escape: 1 + 2 * 3 + 5 uses the
;; + and * methods the program defines on <long>; foo(1, 2) defines and calls.
(check "maruby"
  (let* ((out (run "maruby" "./eval maruby.l"))
	 (results (select (lambda (l) (starts l " => ")) out)))
    (unit-assert (equal (last (after " => 12" results)) " => 3"))))

;;; ---------------------------------------------------------------- ir2

;; maru-test.k's sieve prints the primes below 32, then its struct code sets
;; x = 42 and y = 666, sums them and doubles both.  The two lines after the
;; primes read uninitialised memory and are skipped.
(check "maru_test"
  (let* ((out (run "maru_test" (concat-strings (ir2-build "maru-test" "maru-test.k") " 32")))
	 (primes ()))
    (for (n 2 32) (or (select (lambda (p) (= 0 (% n p))) primes) (set primes (concat-list primes (list n)))))
    (unit-assert (equal (map string->long (words (car out))) primes))
    (unit-assert (member? "sum is 708" out))
    (unit-assert (equal (last out) "print-foo: 84 1332"))))

(check "ir2"        (unit-assert (equal (last (run "ir2" (ir2-build "ir2" "check/ir2.k"))) "ir2 ok")))

;; Upstream's own ir2 conformance test: one "... ok" line per section.
(check "maru_check"
  (let ((out (run "maru_check" (ir2-build "maru-check" "maru-check.k"))))
    (list-do s '("bytes" "words" "ints" "floats" "structs" "pointers")
      (unit-assert (member? (concat-strings s " ok") out)))))

;; maru-gc.k builds a 256-cell list 10000 times, reporting every 1000
;; iterations and after a final collection with no roots.
(check "maru_gc"
  (let* ((reports (map words (select (lambda (l) (starts l "GC: ")) (run "maru_gc" (ir2-build "maru-gc" "maru-gc.k")))))
	 (k 0))
    (unit-assert (= 11 (list-length reports)))
    (list-do r reports
      (unit-assert (= (string->long (caddr (cdddr r))) (* 256 (if (= k 10) 10000 (* 1000 k)))))
      (incr k))
    (let ((final (last reports)))
      (unit-assert (< 0 (string->long (cadr (cdddr (cdddr final))))))
      (unit-assert (= 0 (string->long (cadr final))))
      (unit-assert (= 0 (string->long (car (cddddr (cddddr (cdr final))))))))))

;; check/gc.k replaces maru-gc.k's main to test growing and merging.
(check "maru_gc_coalesce"
  (let ((gc (contents-of-file-named "maru-gc.k")))
    (contents-to-file-named (concat-strings (string-copy gc 0 (string-find gc "(define-function main "))
					    (contents-of-file-named "check/gc.k"))
			    (concat-strings tmp "/gc.k"))
    (unit-assert (equal (last (run "gc" (ir2-build "gc" (concat-strings tmp "/gc.k")))) "gc ok"))))

;;; ---------------------------------------------------------------- budget

;; Every source line is accounted for: the count must equal the sum of the
;; entries in check/lines, and each entry that adds lines must say why.
(check "lines"
  (let ((n (string->long (car (words (car (run "count" "git ls-files -co --exclude-standard | grep -E \"[.](l|k|g|c|h|osdefs|irl|irgol|dc)$|Makefile$\" | grep -vx system.osdefs.c | xargs cat | wc -l"))))))
	(sum 0))
    (list-do entry (lines (contents-of-file-named "check/lines"))
      (let ((w (words entry)))
	(when w
	  (set sum (+ sum (string->long (car w))))
	  (or (cdr w) (< (string->long (car w)) 0) (error "FAIL lines: no reason given for: " entry)))))
    (or (= n sum) (error "FAIL lines: " n " source lines, but check/lines accounts for " sum
			 "; add an entry for " (- n sum) " saying why"))))

(println "all checks passed")
