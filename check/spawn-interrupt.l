;;; A runner with one command, for run_limit to interrupt as Ctrl-C interrupts check.l: what the command started must
;;; not outlive it.
;;;   ./eval check/spawn-interrupt.l SHELL-COMMAND
(require "spawn.l")
(command-status (make <command> argv: (list "sh" "-c" (pop *arguments*)) wall: 30))
