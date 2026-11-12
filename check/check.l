;;; Behavior checks for the demos and the ir2 toolchain, in untyped Maru.
;;; Each case runs a program, then asserts what it should compute, using
;;; boot.l's unit-test (which stops at the first failure).
;;;
;;;   ./eval check/check.l              run every case
;;;   ./eval check/check.l pepsi ...    run the named cases; a name no case has fails

;; run directly, it keeps out of the directory a parallel run in this checkout is using
(require "check/temp.l")
(require "spawn.l")
(define tmp (if (env-var "MARU_CHECK_TMP") check-tmp (concat-strings check-tmp "/direct")))

(define-function split (str sep)
  (let ((out ()) (start 0) (n (string-length str)))
    (for (i 0 n)
      (when (= sep (string-at str i))
	(push out (string-copy str start (- i start)))
	(set start (+ i 1))))
    (and (< start n) (push out (string-copy str start (- n start))))
    (list-reverse! out)))

(define-function lines (str) (split str ?\n))
(define-function join-lines (ls) (let ((s "")) (list-do l ls (set s (concat-strings s l "\n"))) s))	; each line ended
(define-function words (str) (let ((ws ())) (list-do w (split str 32) (or (= 0 (string-length w)) (push ws w))) (list-reverse! ws)))
(define-function starts (str prefix) (and (<= (string-length prefix) (string-length str)) (= 0 (string-compare str prefix 0 (string-length prefix)))))
(define-function join-words (ws) (let ((s "")) (list-do w ws (set s (if (= 0 (string-length s)) w (concat-strings s " " w)))) s))
(define-function last (list) (while (cdr list) (set list (cdr list))) (car list))
(define-function after (line list) (while (and list (not (= line (car list)))) (set list (cdr list))) (cdr list))
(define-function until-blank (list) (let ((out ())) (while (and list (< 0 (string-length (car list)))) (push out (car list)) (set list (cdr list))) (list-reverse! out)))
(define-function select (pred list) (let ((out ())) (list-do x list (and (pred x) (push out x))) (list-reverse! out)))
(define-function string-find (str sub)
  (let ((i 0) (n (- (string-length str) (string-length sub))))
    (while (and (<= i n) (not (= sub (string-copy str i (string-length sub))))) (incr i))
    (and (<= i n) i)))

;; What a check runs: a <command> (spawn.l), or a program and its arguments as a list, started directly, never
;; through a shell (doc/plans/2026-11-11-check-without-shell.md).
(define-selector command-of (cmd) (error "not a command: " cmd))
(define-method command-of <command> () self)
(define-method command-of <pair> () (let ((argv self)) (make <command> argv: argv)))	; make binds self to what it makes
(define-function command-argv (cmd) (<command>-argv (command-of cmd)))
(define-function command-in (cmd wall out err)	; cmd with no input, a wall limit, and its output where a check keeps it
  (let ((c (command-of cmd)))
    (make <command> argv: (<command>-argv c) in: (<command>-in c) env: (<command>-env c) dir: (<command>-dir c)
	  out: (or (<command>-out c) out) err: (or (<command>-err c) err) wall: wall cpu: (<command>-cpu c))))

(define-function file-text (path) (or (contents-of-file-named path) ""))
;; cmd's status, with a limit of secs seconds, which an alarm set in the child enforces
(define-function run-status (secs cmd) (command-status (command-in cmd secs () ())))

;; Run a command with no input and a 120 s limit (or SECS); keep its
;; output in tmp/NAME.out.  Returns the output's lines, or fails the case.
;; tree_lists prints "tpeg lists ok"
(define-function subst-underscore (name)
  (concat-string "tpeg " (string-copy name 5 (- (string-length name) 5))))

(define-function run (name cmd . secs)	; its output's lines: tmp/NAME.out's, or the file the command writes its own to
  (let* ((c (command-in cmd (or (car secs) 120) (concat-strings tmp "/" name ".out") (concat-strings tmp "/" name ".err")))
	 (status (command-status c)))
    (or (= 0 status) (error "FAIL " name ": exit status " status " running: " (command-argv cmd)))
    (lines (file-text (<command>-out c)))))

;; the evaluators, each a program and its arguments, and what checks build commands from
(define eval1 '("./eval"))
(define eval2 '("./eval2" "-b" "boot2.l"))
(define eval3 '("./eval3" "-b" "boot2.l"))
(define-function with-args (argv . args) (concat-list argv args))	; argv, more arguments after
(define-function writing (argv path) (let ((a argv)) (make <command> argv: a out: path)))	; argv, its output in path
(define-function in-dir (dir argv) (let ((a argv) (d dir)) (make <command> argv: a dir: d)))	; argv run in dir
(define-function make-dir (path) (run-status 5 (list "mkdir" "-p" path)))
(define root ((subr "getcwd" "pl>s") ((subr "malloc" "l>p") 4096) 4096))	; this checkout, for a command run elsewhere
(define nile-compilers (concat-strings root "/nile/compilers/maru"))
;; Nile's Maru back end on source (absolute, or a path from the root), in a directory of its own made first: module.k, there
(define-function nile-compile (name dir module source)
  (make-dir dir)
  (run name (in-dir dir (list (concat-strings nile-compilers "/nile-to-maru-compiler.sh") module
			     (if (= ?/ (string-at source 0)) source (concat-strings root "/" source))))))
;; a run whose program writes nothing to its standard error, as a driver that leaked no block doesn't
(define-function quiet-run (name cmd . secs)
  (let ((out (apply run (cons name (cons cmd secs)))))
    (or (= 0 (string-length (file-text (concat-strings tmp "/" name ".err"))))
	(error "FAIL " name ": wrote to its standard error: " (file-text (concat-strings tmp "/" name ".err"))))
    out))
;; the files in dir whose names end in suffix, as a shell's dir/*suffix lists them, in ls's order
(define-function files-ending (dir suffix)
  (let ((out ()) (n (string-length suffix)))
    (list-do f (run (concat-strings "ls-" suffix) (list "ls" dir))
      (and (<= n (string-length f)) (= suffix (string-copy f (- (string-length f) n) n))
	   (push out (concat-strings dir "/" f))))
    (list-reverse! out)))

;; this run's scratch directory, emptied
(run-status 60 (list "rm" "-rf" tmp))
(make-dir tmp)

;; Compile FILE through the ir2 C backend and return the command that runs it.
(define-function ir2-build (name file)	; the binary, as a command with no arguments yet
  (let ((bin (concat-strings tmp "/" name)))
    (run (concat-strings name "-gen") (writing (list "./eval2" "ir-gen-c.k" "maru.k" file) (concat-strings bin ".c")))
    (run (concat-strings name "-cc") (list "cc" "-fno-builtin" "-w" "-o" bin (concat-strings bin ".c") "-ldl"))
    (list bin)))

(define *selected* *arguments*)
(set *arguments* ())
(define *ran* ())
(define-form check (name . body)
  `(when (or (not *selected*) (member? ,name *selected*))
     (push *ran* ,name)
     (unit-test ,name ,@body (println "PASS " ,name))))

;; The names in selected that no check ran.
(define-function unmatched (selected ran)	(select (lambda (n) (not (member? n ran))) selected))

;; A command's status is its exit code << 8, or the signal that ended it; one
;; still running at its limit ends by SIGALRM (14).
(define-function spawned (name c)	; c's status and output, both streams in tmp/NAME.out
  (let ((out (concat-strings tmp "/" name ".out")))
    (set (<command>-out c) out)
    (set (<command>-err c) out)
    (let ((status (command-status c)))
      (cons status (contents-of-file-named out)))))
(check "run_limit"
  (unit-assert (= 0 (command-status (make <command> argv: '("true")))))
  (unit-assert (= 256 (command-status (make <command> argv: '("false")))))
  (unit-assert (= 14 (command-status (make <command> argv: '("sleep" "30") wall: 1))))
  ;; no shell: each argument reaches the program as it is written
  (unit-assert (equal (spawned "spawn-args" (make <command> argv: '("printf" "%s|" "a;b" "c d" "$HOME" "x>y"))) '(0 . "a;b|c d|$HOME|x>y|")))
  (unit-assert (equal (spawned "spawn-env" (make <command> argv: '("printenv" "MARU_SPAWN_SEEN") env: '(("MARU_SPAWN_SEEN" . "yes"))))
		      '(0 . "yes\n")))
  (unit-assert (= 0 (command-status (make <command> argv: '("test" "-f" "check.l") dir: "check"))))
  ;; a child that can't be set up as asked never runs the program: it exits 127, as one that can't be started does
  (unit-assert (= (<< 127 8) (command-status (make <command> argv: '("true") dir: "/nonexistent-dir"))))
  (unit-assert (= (<< 127 8) (command-status (make <command> argv: '("true") out: "/nonexistent-dir/out"))))
  (unit-assert (= (<< 127 8) (command-status (make <command> argv: '("true") in: "/nonexistent-dir/in"))))
  ;; and an error in the child before it becomes the program ends the child, never the runner's code after the fork
  (unit-assert (= (<< 127 8) (command-status (make <command> argv: '(true)))))
  ;; one that can't be started says so on its standard error
  (unit-assert (let ((r (spawned "spawn-missing" (make <command> argv: '("no-such-program-anywhere")))))
		 (and (= (<< 127 8) (car r)) (string-find (cdr r) "no-such-program-anywhere"))))
  ;; a program on PATH is an executable file, not a directory or a file that can't run, as a shell finds one
  (let ((d (concat-strings tmp "/path")))
    (make-dir (concat-strings d "/a/prog"))		; a directory named prog, first on the path
    (make-dir (concat-strings d "/b"))
    (make-dir (concat-strings d "/c"))
    (contents-to-file-named "" (concat-strings d "/b/prog"))	; then a file that can't run
    (contents-to-file-named "#!/bin/sh\n" (concat-strings d "/c/prog"))
    (run-status 5 (list "chmod" "+x" (concat-strings d "/c/prog")))
    (unit-assert (equal (find-program-in "prog" (concat-strings d "/a:" d "/b:" d "/c")) (concat-strings d "/c/prog"))))
  ;; as many arguments as the system takes, past the FFI's variadic few: a hundred
  (unit-assert (let ((xs ())) (for (i 0 100) (push xs "x")) (= 100 (string-length (cdr (spawned "spawn-many" (make <command> argv: (cons "printf" (cons "%s" xs)))))))))
  (unit-assert (let ((r (spawned "spawn-both" (make <command> argv: '("ls" "check.l" "no-such-file") dir: "check"))))
		 (and (< 0 (car r)) (string-find (cdr r) "check.l") (string-find (cdr r) "no-such-file")))))

;; A name asked for that no check has fails the run instead of passing unrun.
(check "unmatched"
  (unit-assert (equal (unmatched '("pepsi" "pepsy") '("pepsi")) '("pepsy")))
  (unit-assert (equal (unmatched () '("pepsi")) ())))

;;; ---------------------------------------------------------------- osdefs

;; Every "integer X?" probe in system.osdefs is defined in osdefs.k exactly
;; when the compiler predefines X, and the host architecture is probed.
(check "osdefs"
  (let ((predefined (map cadr (map words (run "macros" '("cc" "-dM" "-E" "-x" "c" "/dev/null")))))
	(defined    (map cadr (map words (lines (contents-of-file-named "osdefs.k")))))
	(arch       (car (run "arch" '("uname" "-m"))))
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
  (let ((rows (after "correlated power spectrum:" (run "pepsi" '("./eval" "repl.l" "test-pepsi.l"))))
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
  (let ((out (run "recursion" '("./eval" "repl.l" "test-recursion.l")))
	(tree "0"))
    (for (d 1 10) (set tree (concat-strings "(add " tree " " (long->string d) ")")))
    (unit-assert (equal (select (lambda (l) (or (starts l "could not") (starts l "input matched"))) out)
			'("could not match input" "input matched: \"a\"" "input matched: \"\"" "input matched: \"a\""
			  "input matched: \"aaa\"" "input matched: \"aaaaaaaaaaaaa\"")))
    (unit-assert (equal (last out) tree))))

;; Grammars composed by calling (pb-expr) and inheriting (<lang> : <cexpr>)
;; keep their memo entries apart, and an entry rule may be left-recursive,
;; in parser.l and in text-parser.l (tpeg grammars).
(check "peg_compose"
  (unit-assert (equal (until-blank (after "; PEG recursion enabled" (run "peg-compose" '("./eval" "repl.l" "check/peg-compose.l"))))
		      '("from-a" "(+ (+ 1 2) 3)" "(+ (+ (name \"a\") (+ 1 2)) (name \"b\"))")))
  (run "peg-lr-gen" (writing '("./eval" "compile-tpeg.l" "check/peg-lr.g") (concat-strings tmp "/peg-lr.g.l")))
  (unit-assert (equal (last (run "peg-lr" (list "./eval" "check/peg-lr.l" (concat-strings tmp "/peg-lr.g.l")))) "(+ (+ 1 2) 3)")))

;; A language built at the REPL prints the 10x10 multiplication table, and
;; nfibs(n) = nfibs(n-1) + nfibs(n-2) + 1 is 2*fib(n+1) - 1.
(check "repl"
  (let* ((out (run "repl" '("./eval" "repl.l" "test-repl.l")))
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
	 (out   (run "pegen" '("./eval" "test-pegen.k"))))
    (unit-assert (member? (concat-strings "matched " (long->string stop)) out))
    (unit-assert (equal (last out) (string-copy input 0 stop)))))

;; Earley parsing of 1+2*3, with left- and right-recursive grammars: in each
;; derivation "+" is outermost, "*" sits under its right operand, and the
;; leaves are 1, 2, 3 in order.
(check "earley"
  (let ((rest (run "earley" '("./eval" "test-earley.k"))) (derivations 0))
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
  (let* ((out (run "maruby" '("./eval" "maruby.l")))
	 (results (select (lambda (l) (starts l " => ")) out)))
    (unit-assert (equal (last (after " => 12" results)) " => 3"))))

;; text-parser.l matches a string literal that ends at the end of the input.
(check "text_parser"
  (unit-assert (equal (last (run "text-parser" '("./eval" "check/text-parser.l"))) "text parser ok")))

;; Each evaluator calls C alike: subr by name or address, typed results, byte access.
(check "eval2_subr"
  (unit-assert (equal (last (run "subr" (make <command> argv: '("./eval" "check/eval2-subr.l") env: '(("MARU_SUBR_STRING" . "returned"))))) "subr ok"))
  (unit-assert (equal (last (run "subr2" (make <command> argv: '("./eval2" "-b" "boot2.l" "check/eval2-subr.l") env: '(("MARU_SUBR_STRING" . "returned"))))) "subr ok"))
  (unit-assert (equal (last (run "subr3" (make <command> argv: '("./eval3" "-b" "boot2.l" "check/eval2-subr.l") env: '(("MARU_SUBR_STRING" . "returned"))))) "subr ok")))

;; eval3 (Piumarta, 2013) beside eval2 for comparison: it runs boot2.l and the
;; same cases, and calls C by libffi (dlextern) where eval2 uses subr.
(check "eval3"
  (unit-assert (equal (last (run "eval3-strings" '("./eval3" "-b" "boot2.l" "check/boot2-strings.l"))) "boot2 strings ok"))
  (unit-assert (equal (last (run "eval3-asm" '("./eval3" "-b" "boot2.l" "check/asm-interface.l"))) "asm interface ok"))
  (unit-assert (equal (last (run "dlextern2" '("./eval2" "-b" "boot2.l" "check/dlextern.l"))) "dlextern ok"))
  (unit-assert (equal (last (run "dlextern3" '("./eval3" "-b" "boot2.l" "check/dlextern.l"))) "dlextern ok")))

;;; ---------------------------------------------------------------- asm

;; The table-driven encoders: one interface for every instruction set, under
;; both evaluators, and every row's samples against clang (check/asm-rows.l).
(check "asm_interface"
  (unit-assert (equal (last (run "asm-interface" '("./eval" "check/asm-interface.l"))) "asm interface ok"))
  (unit-assert (equal (last (run "asm-interface2" '("./eval2" "-b" "boot2.l" "check/asm-interface.l"))) "asm interface ok")))

(check "asm_rows_arm64"
  (unit-assert (equal (last (run "asm-rows-arm64" (list "./eval" "check/asm-rows.l" "arm64" tmp) 600)) "asm rows arm64 ok")))

(check "asm_rows_x64"
  (unit-assert (equal (last (run "asm-rows-x64" (list "./eval" "check/asm-rows.l" "x64" tmp) 600)) "asm rows x64 ok")))

(check "asm_rows_x86"
  (unit-assert (equal (last (run "asm-rows-x86" (list "./eval" "check/asm-rows.l" "x86" tmp) 600)) "asm rows x86 ok")))

(check "asm_coverage"
  (unit-assert (equal (last (run "asm-coverage-arm64" '("./eval" "check/asm-coverage.l" "arm64"))) "asm coverage arm64 ok"))
    (unit-assert (equal (last (run "asm-coverage-x64" '("./eval" "check/asm-coverage.l" "x64"))) "asm coverage x64 ok"))
  (unit-assert (equal (last (run "asm-coverage-x86" '("./eval" "check/asm-coverage.l" "x86"))) "asm coverage x86 ok")))

;; Encoded code runs in-process on every evaluator this host has: its own,
;; and on arm64 macOS bin/x86_64/eval2 under Rosetta.
;; whether path is a program this host can run
(define-function executable? (path) (= 0 (run-status 5 (list "test" "-x" path))))
(define host-isa (if (= "x86_64" (car (run "uname-m" '("uname" "-m")))) 'x64 'arm64))
(check "jit_run"
  (list-do e (cons (list "./eval2" host-isa)
		   (if (executable? "bin/x86_64/eval2") (list (list "bin/x86_64/eval2" 'x64)) ()))
    (let* ((name (concat-string "jit-run-" (symbol->string (cadr e))))
	   (out (run name (list (car e) "-b" "boot2.l" "check/jit-run.l" (symbol->string (cadr e))))))
      (unit-assert (equal (car out) "ABCDEFGHIJKLMNOPQRSTUVWXYZ"))
      (unit-assert (equal (last out) (concat-strings "jit run " (symbol->string (cadr e)) " ok"))))))

(check "cross_eval"
  (or (!= 'arm64 host-isa) (!= 0 (run-status 5 (make <command> argv: '("arch" "-x86_64" "/usr/bin/true") out: "/dev/null" err: "/dev/null")))
      (unit-assert (and (executable? "bin/x86_64/eval2") (executable? "bin/x86_64/eval")))))

;; cexpr.g parses C's expressions to Maru forms (check/cexpr-forms.l).
(check "cexpr_forms" (unit-assert (equal (last (run "cexpr_forms" '("./eval" "check/cexpr-forms.l"))) "cexpr forms ok")))

;; john.g reads the three complete JOHN programs to forms, with the precedence and relations the reconstruction gives (check/john-forms.l).
(check "john_forms" (unit-assert (equal (last (run "john_forms" '("./eval" "check/john-forms.l"))) "john forms ok")))
;; tpeg over any data, under each evaluator (draft-ndn-maru-typed-tree-matching-00).
(define-form on-each-evaluator (name file)
  (let ((want (concat-strings (subst-underscore name) " ok")))
    `(let ()
       (unit-assert (equal (last (run ,name (concat-list eval1 ',file))) ,want))
       (unit-assert (equal (last (run (concat-string ,name "2") (concat-list eval2 ',file))) ,want))
       (unit-assert (equal (last (run (concat-string ,name "3") (concat-list eval3 ',file))) ,want)))))
(check "tree_selectors" (on-each-evaluator "tree_selectors" ("check/tpeg-selectors.l")))
(check "tree_source" (on-each-evaluator "tree_source" ("tpeg-repl.l" "check/tpeg-source.l")))
(check "tree_lists" (on-each-evaluator "tree_lists" ("tpeg-repl.l" "check/tpeg-lists.l")))
(check "tree_args" (on-each-evaluator "tree_args" ("tpeg-repl.l" "check/tpeg-args.l")))
(check "tree_apply" (on-each-evaluator "tree_apply" ("check/tpeg-apply.l")))
(check "tree_memo" (on-each-evaluator "tree_memo" ("tpeg-repl.l" "check/tpeg-memo.l")))
(check "tree_foreign" (on-each-evaluator "tree_foreign" ("tpeg-repl.l" "check/tpeg-foreign.l")))
(check "tree_literals" (on-each-evaluator "tree_literals" ("tpeg-repl.l" "check/tpeg-literals.l")))
;; what a grammar can't do stops its definition, saying why
(check "tree_text_refuses" (on-each-evaluator "tree_text_refuses" ("tpeg-repl.l" "check/tpeg-refuses.l")))
;; cmd's output says word
(define-function output-has (text word)
  (let ((i 0) (n (- (string-length text) (string-length word))) (found ()))
    (while (and (not found) (<= i n))
      (and (= word (string-copy text i (string-length word))) (set found 1))
      (incr i))
    found))
;; cmd exits with an error, and its output says word
(define-function fails-saying (name cmd word)
  (let ((out (concat-strings tmp "/" name ".out")))
    (and (not (= 0 (command-status (command-in cmd 60 out out))))
	 (output-has (contents-of-file-named out) word))))
;; the runner removes its directory, so it refuses one it couldn't safely remove, before removing anything
(check "check_tmp"
  (list-do unsafe '("/" "" "/tmp/" "/Users" "/tmp/a b" "/tmp/x/../..")
    (unit-assert (fails-saying "check_tmp" (let ((e (list (cons "MARU_CHECK_TMP" unsafe))))
					     (make <command> argv: '("./eval" "check/parallel.l" "lines") env: e))
			       "must be a plain path under /tmp/"))))
;; non-local exit through stubs Maru writes, on every evaluator this host has, in each instruction set it runs
(define-function native-evaluators ()
  (let ((out (list eval1 eval2 eval3)))
    (and (executable? "bin/x86_64/eval")
	 (set out (concat-list out '(("bin/x86_64/eval") ("bin/x86_64/eval2" "-b" "boot2.l")))))
    out))
(check "catch"
  (list-do evaluator (native-evaluators)
    (unit-assert (equal (last (run "catch" (with-args evaluator "check/catch.l") 300)) "catch ok"))))
;; errors are survivable and leave state as it was, on every evaluator; the collector's laws hold (check/laws/gc.law)
;; the undo log's logic is undo.irl; the C every evaluator includes, undo-irl.c, is what it compiles to (make undo-irl)
(check "undo_irl"
  (let ((c (concat-strings tmp "/undo-irl.c")))
    (unit-assert (= 0 (run-status 300 (make <command> argv: '("./eval2" "compile-irl-library.l" "undo.irl") out: c err: "/dev/null"))))
    (unit-assert (= 0 (run-status 60 (list "cmp" "-s" "undo-irl.c" c))))))
(check "recover"
  (list-do evaluator (native-evaluators)
    (unit-assert (equal (last (run "recover" (with-args evaluator "check/recover.l") 300)) "recover ok"))))
;; a saved image's heap has its books in order once it's loaded (only eval saves images)
(check "gc_image"
  (let ((image (concat-strings tmp "/image")) (saver (concat-strings tmp "/save-image.l")) (reader (concat-strings tmp "/read-image.l")))
    ;; a Data keeps the length it was made with, and its bytes, across the image
    (contents-to-file-named (concat-strings "(define keep (list 1 2 3))\n(define bytes (data 8))\n(set-byte-at bytes 7 42)\n"
					    "(save \"" image "\")\n")
			    saver)
    (contents-to-file-named (concat-strings "(println ((subr \"GC_check_heap\" \">l\")))\n(println keep)\n"
					    "(println (data-length bytes) \" \" (byte-at bytes 7))\n")
			    reader)
    (run "gc_image_save" (list "./eval" saver))
    (unit-assert (equal (run "gc_image_load" (list "./eval" "-l" image reader)) '("0" "(1 2 3)" "8 42")))))
;; a law file's limit is CPU time, not wall time, so cases running beside it can't fail it: RLIMIT_CPU (0 on Darwin and
;; Linux) is set in the child and inherited by each question it forks, with an alarm at four times as long behind it
;; for a run that blocks without using the CPU.  Each run keeps its own output, the path law-file-holds answers, and a failure
;; prints its last lines.
(define-function run-cpu-status (secs cmd)
  (let ((c (command-in cmd (* 4 secs) () ())))
    (set (<command>-cpu c) secs)
    (command-status c)))
(define law-runs 0)
(define-function law-file-holds (name evaluator support file)
  (set law-runs (+ law-runs 1))
  (let* ((out (concat-strings tmp "/" name "-" (long->string law-runs) ".out"))
	 (status (run-cpu-status 300 (let ((a (with-args evaluator "check/law.l" support file))) (make <command> argv: a out: out err: out)))))
    (if (= 0 status)
	out
	(let ((all (lines (contents-of-file-named out))))
	  (println "law file " file " on " evaluator ": status " status " (a signal of 24 is the CPU limit, 14 the alarm); last lines:")
	  (while (< 10 (list-length all)) (set all (cdr all)))
	  (list-do l all (println "  " l))
	  ()))))
;; the heaviest laws are the collector's, not an instruction set's or a particular evaluator's: one with tagged integers and
;; one with boxed.  eval2 keeps recover and gc_every here, and all of them in the sweep (make check-sweep)
(define heavy-law-evaluators (list eval1 eval3))
(check "gc_laws"
  (list-do evaluator heavy-law-evaluators
    (unit-assert (law-file-holds "gc_laws" evaluator "check/laws/gc-reference.l" "check/laws/gc.law")))
  (list-do evaluator (list eval1 eval2 eval3)
    (unit-assert (law-file-holds "gc_every" evaluator "check/laws/gc-reference.l" "check/laws/gc-every.law"))))
;; boot.l's and boot2.l's class and dispatch forms agree on every evaluator, make with keyword pairs among them
(check "boot_forms"
  (list-do evaluator (list eval1 eval2 eval3)
    (unit-assert (equal (last (run "boot_forms" (with-args evaluator "check/boot-forms.l"))) "boot forms ok"))))
;; Maru's equal and equal-hash as selectors, each type's equality defined with the type, on every evaluator
(check "equal_selector"
  (list-do evaluator (list eval1 eval2 eval3)
    (unit-assert (equal (last (run "equal_selector" (with-args evaluator "check/equal.l"))) "equal ok"))))
;; hash.l's weak tables on every evaluator: an entry goes with its key, and its value keeps its key no more than the
;; table does (an ephemeron)
(check "weak_table"
  (list-do evaluator (list eval1 eval2 eval3)
    (unit-assert (equal (last (run "weak_table" (with-args evaluator "check/weak.l"))) "weak ok"))
    (unit-assert (law-file-holds "weak_table" evaluator "check/laws/weak.l" "check/laws/weak.law"))))
;; hash.l's tables against an association list, on every evaluator, and an identity table across a saved image (only eval
;; saves images), where every object has moved: it rehashes itself before answering
(check "hash_table"
  (list-do evaluator (list eval1 eval2 eval3)
    (unit-assert (law-file-holds "hash_table" evaluator "check/laws/hash.l" "check/laws/hash.law")))
  (let ((image (concat-strings tmp "/hash-image")))
    (run "hash_image_save" (list "./eval" "check/hash-image-save.l" image))
    (unit-assert (equal (run "hash_image_load" (list "./eval" "-l" image "check/hash-image-read.l"))
			'("(t t t) 0" "b t s 2 gone Array<4>(b () s 2)" "23 of 23" "weak held 1")))))
;; generated programs against a model of what they should do, and generated allocations; collecting on every allocation
;; is slow, so that runs on one evaluator with tagged integers and one without
(check "gc_model"
  (list-do evaluator heavy-law-evaluators
    (unit-assert (law-file-holds "gc_model" evaluator "check/laws/gc-model.l" "check/laws/gc-model.law")))
  (list-do evaluator (list eval1 eval3)
    (unit-assert (law-file-holds "gc_model_paced" evaluator "check/laws/gc-model.l" "check/laws/gc-model-paced.law"))))
;; exe.l's programs, the same bytes from every evaluator, run where this host can: natively, under Rosetta, or
;; in a Linux VM.  A target with nowhere to run says so.
(define-function exe-can? (argv) (= 0 (run-status 20 (let ((a argv)) (make <command> argv: a out: "/dev/null" err: "/dev/null")))))
(define-function exe-transcript (name argv . in)	; its output and exit code, its input from the file in, if any
  (let ((out (concat-strings tmp "/" name ".out")))
    (let ((status (run-status 60 (let ((a argv) (i (car in))) (make <command> argv: a in: i out: out err: "/dev/null")))))
      (list (file-text out) (>> status 8)))))
(check "exe"
  (let ((dirs '("exe1" "exe2" "exe3"))
	;; colima ssh turns every failing status into 1, so the VM says the status
	(vm '("colima" "ssh" "--" "sh" "-c" "cat > /tmp/b; chmod +x /tmp/b; /tmp/b; echo status $?; rm -f /tmp/b"))	; the VM's shell
	(mac-arm (equal (run "exe-uname" '("uname" "-sm")) '("Darwin arm64")))
	(rosetta (and (equal (run "exe-uname-s" '("uname" "-s")) '("Darwin")) (exe-can? '("arch" "-x86_64" "/usr/bin/true"))))
	(linux-vm (exe-can? '("colima" "status"))))
    (list-do d dirs (make-dir (concat-strings tmp "/" d)))
    (unit-assert (equal (last (run "exe1" (list "./eval" "check/exe.l" (concat-strings tmp "/exe1")))) "exe ok"))
    (unit-assert (equal (last (run "exe2" (with-args eval2 "check/exe.l" (concat-strings tmp "/exe2")))) "exe ok"))
    (unit-assert (equal (last (run "exe3" (with-args eval3 "check/exe.l" (concat-strings tmp "/exe3")))) "exe ok"))
    (unit-assert (fails-saying "exe-import" '("./eval" "check/exe.l" "--import-on-linux") "linux-x64 is static"))
    (unit-assert (fails-saying "exe-entry" '("./eval" "check/exe.l" "--no-entry") "isn't in the buffer"))
    (unit-assert (fails-saying "exe-unwritable" '("./eval" "check/exe.l" "--unwritable") "can't write /nonexistent/maru"))
    (list-do target '("linux-i386" "linux-x64" "linux-arm64" "macos-arm64" "macos-x64" "macos-arm64-libsystem" "macos-x64-libsystem"
		     "macos-arm64-big" "macos-x64-big" "linux-x64-big" "answer")
      (let ((one (concat-strings tmp "/exe1/" target)))
	(list-do d '("exe2" "exe3")
	  (unit-assert (exe-can? (list "cmp" one (concat-strings tmp "/" d "/" target)))))))
    (define-function exe-runs (target argv)
      (unit-assert (equal (exe-transcript target argv) (list "hello from maru\n" 42))))
    (let ((dir (concat-strings tmp "/exe1/")))
      (if mac-arm
	  (let ()
	    (list-do target '("macos-arm64" "macos-arm64-libsystem" "macos-arm64-big")
	      (exe-runs target (list (concat-strings dir target)))
	      (unit-assert (exe-can? (list "codesign" "-v" (concat-strings dir target)))))
	    (unit-assert (equal (exe-transcript "answer" (list (concat-strings dir "answer"))) (list "" 42)))
	    (unit-assert (equal (last (run "exe-jit" '("./eval2" "-b" "boot2.l" "check/exe.l" "--jit"))) "exe ok")))
	(println "exe: macos-arm64 not run here"))
      (if rosetta
	  (list-do target '("macos-x64" "macos-x64-libsystem" "macos-x64-big")
	    (exe-runs target (list "arch" "-x86_64" (concat-strings dir target))))
	(println "exe: macos-x64 not run here"))
      (if linux-vm
	  (list-do target '("linux-i386" "linux-x64" "linux-arm64" "linux-x64-big")
	    (unit-assert (equal (exe-transcript target vm (concat-strings dir target))
				(list "hello from maru\nstatus 42\n" 0))))
	(println "exe: linux targets not run here, no colima")))))
;; a grammar that stops parsing partway is an error, and doesn't quietly lose its remaining rules
(check "tree_parse_complete"
  (unit-assert (fails-saying "parse-complete" '("./eval" "compile-tpeg.l" "check/tpeg-broken.g") "stopped parsing check/tpeg-broken.g")))
;; tpeg-repl.l reads a file of code and grammars interleaved, as repl.l reads test-pepsi.l (check/tpeg-interleave.l).
(check "tree_interleave"
  (unit-assert (equal (last (run "tree_interleave" '("./eval" "tpeg-repl.l" "check/tpeg-interleave.l"))) "tpeg interleave ok"))
  (unit-assert (equal (last (run "tree_interleave2" '("./eval2" "-b" "boot2.l" "tpeg-repl.l" "check/tpeg-interleave.l"))) "tpeg interleave ok"))
  (unit-assert (equal (last (run "tree_interleave3" '("./eval3" "-b" "boot2.l" "tpeg-repl.l" "check/tpeg-interleave.l"))) "tpeg interleave ok")))
(check "tree_calc" (on-each-evaluator "tree_calc" ("tpeg-repl.l" "check/tpeg-calc.l")))
;; kscript.g reads the report's KScript listings, and kscript.l runs streams tick by tick (check/kscript.l).
(check "kscript"
  (unit-assert (equal (last (run "kscript" (concat-list '("./eval" "check/kscript.l") (files-ending "notes/sources/grammars" ".kscript"))))
		      "kscript ok")))
;; KSWorld documents headless (ksworld-run.l): a fixture of ours, and KSWorld.ks where the dbjr documents are
(check "ksworld_headless" (unit-assert (equal (last (run "ksworld_headless" '("./eval" "check/ksworld.l"))) "ksworld ok")))
;; OMeta2 grammar classes (KSWorld's KScript2 compiler passes) run from their sources on Maru's PEG (ometa2.l)
(check "ometa2" (unit-assert (equal (last (run "ometa2" '("./eval" "check/ometa2.l"))) "ometa2 ok")))
;; KSWorld's own methods from ksworld/*.st: every KScript method of KSTextLayout read, and each a method of the class
;; reading KSWorld's sources is the work (KSBox's 370 methods through the grammars, about 20 s alone), so 600 s as the heavy cases
(check "ksworld_sources" (unit-assert (equal (last (run "ksworld_sources" '("./eval" "check/ksworld-sources.l") 600)) "ksworld sources ok")))
;; the pointer in KSWorld.ks: a press, a drag, the selection drawn, a release (check/ksworld-mouse.l)
(check "ksworld_mouse" (unit-assert (equal (last (run "ksworld_mouse" '("./eval" "check/ksworld-mouse.l"))) "ksworld mouse ok")))
;; png.irl under AddressSanitizer: every fixture, good and hostile, read into a buffer of exactly its size by
;; check/png-asan.irl, so any read past the input fails the case (ASan exits non-zero)
(check "png_asan"
  (let ((both (concat-strings tmp "/png-asan.irl")))
    ;; png.irl less its export lines, then check/png-asan.irl
    (contents-to-file-named (concat-strings (join-lines (select (lambda (l) (not (starts l "export"))) (lines (file-text "png.irl"))))
					    (file-text "check/png-asan.irl"))
			    both)
    (run "png_asan_k" (writing (list "./eval" "compile-irl.l" both) (concat-strings tmp "/png-asan.k")))
    (run "png_asan_c" (writing (list "./eval2" "ir-gen-c.k" "maru.k" (concat-strings tmp "/png-asan.k")) (concat-strings tmp "/png-asan.c")))
    (run "png_asan_cc" (list "cc" "-g" "-O1" "-fsanitize=address,undefined" "-fno-builtin" "-w" "-o" (concat-strings tmp "/png-asan")
			     (concat-strings tmp "/png-asan.c") "-ldl"))
    (let ((out (run "png_asan" (concat-list (list (concat-strings tmp "/png-asan"))
					    (concat-list (files-ending "check/png" ".png") (files-ending "check/png/bad" ".png"))))))
      (unit-assert (= (list-length out) 26)))))

;; png.l: our fixtures (every deflate block and row filter), and with MARU_DBJR the front page's image (check/png.l)
(check "png" (unit-assert (equal (last (run "png" '("./eval" "check/png.l"))) "png ok")))
;; KSWorld.ks in an SDL3 window on the dummy driver: SDL's mouse events reach the document, each change drawn (check/ksworld-window.l)
;; a document in a window runs on the window's clock: a timer fires as time passes, and only then is a frame drawn
(check "ksworld_clock"
  (if (= 0 (run-status 60 '("pkg-config" "--exists" "sdl3")))
      (unit-assert (equal (last (run "ksworld_clock" (make <command> argv: '("./eval" "check/ksworld-clock.l") env: '(("SDL_VIDEO_DRIVER" . "dummy"))))) "ksworld clock ok"))
    (println "SKIP ksworld_clock: SDL3 is not installed (pkg-config --exists sdl3 fails)")))
(check "ksworld_window"
  (if (= 0 (run-status 60 '("pkg-config" "--exists" "sdl3")))
      (let ()
	(run "ksworld-window-osdefs" '("make" "-q" "sdl3.osdefs.k"))	; measured from these headers, not stale
	(unit-assert (equal (last (run "ksworld_window" (make <command> argv: '("./eval" "check/ksworld-window.l") env: '(("SDL_VIDEO_DRIVER" . "dummy"))))) "ksworld window ok")))
      (println "SKIP ksworld_window: SDL3 is not installed (pkg-config --exists sdl3 fails)")))

;; KSWorld.ks's pixels in that window: the bar, the background, a filled shape, the glyphs and the selection after a press and
;; a drag through sdl3-push (check/ksworld-pixels.l)
(check "ksworld_pixels"
  (if (= 0 (run-status 60 '("pkg-config" "--exists" "sdl3")))
      (unit-assert (equal (last (run "ksworld_pixels" (make <command> argv: '("./eval" "check/ksworld-pixels.l") env: '(("SDL_VIDEO_DRIVER" . "dummy"))))) "ksworld pixels ok"))
      (println "SKIP ksworld_pixels: SDL3 is not installed (pkg-config --exists sdl3 fails)")))

;; john-eval.l solves Hanoi by searching possible worlds, and an unknown name is an error (check/john-run.l).
(check "john_run" (unit-assert (equal (last (run "john_run" '("./eval" "check/john-run.l"))) "john run ok")))
;; JOHN as a session: time moved only by steps, echo at the prompt, failed statements undone, RN-2008-003's transcripts at john-repl.l
(check "john_session" (unit-assert (equal (last (run "john_session" '("./eval" "check/john-session.l"))) "john session ok")))
;; call by meaning: answers from a scripted model held to probes and examples, and the Ollama client against a forked server
(check "call_by_meaning" (unit-assert (equal (last (run "call_by_meaning" '("./eval" "check/meaning.l"))) "meaning ok")))
(check "plan_evidence"
  (unit-assert (equal (last (run "plan_evidence" '("./eval" "check/plan-evidence.l"))) "plan evidence ok"))
  ;; the plan as it stands replays and plans, running no check
  (unit-assert (= 0 (run-status 120 (make <command> argv: '("./eval" "notes/plan/next.l") out: "/dev/null" err: "/dev/null")))))


;; check/law.l runs law files, one outcome line per law: (status . lines) of a run over FILES.
(define-function law-run (name . files)	; files, each a path; an empty one is left out
  (let* ((out (concat-strings tmp "/" name ".out"))
	 (argv (concat-list '("./eval" "check/law.l") (select (lambda (f) (< 0 (string-length f))) files)))
	 (st (run-status 120 (make <command> argv: argv out: out err: (concat-strings tmp "/" name ".err")))))
    (cons st (lines (file-text out)))))
(define-function law-fixture (name support) (law-run name support (concat-strings "check/laws/fixtures/" name ".law")))

;; law.g reads law files and templates fill by text (check/law-compile-test.l); cexpr.law's laws hold over primaries generated from cexpr.g's records, at least 80% of them accepted; a false one is refuted, shrunk.
(check "law_cexpr"
  (unit-assert (equal (last (run "law_cexpr" '("./eval" "check/law-compile-test.l"))) "law compile ok"))
  (let* ((r (law-run "cexpr" "check/laws/cexpr.law")) (w (words (last r))) (n (string->long (last w))))
    (unit-assert (equal (list (car r) (cadr r) (caddr r) (cadddr r))
			'(0 "law conditional_right: TESTED 100" "law minus_left: TESTED 100" "law comment_blank: TESTED 100")))
    (unit-assert (and (equal (cadr w) "cexpr.primary:") (< 0 n) (<= (* 4 n) (* 5 (string->long (cadddr w)))))))
  ;; the false law shrinks to three primaries for the seed, and each parses as one
  (unit-assert (equal (law-fixture "minus-right" "")
		      '(256 "law minus_right: REFUTED a=\"\\\"\\\"\" b=\"\\\"\\\"\" c=\"6\" seed=42" "grammar cexpr.primary: accepted 3 of 6")))
  (unit-assert (equal (run "law_primary" '("./eval" "check/law-compile-test.l" "primary" "\"\"" "6")) '("yes" "yes"))))
;; rules.l: one rule set generates, checks and enumerates; size bound; occurs check; builtins (check/rules-test.l); and check/laws/engine.law's laws about unify and the three modes.
(check "law_engine"
  (unit-assert (equal (last (run "law_engine" '("./eval" "check/rules-test.l"))) "rules ok"))
  (unit-assert (equal (law-run "engine" "check/laws/engine.l" "check/laws/engine.law")
		      '(0 "law unify_equates: TESTED 100" "law unify_symmetric: TESTED 100" "law nat_exhausted: PROVED 3" "law nat_drawn: TESTED 100"))))
(check "law_rules"
  (let ((d "check/laws/fixtures/double.l"))
    (list-do c `(("tested" ,d 0 "law double_sum: TESTED 100" "law first: TESTED 100") ("proved" "" 0 "law shaded: PROVED 3")
		 ("starved" "" 256 "law blue: STARVED 0 of 2000") ("vacuous" ,d 256 "law plus_zero: VACUOUS" "law cancels: VACUOUS")
		 ("errors" "" 256 "law backwards: E_BINDING c is not the last argument of painted" "law parsed: E_GRAMMAR nope.primary names no grammar language"
		  "law listed: E_EXHAUST cexpr.primary is generated, not enumerated; use by test")
		 ("untested" "" 256 "E_NO_UNDER_TEST check/laws/fixtures/untested.law: no under test: line, so its laws test nothing")
		 ("adequacy" "check/laws/fixtures/holds.l" 256 "law listed: TESTED 100" "law painted_listed: TESTED 100" "law adequate: PROVED 7"
		  "law weak: REFUTED 6 of 7 survive: color(Red:=Green) color(Red:=Blue) -color(Red) color(Green:=Red) color(Green:=Blue) -color(Green)"
		  "law typo: E_ADEQUATE no rule concludes paintd, so it has no mutants")
		 ;; functions in a law file, by cases too, and a list as a domain, named and shared with a schema
		 ("functions" "" 0 "law doubles: PROVED 3" "law applied: PROVED 3" "law valued: PROVED 6" "law twofold: PROVED 3" "law sized: PROVED 6"
		  "law byname: PROVED 3" "law local: PROVED 3" "law own: PROVED 3" "law parens: PROVED 3")
		 ("use" "" 0 "law named: PROVED 3" "law shapes: PROVED 6")
		 ("list-domain" "" 0 "law listed: PROVED 10" "law named: PROVED 5" "law drawn: TESTED 100" "law single: PROVED 1")
		 ("numerals" "" 0 "law few: PROVED 2") ("refs" "check/laws/fixtures/refs.l" 0 "law differ: TESTED 100")
		 ("reach" "check/laws/fixtures/holds.l" 256 "law sound: PROVED 9" "law sound_uv: PROVED 9" "law direct: PROVED 2"
		  "law adequate: REFUTED 4 of 13 survive: edge(A,B:=C) -edge(A,B) edge(B:=A,C) -edge(B,C)"
		  "law adequate_uv: REFUTED 4 of 13 survive: edge(A,B:=C) -edge(A,B) edge(B:=A,C) -edge(B,C)" "law adequate_direct: direct REFUTED x=A y=C seed=44")
		 ("verdict" "check/laws/fixtures/refs.l" 256 "law truthy: E_CLAIM the claim of truthy is a verdict; compare it, e.g. `= accept`"
		  "law guarded: E_CLAIM a condition of guarded is a verdict; compare it, e.g. `= accept`" "law compared: TESTED 100")
		 ("dup" ,d 256 "E_DUPLICATE check/laws/fixtures/dup.law: two laws are named twice, so none of its laws run")
		 ("flaky" "check/laws/fixtures/flaky.l" 256 "law first: INCONCLUSIVE status=7 input=(A)" "law again: INCONCLUSIVE status=-1 input=(stand-in)")
		 ;; a per-case let is evaluated once per case, binds later domains, shrinks by recomputing (n=3 fails first; n=2 is the least)
		 ("let" "check/laws/fixtures/let.l" 256 "law let_once: PROVED 3" "law let_domain: PROVED 3" "law let_shrink: REFUTED n=2 d=4 seed=44" "law let_test: TESTED 100")
		 ;; shrinking stays in each domain, and a let after the shrunk value is computed only from values in their domains
		 ("domain-shrink" "check/laws/fixtures/domain-shrink.l" 256 "law member_only: REFUTED w=2 seed=42"
		  "law member_pair: REFUTED w=8 lw=1 seed=43" "law member_let: REFUTED w=2 r=1 seed=44")
		 ;; a range in a list, A .. B, is the whole numbers A to B (numerals 1 .. 4 and 10: five values); a long one in a claim is a
		 ;; constant, walked by loops, not thousands of nested forms or frames (they overflowed the stack)
		 ("range" "" 0 "law range_values: PROVED 5" "law range_long: PROVED 5")
		 ;; a record's fields, a list literal and = by value; a record printed readably in a refutation
		 ("fields" "check/laws/fixtures/fields.l" 256 "law fields_read: TESTED 100" "law record_value: TESTED 100" "law record_equal: TESTED 100"
		  "law shown: REFUTED n=0 r={a: 0, b: (0 0)} seed=45")
		 ;; a rule's [c | s] is a Maru list of numbers, and exhaustion over it reaches every list up to the size (1: 2 + 4, 2: 2 + 4 + 8)
		 ("lists" "check/laws/fixtures/lists.l" 0 "law lists_size_one: PROVED 6" "law lists_size_two: PROVED 14" "law lists_test: TESTED 100")
		 ;; the runtime's layout claim, as schedule.law states it: 2 widths x 2 worker counts x 14 schedules
		 ("schedule" "check/laws/fixtures/schedule.l" 0 "law layout_contracts: PROVED 56")
		 ;; classes: each passing case's share, whole percents; a cover short of its share fails the law, a cover of no class is E_COVER
		 ("classify" "check/laws/fixtures/classify.l" 256 "law classes_proved: PROVED 10 (zero 10%, small 50%)" "law classes_tested: TESTED 100 (always 100%)"
		  "law classes_let: PROVED 10 (big 40%)" "law covered: PROVED 10 (zero 10%)"
		  "law undercovered: UNDERCOVERED zero 1 of 10 < 20%, small 5 of 10 < 60%" "law refuted_classes: REFUTED n=5 seed=47"
		  "law cover_unknown: E_COVER cover names big, which no classify declares" "law cover_over: E_COVER cover asks 120% of zero, more than all"
		  "law class_verdict: E_CLAIM a class of class_verdict is a verdict; compare it, e.g. `= accept`"
		  "law class_crash: INCONCLUSIVE status=7 input=(0)" "law class_twice: E_COVER classify names zero twice")
		 ("classify-none" "" 256 "law none: TESTED 0" "law none_covered: UNDERCOVERED zero 0 of 0 < 5%")
		 ;; by test a cover is decided sequentially: 11 of 100 is short of 50% at once, a tenth is short of 12% and meets 9% only
		 ;; after thousands of cases, and a tenth against 10% can't be decided within 300, so fails
		 ("classify-test" "" 256 "law sampled_short: UNDERCOVERED zero 11 of 100 < 50%" "law sampled_near: UNDERCOVERED zero 915 of 9200 < 12%"
		  "law sampled_met: TESTED 8700 (zero 10%)" "law sampled_two: TESTED 5800 (zero 10%, low 50%)")
		 ("classify-cap" "" 256 "law undecided: UNDERCOVERED zero 32 of 300 < 10%"))
      (unit-assert (equal (cddr c) (law-fixture (car c) (cadr c))))))
  ;; a field the record doesn't have, or a field of a value that isn't a record, stops the run naming it (the error is printed on the output)
  (let ((r (law-fixture "empty-domain" "")))	; an empty list is no domain
    (unit-assert (and (= 256 (car r)) (string-find (contents-of-file-named (concat-strings tmp "/empty-domain.out")) "E_DOMAIN"))))
  (let ((r (law-run "leak" "check/laws/fixtures/functions.law" "check/laws/fixtures/leak.law")))	; a file's functions stay its own
    (unit-assert (and (= 256 (car r)) (string-find (contents-of-file-named (concat-strings tmp "/leak.out")) "law leaked: E_UNDEFINED double"))))
  (let ((r (law-fixture "no-case" "")))	; a term no case of a function matches stops the run, naming both
    (unit-assert (and (= 256 (car r)) (string-find (contents-of-file-named (concat-strings tmp "/no-case.out")) "E_NO_CASE: value has no case for other(0)"))))
  (list-do c '(("field-error" "no field c in the record, which has a, b") ("field-plain" "a is read from a value that is not a record"))
    (let ((r (law-fixture (car c) "check/laws/fixtures/fields.l")))
      (unit-assert (and (= 256 (car r)) (string-find (contents-of-file-named (concat-strings tmp "/" (car c) ".out")) (concat-strings "E_FIELD: " (cadr c)))))))
  ;; a crashed reference is no verdict, in a claim or a condition; a claim that exits leaves its law's name last
  (let ((r (law-fixture "inconclusive" "check/laws/fixtures/inconclusive.l")))
    (unit-assert (and (= 256 (car r)) (starts (cadr r) "law answers: INCONCLUSIVE status=139 input=(")
		      (starts (caddr r) "law guarded: INCONCLUSIVE status=139 input=("))))
  (let ((r (law-fixture "crash" "")))
    (unit-assert (and (= (<< 7 8) (car r)) (starts (last (cdr r)) "law boom:"))))
  ;; a - b = b - a shrinks to the smallest pair, a=0 b=0.5; the printed seed alone reproduces it
  (let* ((r (law-fixture "refuted" "check/laws/fixtures/double.l")) (w (words (caddr r))) (seed (string-copy (last w) 5 (- (string-length (last w)) 5))) (ab (and (cdddr w) (concat-strings (cadddr w) " " (car (cddddr w))))))
    (unit-assert (equal (cadr r) "law double_sum: TESTED 100"))
    (unit-assert (and (equal (list "law" "swap:" "REFUTED") (list (car w) (cadr w) (caddr w))) (equal (last w) "seed=43")
		      (equal ab "a=0 b=0.500000")))
    (contents-to-file-named (concat-strings "under test: double\ndefaults seed = " seed "\nlaw swap: all a, b: number. a - b = b - a\n") (concat-strings tmp "/reseed.law"))
    (unit-assert (equal (cdr (law-run "reseed" "check/laws/fixtures/double.l" (concat-strings tmp "/reseed.law"))) (cddr r)))))
;; a law file's rule, fact and facts lines, and a rule's continuation lines, each without its -- comment
(define-function law-uncomment (l)
  (let ((i 0) (n (string-length l)))
    (while (and (< i n) (not (and (< 0 i) (= 32 (string-at l (- i 1))) (starts (string-copy l i (- n i)) "--")))) (set i (+ i 1)))
    (while (and (< 0 i) (= 32 (string-at l (- i 1)))) (set i (- i 1)))
    (string-copy l 0 i)))
(define-function law-rule-lines (path)
  (let ((out ()) (in ()))
    (list-do l (lines (contents-of-file-named path))
      (set in (or (starts l "rule ") (starts l "fact") (and in (starts l " "))))
      (and in (push out (law-uncomment l))))
    (list-reverse! out)))
;; the Nile rules, judged by Nile's own resolver and type checker; Nile's resolver crash is no verdict
(check "law_nile"
  (let ((n "check/laws/nile-reference.l"))
    ;; nile-adequacy.law repeats nile.law's rules and facts, so its mutants are nile.law's
    (unit-assert (equal (law-rule-lines "check/laws/nile.law") (law-rule-lines "check/laws/nile-adequacy.law")))
    (unit-assert (equal (law-run "nile" n "check/laws/nile.law")
			'(0 "law sound: TESTED 100" "law generate_checks: TESTED 100" "law coverage: PROVED 1" "law agree: TESTED 100"
			  "law agree_rejected: TESTED 100" "law round_trip: TESTED 100")))
    ;; every mutant of the expr rules fails sound or agree, at one leaf per type
    (unit-assert (equal (law-run "nile_adequacy" n "check/laws/nile-adequacy.law")
			'(0 "law sound: PROVED 46" "law agree: PROVED 222" "law adequate: PROVED 69")))
    (unit-assert (equal (law-fixture "nile-crash" n) '(256 "law resolver_crash: INCONCLUSIVE status=256 input=(\"ϫ():ρ\\012forall_\\012\")")))))

;; maru.k is the one typed IR: ir.k and irgol are gone (so nothing that runs
;; can require ir.k), and irl has no ir- form.
(check "ir_retired"
  (list-do f '("ir.k" "irgol.g" "compile-irgol.l" "test.irgol" "test-ir.k")
    (unit-assert (not (let ((s (open f))) (and s (close s) 1)))))
  (list-do f '("irl.g" "compile-irl.l")
    (unit-assert (not (string-find (contents-of-file-named f) "(ir-")))))

;; irl, inheriting cexpr.g, compiles test.irl to a .k program for maru.k.
;; make builds what a check opens (make check's CHECK_LIBS); a check asserts it is current, so
;; a failed build never passes on old output
(define *shlib* (if (equal (run "uname-s" '("uname" "-s")) '("Darwin")) "dylib" "so"))
(define-function built (file) (run (concat-string "built-" file) (list "make" "-q" (concat-string "build/" file))))

;; JOHN planning by satisfiability: gates, sorts and refusals (check/sat-john.l).
(check "sat_john"
  (built (concat-string "sat." *shlib*))
  (unit-assert (equal (last (run "sat_john" '("./eval" "check/sat-john.l"))) "sat john ok")))

;; UNSAT answers carry DRAT proofs that drat-check.irl verifies, and bad proofs are rejected (check/sat-proof.l).
(check "sat_proof"
  (built (concat-string "sat." *shlib*))
  (unit-assert (equal (last (run "sat_proof" '("./eval" "check/sat-proof.l"))) "sat proof ok")))

;; sat.irl's CDCL solver answers SAT and UNSAT through IPASIR, its models checked (check/sat-core.l).
(check "sat_core"
  (built (concat-string "sat." *shlib*))
  (unit-assert (equal (last (run "sat_core" '("./eval" "check/sat-core.l"))) "sat core ok")))

;; dimacs.irl's grammar reads DIMACS formulas, rejecting a malformed file by line (check/sat-dimacs.l).
(check "sat_dimacs"
  (built (concat-string "sat." *shlib*))
  (unit-assert (equal (last (run "sat_dimacs" '("./eval" "check/sat-dimacs.l"))) "sat dimacs ok")))

;; grammars call each other's rules, and irl compiles grammar blocks to typed Maru (check/irl-grammar.l).
(check "irl_grammar"
  (built "tpeg-foreign-a.g.l") (built "tpeg-foreign-b.g.l") (built (concat-string "irl-grammar." *shlib*))
  (unit-assert (equal (last (run "irl_grammar" '("./eval" "check/irl-grammar.l"))) "irl grammar ok")))

;; compile-irl.l --library builds a shared library whose exported functions untyped Maru calls (check/irl-library.l).
(check "irl_library"
  (built (concat-string "irl-lib." *shlib*))
  (unit-assert (equal (last (run "irl_library" '("./eval" "check/irl-library.l"))) "irl library ok")))

;; raw access to any object is held to its block on every evaluator (check/byte-bounds.l)
(check "byte_bounds"
  (list-do e '(("./eval") ("./eval2") ("./eval3"))
    (unit-assert (equal (last (run "byte_bounds" (with-args e "check/byte-bounds.l"))) "byte bounds ok"))))

;; a typed program's exit status is what its main answers, through ir-gen-c's C main (check/exit-status.k)
(check "exit_status"
  (unit-assert (= (<< 3 8) (run-status 120 (ir2-build "exit-status" "check/exit-status.k")))))

(check "irl"
  (run "irl-gen" (writing '("./eval" "compile-irl.l" "test.irl") (concat-strings tmp "/irl.k")))
  (unit-assert (equal (run "irl" (ir2-build "irl" (concat-strings tmp "/irl.k")))
		      '("hello, world" "hello again" "42" "15" "15" "Point with x = 1 and y = 2" "Point with x = 1 and y = 2"
			"   2   3   5   7  11  13  17  19  23  29  31  37  41  43  47"
			"   2   3   5   7  11  13  17  19  23  29  31  37  41  43  47  53  59  61  67  71  73  79  83  89  97")))
  ;; a program's own main, with its arguments, is kept: none is generated in its place
  (run "irl-main-gen" (writing '("./eval" "compile-irl.l" "check/irl-main.irl") (concat-strings tmp "/irl-main.k")))
  (unit-assert (equal (run "irl-main" (with-args (ir2-build "irl-main" (concat-strings tmp "/irl-main.k")) "one" "two"))
		      '("main sees 3 arguments, the last two")))
  (run "irl-errors-gen" (writing '("./eval" "compile-irl.l" "check/irl-errors.irl") (concat-strings tmp "/irl-errors.k")))
  (unit-assert (equal (last (run "irl-errors" (list "./eval2" "ir-gen-c.k" "check/irl-errors.l" "maru.k" (concat-strings tmp "/irl-errors.k"))))
		      "irl errors ok")))

(check "asm_patch"
  (unit-assert (equal (last (run "asm-patch-arm64" '("./eval" "check/asm-patch.l" "arm64"))) "asm patch arm64 ok"))
    (unit-assert (equal (last (run "asm-patch-x64" '("./eval" "check/asm-patch.l" "x64"))) "asm patch x64 ok"))
  (unit-assert (equal (last (run "asm-patch-x86" '("./eval" "check/asm-patch.l" "x86"))) "asm patch x86 ok")))

;;; ---------------------------------------------------------------- ir2

;; maru-test.k's sieve prints the primes below 32, then its struct code sets
;; x = 42 and y = 666, sums them and doubles both.  The two lines after the
;; primes read uninitialised memory and are skipped.
;; data-length answers what a Data was made with (check/data-length.l), on the evaluators that have it
(check "data_length"
  (list-do e '(("./eval") ("./eval3"))
    (unit-assert (equal (last (run "data_length" (with-args e "check/data-length.l"))) "data-length ok"))))
;; typed Maru compiled to native code in-process and called by address (check/native.l, native.l)
(check "native_ir2" (unit-assert (equal (last (run "native_ir2" '("./eval2" "check/native.l") 300)) "native ok")))
;; the same on x86-64: natively where the host is x86-64 (above), and here only as a smoke test under Rosetta, where
;; bin/x86_64/eval2 is built (arm64 macOS); it takes over a minute alone, so both get 300 s, for a loaded machine
(check "native_ir2_x64"
  (if (executable? "bin/x86_64/eval2")
      (unit-assert (equal (last (run "native_ir2_x64" '("bin/x86_64/eval2" "check/native.l") 300)) "native ok"))
    (println "native_ir2_x64: SKIP, no bin/x86_64/eval2")))
;; a unit saved as a code image on eval2, loaded and called on eval and eval3 with native-image.l alone
(check "native_image"
  (let ((dir (concat-strings tmp "/native-image")))
    (make-dir dir)
    (unit-assert (equal (last (run "native_image_save" (list "./eval2" "check/native-image-save.l" dir))) "saved"))
    (unit-assert (equal (last (run "native_image_eval" (list "./eval" "check/native-image.l" dir))) "image ok"))
    (unit-assert (equal (last (run "native_image_eval3" (list "./eval3" "check/native-image.l" dir))) "image ok"))))
(check "maru_test"
  (let* ((out (run "maru_test" (with-args (ir2-build "maru-test" "maru-test.k") "32")))
	 (primes ()))
    (for (n 2 32) (or (select (lambda (p) (= 0 (% n p))) primes) (set primes (concat-list primes (list n)))))
    (unit-assert (equal (map string->long (words (car out))) primes))
    (unit-assert (member? "sum is 708" out))
    (unit-assert (equal (last out) "print-foo: 84 1332"))))

;; Core forms give the same integers, and comparisons the same truth, untyped
;; and through maru.k (check/core-forms.l).
(check "core_forms"
  (run "core_forms-gen" (writing '("./eval" "check/core-forms.l" "k") (concat-strings tmp "/core-forms.k")))
  (let ((untyped (run "core_forms-untyped" '("./eval" "check/core-forms.l"))))
    (unit-assert (= 23 (list-length untyped)))
    (unit-assert (equal (run "core_forms" (ir2-build "core-forms" (concat-strings tmp "/core-forms.k"))) untyped))))

;; The x86 assembler generated from gen-asm-x86.k encodes as clang -target i386
;; does: check/asm-x86.l assembles movl, addl, pushl, an SIB load, int, call, ret.
(check "asm_x86"
  (unit-assert (equal (car (run "asm_x86" '("./eval" "check/asm-x86.l")))
		      "b8 2a 00 00 00 01 ca 53 8b 7c b5 08 cd 80 81 c4 e8 03 00 00 e8 e7 ff ff ff c3 8b 45 00 8b 7c b5 00 ")))

(check "ir2"        (unit-assert (equal (last (run "ir2" (ir2-build "ir2" "check/ir2.k"))) "ir2 ok")))
(check "zero_global" (unit-assert (equal (last (run "zero_global" (ir2-build "zero-global" "check/zero-global.k"))) "zero global ok")))

;; Upstream's own ir2 conformance test: one "... ok" line per section.
(check "maru_check"
  (let ((out (run "maru_check" (ir2-build "maru-check" "maru-check.k"))))
    (list-do s '("bytes" "words" "ints" "floats" "structs" "pointers")
      (unit-assert (member? (concat-strings s " ok") out)))))

;; maru-label.k (Piumarta, 2013): label and goto, plain and computed, through
;; the C back end. x counts down from 10; 9 and 7 jump to their labels, and 5
;; jumps through a label held in a variable to the function's end.
(check "maru_label"
  (let ((out (run "maru_label" (ir2-build "maru-label" "maru-label.k"))))
    (unit-assert (equal (cdr out) '("10" "9" "GOT 9" "8" "7" "GOT 7" "6" "5" "GOT 5")))))

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

;;; ---------------------------------------------------------------- sdl3

;; sdl3.k (typed; sdl3.osdefs.k measured from SDL3's headers) opens a window on SDL's dummy video driver,
;; draws a known frame, reads it back and round-trips synthetic mouse and key events (check/sdl3-window.k).
;; Without SDL3 (pkg-config, or pkg-config itself, finds no sdl3) it says it skipped and passes.
(check "sdl3_window"
  (if (= 0 (run-status 60 '("pkg-config" "--exists" "sdl3")))
      (let ((prog (concat-strings tmp "/sdl3-window")))
	(run "sdl3-osdefs-built" '("make" "-q" "sdl3.osdefs.k"))	; measured from these headers, not stale
	(contents-to-file-named (concat-strings (file-text "sdl3.osdefs.k") (file-text "sdl3.k") (file-text "check/sdl3-window.k"))
				(concat-strings tmp "/sdl3-window.k"))
	(run "sdl3-window-gen" (writing (list "./eval2" "ir-gen-c.k" "maru.k" (concat-strings tmp "/sdl3-window.k")) (concat-strings prog ".c")))
	(run "sdl3-window-cc" (concat-list (list "cc" "-fno-builtin" "-w" "-o" prog (concat-strings prog ".c"))
					   (words (car (run "sdl3-libs" '("pkg-config" "--libs" "sdl3"))))))
	(unit-assert (equal (last (run "sdl3_window" (let ((a (list prog))) (make <command> argv: a env: '(("SDL_VIDEO_DRIVER" . "dummy"))))))
			    "sdl3 ok")))
      (println "SKIP sdl3_window: SDL3 is not installed (pkg-config --exists sdl3 fails)")))

;;; ---------------------------------------------------------------- boot2

;; boot2.l defines in Maru the string and number operations eval2 dropped.
(check "boot2_strings"
  (unit-assert (equal (last (run "boot2-strings" '("./eval2" "-b" "boot2.l" "check/boot2-strings.l"))) "boot2 strings ok")))

;; Nile's compiler runs on eval2 and boot2.l (nile-to-maru-compiler.sh) and
;; writes what it wrote on eval and boot.l, the oracle kept only here.
(check "nile_compile"
  (let ((c nile-compilers))
    (make-dir (concat-strings tmp "/old"))
    (run "nile-old" (in-dir (concat-strings tmp "/old")
			    (list (concat-strings root "/eval") "-b" (concat-strings root "/boot.l") "-L" (concat-strings root "/")
				  (concat-strings c "/nile-compiler.l") c "maru" "text-layout"
				  (concat-strings root "/nile/examples/text-layout.nl"))))
    (nile-compile "nile-new" (concat-strings tmp "/new") "text-layout" "nile/examples/text-layout.nl")
    (let ((was (contents-of-file-named (concat-strings tmp "/old/text-layout.k")))
	  (now (contents-of-file-named (concat-strings tmp "/new/text-layout.k"))))
      (unit-assert (< 1000 (string-length was)))
      (unit-assert (equal was now)))))

;; nile.k declares every call of the RFC's public and kernel interface tables
;; (in their order), and Nile's Maru generator passes sizeof_vars as the
;; fourth argument of nile_Process (R-one-interface). The link half, test/
;; interface.k against the runtime, waits for the runtime's task; until then
;; this asserts the declarations and the generator.
;;; ---------------------------------------------------------------- nile runtime in maru

;; The runtime's files, in the order they're compiled; later tasks append theirs.
(define nile-dir "nile/runtimes/maru/")
(define nile-runtime '("nile.k" "nile-sync.k" "nile-heap.k" "nile-deque.k" "nile-thread.k" "nile-process.k" "nile-kernel.k" "nile-builtins.k"))

(define-function unique (items)
  (let ((out ()))
    (list-do x items (or (member? x out) (push out x)))
    (list-reverse! out)))

;; Compiles FILES (paths from the root) with nile.osdefs measured for this host and the runtime's
;; files, in one ir-gen-c run, then cc -pthread.  nile.k is the runtime's first file and is loaded
;; once, so kernels don't load it; a file named twice is compiled once.  Returns the binary's path.
(define-function nile-build (name files cflags)
  (let* ((osdefs  (concat-strings tmp "/" name ".osdefs"))
	 (listed  ())
	 (inputs  ()))
    (list-do f nile-runtime (push listed (concat-strings nile-dir f)))
    (list-do f files (push listed f))
    (set inputs (unique (list-reverse! listed)))
    (run (concat-strings name "-osdefs-c") (writing (list "./eval" "compile-osdefs.l" (concat-strings nile-dir "nile.osdefs"))
						    (concat-strings osdefs ".c")))
    (run (concat-strings name "-osdefs-cc") (list "cc" "-o" (concat-strings osdefs ".exe") (concat-strings osdefs ".c")))
    (run (concat-strings name "-osdefs") (writing (list (concat-strings osdefs ".exe")) (concat-strings osdefs ".k")))
    (run (concat-strings name "-gen") (writing (concat-list (list "./eval2" "ir-gen-c.k" "maru.k" (concat-strings osdefs ".k")) inputs)
					       (concat-strings tmp "/" name ".c")))
    (run (concat-strings name "-build") (concat-list (concat-list '("cc" "-pthread" "-fno-builtin" "-w") (words cflags))
						     (list "-o" (concat-strings tmp "/" name) (concat-strings tmp "/" name ".c"))))
    (list (concat-strings tmp "/" name))))

;; The pthread types nile.osdefs measures are the sizes nile-sync.k's opaque structs have: the typed
;; driver and the C driver print the same line (R-opaque-pthread).
(check "nile_osdefs"
  (let* ((typed (run "nile-osdefs-typed"
		     (nile-build "nile-osdefs" (list (concat-strings nile-dir "test/osdefs.k")) "")))
	 (_     (run "nile-osdefs-cc" (list "cc" "-pthread" "-w" "-o" (concat-strings tmp "/nile-osdefs-c") (concat-strings nile-dir "test/osdefs.c"))))
	 (c     (run "nile-osdefs-c" (list (concat-strings tmp "/nile-osdefs-c")))))
    (unit-assert (equal typed c))
    (unit-assert (and typed (not (cdr typed))))))

;; Startup, sync and shutdown with 1, 2 and 8 workers and with too little memory; the driver
;; prints one line per case and nothing to stderr, so no block leaked (R-startup).
(check "nile_startup"
  (let* ((bin (nile-build "nile-startup" (list (concat-strings nile-dir "test/startup.k")) ""))
	 (out (quiet-run "nile-startup-run" bin)))
    (unit-assert (equal out '("startup 1 ok" "startup 2 ok" "startup 8 ok" "startup small ok")))))

;; Many pipelines of hand-written reciprocal kernels, with 1, 2 and 8 workers, must each
;; give the direct sum (R-recip, R-threads); the driver prints one line when they all do.
(check "nile_recip"
  (let ((bin (nile-build "nile-recip" (list (concat-strings nile-dir "test/recip.k")) "")))
    (list-do n '("1" "2" "8")
      (unit-assert (equal (quiet-run (concat-strings "nile-recip-" n) (with-args bin n) 300)
			  '("recip ok"))))))

;; Variable records, elements and partial feeds the runtime refuses with BAD_ARG (R-vars-fit,
;; R-element-fits, review focus 4).
(check "nile_limits"
  (let* ((bin (nile-build "nile-limits" (list (concat-strings nile-dir "test/limits.k")) ""))
	 (out (quiet-run "nile-limits-run" bin)))
    (unit-assert (equal out '("vars-fit ok" "element-fits ok" "partial-element ok")))))

;; Too little memory for the pipeline sets nile_error and OUT_OF_MEMORY without a crash (R-oom).
(check "nile_oom"
  (let* ((bin (nile-build "nile-oom" (list (concat-strings nile-dir "test/oom.k")) ""))
	 (out (quiet-run "nile-oom-run" bin 120)))
    (unit-assert (equal out '("oom ok")))))

;; Pushing back at a buffer's start, and an empty stream through a prologue and epilogue
;; (R-prefix, review focus 3), with 1 and 2 workers.
(check "nile_prefix"
  (let ((bin (nile-build "nile-prefix" (list (concat-strings nile-dir "test/prefix.k")) "")))
    (list-do n '("1" "2")
      (unit-assert (equal (quiet-run (concat-strings "nile-prefix-" n) (with-args bin n) 300)
			  '("prefix ok" "empty ok"))))))

;; A rerouted pipeline gives the kernel's output, then the sub-pipeline's (R-reroute), with 1 and 2 workers.
(check "nile_reroute"
  (let ((bin (nile-build "nile-reroute" (list (concat-strings nile-dir "test/reroute-kernels.k") (concat-strings nile-dir "test/reroute.k")) "")))
    (list-do n '("1" "2")
      (unit-assert (equal (quiet-run (concat-strings "nile-reroute-" n) (with-args bin n) 300)
			  '("reroute ok"))))))

;; Reverse, SortBy, and DupCat and DupZip, with 1 and 2 workers (R-reverse, R-sort, R-dupcat).
(check "nile_reverse"
  (let ((bin (nile-build "nile-reverse" (list (concat-strings nile-dir "test/reverse.k")) "")))
    (list-do n '("1" "2")
      (unit-assert (equal (quiet-run (concat-strings "nile-reverse-" n) (with-args bin n) 300)
			  '("reverse ok"))))))

(check "nile_sort"
  (let ((bin (nile-build "nile-sort" (list (concat-strings nile-dir "test/sort.k")) "")))
    (list-do n '("1" "2")
      (unit-assert (equal (quiet-run (concat-strings "nile-sort-" n) (with-args bin n) 300)
			  '("sort ok"))))))

(check "nile_dupcat"
  (let ((bin (nile-build "nile-dupcat" (list (concat-strings nile-dir "test/dupcat.k")) "")))
    (list-do n '("1" "2")
      (unit-assert (equal (quiet-run (concat-strings "nile-dupcat-" n) (with-args bin n) 300)
			  '("dupcat ok" "dupzip ok"))))))

; text-layout.nl, compiled by Nile's Maru back end (module text_layout: a hyphen isn't in a C name),
; runs through the runtime with one worker and with eight, and lays out its glyphs as it should (R-text-layout).
(check "nile_text_layout"
  (let* ((gen (concat-strings tmp "/text-layout-gen"))
	 (_   (nile-compile "text-layout-gen" gen "text_layout" "nile/examples/text-layout.nl"))
	 (bin (nile-build "nile-text-layout" (list (concat-strings gen "/text_layout.k") (concat-strings nile-dir "test/text-layout.k")) "")))
    (list-do n '("1" "8")
      (unit-assert (equal (quiet-run (concat-strings "nile-text-layout-" n) (with-args bin n) 300)
			  '("text-layout ok"))))))

;; Gezira's kernels, from gezira/nile/gezira.nl (the 2016 Nile source), through Nile's Maru back end and
;; the Maru runtime: a 40 by 30 rectangle at (10.5, 20) composited into an ARGB32 image, with one worker and four.
; Gezira's kernels, generated by Nile's Maru back end from gezira/nile/gezira.nl (the 2016 source), as gezira.k in tmp.
(define-function gezira-kernels ()
  (let ((gen (concat-strings tmp "/gezira-gen")))
    (nile-compile "gezira-gen" gen "gezira" "gezira/nile/gezira.nl")
    (concat-strings gen "/gezira.k")))

;; Gezira's Vector arithmetic run (check/gezira-vector.k): two kernels appended to gezira.nl add vector pairs and a number
;; to a vector, and the sums come out as vector sums. No kernel of Gezira's own adds two vectors, so this is the only check
;; of the rule.
(check "gezira_vector"
  (let* ((gen (concat-strings tmp "/gezira-vector-gen"))
	 (_   (make-dir gen))
	 (_   (contents-to-file-named (concat-strings (file-text "gezira/nile/gezira.nl") (file-text "check/gezira/vector-kernels.nl"))
				      (concat-strings gen "/gezira_vector.nl")))
	 (_   (nile-compile "gezira-vector-gen" gen "gezira_vector" (concat-strings gen "/gezira_vector.nl")))
	 (bin (nile-build "nile-gezira-vector" (list (concat-strings gen "/gezira_vector.k") "check/gezira-vector.k") "")))
    (unit-assert (equal (quiet-run "nile-gezira-vector" bin 300)
			'("gezira vector ok")))))

(check "gezira_image"
  (let* ((bin (nile-build "nile-gezira-image" (list (gezira-kernels) (concat-strings nile-dir "gezira-image.k") (concat-strings nile-dir "test/gezira-image.k")) "")))
    (list-do n '("1" "4")
      (unit-assert (equal (quiet-run (concat-strings "nile-gezira-image-" n) (with-args bin n) 300)
			  '("gezira image ok"))))))

;; gezira-maru.l: the Gezira library (build/gezira.dylib, built by make from the 2016 source and the runtime) through
;; its selectors, the same rectangle as gezira_image, on one worker and four.
;; ir-gen-c's library mode: a unit with no main, built as a shared library and opened from untyped Maru (library-mode.l)
(check "library_mode"
  (unit-assert (equal (last (run "library_mode" '("./eval" "check/library-mode.l") 120)) "library mode ok")))

(check "gezira_scene"
  (unit-assert (equal (last (run "gezira_scene" '("./eval" "check/gezira-scene.l") 300)) "gezira scene ok")))

(check "gezira_maru"
  (unit-assert (equal (last (run "gezira_maru" '("./eval" "check/gezira-maru.l") 300)) "gezira maru ok")))
;; an image as a Gezira paint, as KSWorld's GeziraFillImage paints one, and the front page's photograph (check/gezira-image-fill.l)
(check "gezira_image_fill"
  (unit-assert (equal (last (run "gezira_image_fill" '("./eval" "check/gezira-image-fill.l") 300)) "gezira image fill ok")))

; Many fills through the Gezira library's entry points, 1200 of three shapes (one a whole KSWorld page's first path, which
; outgrew the runtime's heap while DupZip buffered its second branch), on 1 and 4 workers: each returns 0, the pixels
; are right, and nile_print_leaks finds nothing (test/gezira-many.k).
(check "gezira_many"
  (let ((bin (nile-build "nile-gezira-many" (list (gezira-kernels) (concat-strings nile-dir "gezira-image.k") (concat-strings nile-dir "gezira-api.k") (concat-strings nile-dir "test/gezira-many.k")) "")))
    (list-do n '("1" "4")
      (unit-assert (equal (quiet-run (concat-strings "nile-gezira-many-" n) (with-args bin n) 300)
			  '("gezira many ok"))))))

; A KSWorld frame's fill calls (check/ksworld-frame-dump.l, from KSWorld.ks's dbjr document) rendered twice on one runtime, on 1
; and 4 workers, under AddressSanitizer and UndefinedBehaviorSanitizer; MARU_SANITIZE=thread gives ThreadSanitizer instead.
; A partial element is refused (test/gezira-rerender.k). It names ksworld so make fetches the dbjr documents.
(check "ksworld_rerender"
  (if (not (env-var "MARU_DBJR"))
      (println "SKIP ksworld_rerender: MARU_DBJR names no dbjr documents")
      (let* ((frame (concat-strings tmp "/frame.txt"))
	     (_     (run "ksworld-frame-dump" (writing '("./eval" "check/ksworld-frame-dump.l") frame)))
	     (san   (if (env-var "MARU_SANITIZE") "-g -O1 -fsanitize=thread" "-g -O1 -fsanitize=address,undefined"))
	     (bin   (nile-build "nile-gezira-rerender" (list (gezira-kernels) (concat-strings nile-dir "gezira-image.k") (concat-strings nile-dir "gezira-api.k") (concat-strings nile-dir "test/gezira-rerender.k")) san)))
	;; every fill is whole path elements, and the first is the 26-float rectangle's 24 floats (four quadratic Béziers: the
	;; floats the document's array holds)
	(unit-assert (equal (last (lines (file-text frame))) "calls 937 whole 937 first 24"))
	(list-do n '("1" "4")
	  (unit-assert (equal (quiet-run (concat-strings "nile-gezira-rerender-" n) (with-args bin n "2" frame) 600)
			      '("gezira rerender ok")))))))

; Gezira fills on a runtime with 70000 bytes a worker: the out-of-memory path runs, and each fill that can't get a block reports
; it and stops, writing only inside its scratch area (under ASan, which found the overflow this fixes), and never stalls
; (test/gezira-oom.k; the leak report on stderr is not checked, see the notes).
(check "gezira_oom"
  (let ((bin (nile-build "nile-gezira-oom" (list (gezira-kernels) (concat-strings nile-dir "gezira-image.k") (concat-strings nile-dir "gezira-api.k") (concat-strings nile-dir "test/gezira-oom.k")) "-g -O1 -fsanitize=address,undefined")))
    (list-do n '("1" "4")
      (unit-assert (equal (run (concat-strings "nile-gezira-oom-" n) (with-args bin n "70000" "3") 300)
			  '("gezira oom ok"))))))

; Zip streams: DupZip's output holds pairs before its input's second piece is poured, and every pair is right (R-zip-stream).
(check "nile_zip_stream"
  (let ((bin (nile-build "nile-zip-stream" (list (concat-strings nile-dir "test/zip-stream.k")) "")))
    (list-do n '("1" "4")
      (unit-assert (equal (quiet-run (concat-strings "nile-zip-stream-" n) (with-args bin n) 300)
			  '("zip stream ok"))))))

; DupZip pipelines, 200 runs on one worker: each run gives back everything it used, so the runtime keeps its memory
; and nile_print_leaks finds no block in no heap (R-leaks). The check's stderr is nile_print_leaks' report.
(check "nile_leaks"
  (let ((bin (nile-build "nile-leaks" (list (concat-strings nile-dir "test/leaks.k")) "")))
    (unit-assert (equal (quiet-run "nile-leaks" (with-args bin "1") 300)
			'("leaks ok")))))
;; the runtime's built-ins and text-layout.nl's pipeline as laws (check/laws/runtime.law): the batch driver
;; (nile/runtimes/maru/test/law-runtime.k), built with text-layout.nl's module, runs one pipeline per question
(check "nile_laws"
  (let* ((gen (concat-strings tmp "/nile-laws-gen"))
	 (_   (nile-compile "nile-laws-gen" gen "text_layout" "nile/examples/text-layout.nl"))
	 (bin (nile-build "nile-law-runtime" (list (concat-strings gen "/text_layout.k") (concat-strings nile-dir "test/reroute-kernels.k")
						    (concat-strings nile-dir "test/law-runtime.k")) ""))
	 (dir (concat-strings tmp "/nile-laws"))
	 (_   (make-dir dir))
	 (out (law-file-holds "nile_laws" (list "env" (concat-strings "NILE_LAW_RUNTIME=" (car bin)) (concat-strings "NILE_LAW_TMP=" dir) "./eval")
			      "check/laws/runtime.l" "check/laws/runtime.law")))
    (unit-assert out)
    (unit-assert (equal (and out (lines (contents-of-file-named out)))
			'("law pass_identity: PROVED 78" "law reverse_backwards: PROVED 78" "law reverse_involution: PROVED 78"
			  "law dupcat_is_twice: PROVED 78" "law dupzip_pairs: PROVED 78" "law sort_keys_ordered: PROVED 78"
			  "law sort_permutation: PROVED 78" "law deterministic: PROVED 260" "law words_partition: PROVED 234"
			  "law breaks_keep_words: PROVED 234" "law breaks_fit: PROVED 234" "law breaks_maximal: PROVED 234"
			  "law points_placed: PROVED 234" "law layout_deterministic: PROVED 468")))))

;; the runtime's contracts over PCT schedules (check/laws/runtime-schedules.law): the batch driver, its threads taking turns
;; by a schedule the law generates, keeps them (no buffer dropped, no process queued while running or after it was freed,
;; every block back, no deadlock) and gives one worker's output. TESTED, as a schedule is one interleaving of very many
(check "nile_schedules"
  (let* ((gen (concat-strings tmp "/nile-sched-gen"))
	 (_   (nile-compile "nile-sched-gen" gen "text_layout" "nile/examples/text-layout.nl"))
	 (bin (nile-build "nile-sched-runtime" (list (concat-strings gen "/text_layout.k") (concat-strings nile-dir "test/reroute-kernels.k")
						      (concat-strings nile-dir "test/law-runtime.k")) ""))
	 (dir (concat-strings tmp "/nile-sched"))
	 (_   (make-dir dir))
	 (out (law-file-holds "nile_schedules" (list "env" (concat-strings "NILE_LAW_RUNTIME=" (car bin)) (concat-strings "NILE_LAW_TMP=" dir) "./eval")
			      "check/laws/runtime.l" "check/laws/runtime-schedules.law")))
    (unit-assert out)
    (unit-assert (equal (and out (lines (contents-of-file-named out)))
			'("law layout_contracts: TESTED 1000" "law found_glyphs: PROVED 2"
			  "law builtin_contracts: TESTED 1000" "law reroute_contracts: TESTED 1000")))))
(check "nile_interface"
  (let ((n "nile/runtimes/maru/nile.k")
	(interface (words "nile_startup nile_shutdown nile_sync nile_status nile_error nile_dropped nile_requeued nile_unreturned nile_schedule nile_schedule_pct nile_deadlocks nile_handoffs nile_print_live nile_print_leaks nile_Process_pipe nile_Process_feed nile_Process_gate nile_Process_pipeline nile_Process_launch nile_Process nile_Process_memory nile_Process_advance_output nile_Process_advance_input nile_Process_prefix_input nile_Process_return nile_Process_reroute nile_PassThrough nile_Capture nile_Reverse nile_SortBy nile_DupZip nile_DupCat nile_Funnel nile_Funnel_pour")))
    (unit-assert (equal (run "externs" (list "grep" "-o" "(extern [A-Za-z_0-9]*)" n))
			(map (lambda (name) (concat-strings "(extern " name ")")) interface)))
    ;; The link half: interface.k, with the runtime, asks dlsym for each call. Every call of
    ;; the table is defined once Task 9 adds Reverse, SortBy, DupZip and DupCat.
    (unit-assert (equal (quiet-run "nile-iface" (nile-build "nile-iface" (list (concat-strings nile-dir "test/interface.k")) ""))
			'("nile interface: 26 calls, 0 missing")))
    (nile-compile "nile-iface-text" (concat-strings tmp "/iface") "text-layout" "nile/examples/text-layout.nl")
    (unit-assert (string-find (contents-of-file-named (concat-strings tmp "/iface/text-layout.k"))
			      "(nile_Process parent 2 3 (sizeof struct text-layout_MakeWords_vars)"))))

;;; ---------------------------------------------------------------- budget

;; The files counted, here and in the nile and gezira submodules: tracked or new but not ignored, outside notes/, named with
;; one of suffixes (".l" ...) or Makefile, and marked neither derived nor unused in .gitattributes.  Paths from the root.
(define-function ends-with? (s suffix)
  (and (<= (string-length suffix) (string-length s)) (= suffix (string-copy s (- (string-length s) (string-length suffix)) (string-length suffix)))))
(define-function counted-files (suffixes)
  (let ((out ()))
    (list-do d '("." "nile" "gezira")
      (let* ((named (select (lambda (f) (or (ends-with? f "Makefile") (let ((hit ())) (list-do x suffixes (and (ends-with? f x) (set hit 't))) hit)))
			    (run (concat-strings "files-" d) (in-dir d '("git" "ls-files" "-co" "--exclude-standard" "--" "." ":!notes")))))
	     (listed (concat-strings tmp "/files-" d ".txt"))
	     (marked ()))
	(contents-to-file-named (join-lines named) listed)
	;; check-attr says, for each file and each attribute, path: attribute: value
	(list-do l (run (concat-strings "attrs-" d) (let ((i listed) (dd d)) (make <command> argv: '("git" "check-attr" "--stdin" "derived" "unused") in: i dir: dd)))
	  (or (ends-with? l ": unspecified") (push marked (string-copy l 0 (string-find l ": ")))))
	(list-do f named
	  (or (member? f marked) (push out (if (= d ".") f (concat-strings d "/" f)))))))
    (list-reverse! out)))
(define-function newlines (text) (let ((n 0)) (for (i 0 (string-length text)) (and (= ?\n (string-at text i)) (incr n))) n))

;; Derived code and code outside the stack (marked derived or unused in
;; .gitattributes, here or in the nile and gezira submodules) doesn't count.
;; Every source line is accounted for: the count must equal the sum of the
;; entries in check/lines, and each entry that adds lines must say why.
(check "lines"
  (let ((n (let ((sum 0))
	     (list-do f (counted-files '(".l" ".k" ".g" ".c" ".h" ".nl" ".spec" ".osdefs" ".irl" ".dc" ".law" ".john"))
	       (set sum (+ sum (newlines (file-text f)))))
	     sum))
	(sum 0))
    (list-do entry (lines (contents-of-file-named "check/lines"))
      (let ((w (words entry)))
	(when w
	  (set sum (+ sum (string->long (car w))))
	  (or (cdr w) (< (string->long (car w)) 0) (error "FAIL lines: no reason given for: " entry)))))
    (or (= n sum) (error "FAIL lines: " n " source lines, but check/lines accounts for " sum
			 "; add an entry for " (- n sum) " saying why"))
    (println "lines: " n ", tests included; the budget of 20000 is soft")))

;; a grammar keeps its definition, to be reflected on: rules, parameters, bodies, annotations, inherited ones too, in process
;; and compiled to a file (grammar.l)
(check "grammar_reflect"
  (run "grammar-reflect-built" '("make" "-q" "cexpr.g.l"))	; the compiled grammar it loads is current
  (list-do evaluator (list eval1 eval2 eval3)
    (unit-assert (equal (last (run "grammar_reflect" (with-args evaluator "check/grammar-reflect.l"))) "grammar reflect ok"))))

;; what loading defined answers its own source (source.l): its form as read, its form and line counts, its text
(check "source"
  (list-do evaluator (list eval1 eval2 eval3)
    (unit-assert (equal (last (run "source" (with-args evaluator "check/source.l"))) "source ok"))
    (unit-assert (equal (last (run "source_main" (with-args evaluator "source-run.l" "check/source/main.l"))) "check/source/main.l 2 2"))
    (unit-assert (equal (last (run "source_order" (with-args evaluator "check/source-order.l"))) "a (define-function req-x () (quote a))"))))

;; definitions read from a file without running it answer what they answer loaded (source.l's file-definitions)
(check "source_lift"
  (list-do evaluator (list eval1 eval2 eval3)
    (unit-assert (equal (last (run "source_lift" (with-args evaluator "check/source-lift.l"))) "source lift ok"))))

;; a definition's tokens (source-tokens.l), as eval.c's reader divides its text, read back to its form and walked by a tree
;; grammar; whole files' tokens read back to what Maru's reader makes of them
(check "source_tokens"
  (list-do evaluator (list eval1 eval2 eval3)
    (unit-assert (equal (last (run "source_tokens" (with-args evaluator "check/source-tokens.l" "boot.l" "boot2.l" "hash.l" "check/source/defs.l")))
			"source tokens ok"))))

;; erosion and verbosity (SlopCodeBench's, erosion.l) over Maru's s-expression files, the lines check's set, held to
;; check/erosion's ledger as lines is to check/lines: each metric equals the sum of its entries, so a rise or a fall says why.
;; The files Maru's own reader can't read whole (each changes language partway, or is broken) aren't measured, and must
;; still fail to read.
(define erosion-unread '("compile.l" "gen-asm-x86.k" "maruby.l" "net/structure-diagram.k" "test-pepsi.l" "test-recursion.l"
			 "test-repl.l" "test.l"
			 "check/tpeg-broken.g"))
(check "erosion"
  (unit-assert (equal (last (run "erosion_fixtures" '("./eval" "check/erosion.l"))) "erosion ok"))
  (let ((files (select (lambda (f) (not (ends-with? f "Makefile"))) (counted-files '(".l" ".k" ".g"))))
	(measured ()))
    (list-do f files (or (member? f erosion-unread) (push measured f)))
    ;; a CPU limit, as law files have, not a wall clock: four cases at once mustn't fail it by contention
    (let* ((path (concat-strings tmp "/erosion.out"))
	   (status (run-cpu-status 300 (let ((a (concat-list (concat-list '("./eval" "erosion-run.l" "--ledger" "check/erosion" "--unread") erosion-unread)
							     (cons "--" (list-reverse! measured)))))
					 (make <command> argv: a out: path err: path))))
	   (out (lines (contents-of-file-named path))))
      (or (= 0 status) (error "FAIL erosion: exit status " status ": " (last out)))
      (list-do l out (println l))
      (or (equal (last out) "erosion matches its ledger") (error "FAIL erosion: " (car out) " per mille, but " (last out))))))

(let ((missing (unmatched *selected* *ran*)))
  (and missing (error "FAIL no check named: " missing)))
(or (env-var "MARU_CHECK_TMP") (println "all checks passed"))
