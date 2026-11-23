;;; Run cmd under sh with a limit of secs seconds, which an alarm set in the child enforces (it survives exec); returns
;;; the status waitpid gives.  check.l runs every check through it; check/run-interrupt.l runs one, to be interrupted.
(define fork	(subr "fork" ">i"))
(define alarm	(subr "alarm" "i>i"))
(define execl	(subr "execl" "ss.>i"))	; two fixed arguments, the rest variadic
(define waitpid	(subr "waitpid" "ipi>i"))
(define _exit	(subr "_exit" "i"))
(define status-word ((subr "malloc" "l>p") 8))
;; The child leads a process group of its own, so at the limit, when the alarm has ended sh (or the program sh became),
;; the group is ended too: the program sh started and anything it forked, which the alarm never reaches.  Leaving the
;; terminal's group, the command no longer hears Ctrl-C, so while the runner waits an interrupt (which eval reports
;; through *backtrace* before it exits) ends the group as well; at any other time *backtrace* is as it was.
(define setpgid	(subr "setpgid" "ii>i"))
(define kill	(subr "kill" "ii>i"))
(define-function run-status (secs cmd)
  (let ((pid (fork)))
    (when (= 0 pid)
      (setpgid 0 0)
      (alarm secs)
      (execl "/bin/sh" "sh" "-c" cmd 0)
      (_exit 127))
    (let ((was *backtrace*))
      (set *backtrace* (lambda (stack depth) (kill (- 0 pid) 9)))	; only waitpid runs meanwhile
      (waitpid pid status-word 0)
      (set *backtrace* was))
    (let ((status (+ (byte-at status-word 0) (<< (byte-at status-word 1) 8))))
      (and (= 14 status) (kill (- 0 pid) 9))	; SIGALRM ended it: SIGKILL to its group
      status)))
