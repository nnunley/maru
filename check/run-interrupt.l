;;; A check runner with one command, for run_limit to interrupt as Ctrl-C interrupts check.l: what the command started
;;; must not outlive it.
;;;   ./eval check/run-interrupt.l COMMAND
(require "check/run-status.l")
(run-status 30 (pop *arguments*))
