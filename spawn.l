;;; spawn.l -- a program started directly, without a shell (doc/plans/2026-11-11-check-without-shell.md).  A <command>
;;; names the program and its arguments (argv, each one string, never split or expanded), where its input comes from (in, a
;;; path; /dev/null if none), where its output goes (out and err, paths, the same one for both in one file; inherited if
;;; none), what it changes in the environment (env, ((name . value) ...), a name with () taken out), its directory (dir),
;;; and its limits in seconds (wall, an alarm that survives exec; cpu, a resource limit).  The directory is set first, so a
;;; relative in, out or err is found there.  A child that can't be set up as asked (no such directory, a file it can't
;;; open, an error in Maru before it becomes the program) exits 127 without running it, as one that can't be started does.  (command-start c) forks it and answers its pid;
;;; (command-status c) starts it, waits, and answers the status waitpid gives: the exit code << 8, or the signal that ended
;;; it (14, SIGALRM, at its wall limit).
(require "osdefs.k")
(define-structure <command> (argv in out err env dir wall cpu))
(define spawn-fork	(subr "fork" ">i"))
(define spawn-execvp	(subr "execvp" "sp>i"))	; the program, and its arguments as C's char *argv[], ended by 0
(define spawn-open	(subr "open" "si.i>i"))
(define spawn-dup2	(subr "dup2" "ii>i"))
(define spawn-exit	(subr "_exit" "i"))
(define spawn-waitpid	(subr "waitpid" "ipi>i"))
(define spawn-status-word ((subr "malloc" "l>p") 8))
(define spawn-rlimit ((subr "malloc" "l>p") 16))	; struct rlimit: soft and hard, 64 bits each, on Darwin and Linux alike

(define-function spawn-fail (what) (print "spawn: " what "\n") (spawn-exit 127))	; in the child: it never runs the program
;; argv as C's char *argv[]: each string copied out (the child never frees it: it becomes the program or exits), each
;; pointer written in the machine's byte order, then 0.  As many arguments as the system takes, not the FFI's variadic few.
(define-function spawn-argv-array (argv)
  (or (pair? argv) (spawn-fail "no program"))
  (list-do arg argv (or (string? arg) (spawn-fail (concat-string "an argument that isn't a string: " (format "%s" arg)))))
  (let ((a ((subr "calloc" "ll>p") (+ 1 (list-length argv)) sizeof-pointer)) (i 0))
    (list-do arg argv
      (let ((p ((subr "strdup" "s>p") arg)))
	(for (k 0 sizeof-pointer)
	  (set-byte-at a (+ (* i sizeof-pointer) (if __LITTLE_ENDIAN__ k (- sizeof-pointer (+ k 1)))) (& 255 (>> p (* 8 k))))))
      (set i (+ i 1)))
    a))
(define-function spawn-fd (path flags)	; path opened, or the child ends
  (let ((fd (spawn-open path flags 420)))	; 0644 for a file it makes
    (if (< fd 0) (spawn-fail (concat-string "can't open " path)) fd)))
(define-function spawn-onto (fd target)	; fd made target, and closed, so the program inherits only 0, 1 and 2
  (spawn-dup2 fd target)
  (or (= fd target) ((subr "close" "i>i") fd)))
(define-function spawn-redirect (c)	; in the child: its input and output where c says
  (spawn-onto (spawn-fd (or (<command>-in c) "/dev/null") 0) 0)	; O_RDONLY is 0 everywhere
  (let ((out (<command>-out c)) (err (<command>-err c)) (writing (| O_WRONLY (| O_CREAT O_TRUNC))))
    (and out (spawn-onto (spawn-fd out writing) 1))
    (when err
      (if (= err out) (spawn-dup2 1 2) (spawn-onto (spawn-fd err writing) 2)))))
(define-function spawn-limit (c)	; in the child: its limits, before it becomes the program
  (let ((wall (<command>-wall c)) (cpu (<command>-cpu c)))
    (and wall ((subr "alarm" "i>i") wall))
    (when cpu
      (for (k 0 16) (set-byte-at spawn-rlimit k (& 255 (>> cpu (* 8 (% k 8))))))
      ((subr "setrlimit" "ip>i") 0 spawn-rlimit))))	; RLIMIT_CPU is 0 on Darwin and Linux

(define-function command-start (c)
  (let ((pid (spawn-fork)))
    (when (= 0 pid)
      (set error (lambda args (apply print (cons "spawn: " args)) (print "\n") (spawn-exit 127)))	; never the parent's code
      (spawn-limit c)
      (list-do e (<command>-env c)	; a name with no value is taken out of the environment
	(if (cdr e) ((subr "setenv" "ssi>i") (car e) (cdr e) 1) ((subr "unsetenv" "s>i") (car e))))
      (and (<command>-dir c) (not (= 0 ((subr "chdir" "s>i") (<command>-dir c))))
	   (spawn-fail (concat-string "no directory " (<command>-dir c))))
      (spawn-redirect c)
      (spawn-execvp (car (<command>-argv c)) (spawn-argv-array (<command>-argv c)))
      (spawn-fail (concat-string "can't start " (car (<command>-argv c)))))	; execvp came back: it couldn't be started
    pid))
(define-function spawn-status () (+ (byte-at spawn-status-word 0) (<< (byte-at spawn-status-word 1) 8)))
(define-function command-status (c)
  (spawn-waitpid (command-start c) spawn-status-word 0)
  (spawn-status))

;; What a program says and whether it ran, for code that only needs that much.
(define-function program-status (argv . files)	; argv run, its input, output and errors from and to files, if given: in out err
  (let ((a argv) (i (car files)) (o (cadr files)) (e (caddr files)))
    (command-status (make <command> argv: a in: i out: o err: e))))
(define spawn-outputs 0)
(define-function program-output (argv)	; argv run to its end: what it wrote, both streams, through a file of its own
  (let ((path (concat-strings "/tmp/maru-spawn-" (long->string ((subr "getpid" ">i"))) "-"
			      (long->string (set spawn-outputs (+ spawn-outputs 1))))))
    (program-status argv () path path)
    (let ((text (or (contents-of-file-named path) "")))
      ((subr "unlink" "s>i") path)
      text)))
(define-function exists? (path) (= 0 ((subr "access" "si>i") path 0)))	; F_OK is 0 everywhere
(define-function make-directory (path) (program-status (list "mkdir" "-p" path)))
(define-function remove-tree (path) (program-status (list "rm" "-rf" path)))
(define spawn-darwin 'unknown)
(define-function darwin? ()	; whether this is macOS, which names a shared library .dylib, not .so
  (and (= spawn-darwin 'unknown) (set spawn-darwin (= "Darwin\n" (program-output '("uname" "-s")))))
  spawn-darwin)
(define-function spawn-getenv (name)	; an environment variable's value, or (), with nothing but boot.l loaded
  (let ((p ((subr "getenv" "s>p") name)) (chars ()) (i 0))
    (and p (!= 0 p)
	 (let ()
	   (while (< 0 (byte-at p i)) (push chars (byte-at p i)) (set i (+ i 1)))
	   (list->string (list-reverse! chars))))))
(define-function spawn-runnable? (path)	; an executable file, not a directory: X_OK is 1 everywhere
  (and (= 0 ((subr "access" "si>i") path 1))
       (let ((d ((subr "opendir" "s>p") path)))
	 (or (= 0 d) (let () ((subr "closedir" "p>i") d) ())))))
(define-function find-program-in (name path)	; name's path in path's directories, the first that holds it runnable, or ()
  (let ((start 0) (found ()))
    (for (i 0 (+ 1 (string-length path)))
      (when (and (not found) (or (= i (string-length path)) (= ?: (string-at path i))))
	(let ((candidate (concat-strings (string-copy path start (- i start)) "/" name)))
	  (and (< start i) (spawn-runnable? candidate) (set found candidate)))
	(set start (+ i 1))))
    found))
(define-function find-program (name) (find-program-in name (or (spawn-getenv "PATH") "")))	; as on PATH
