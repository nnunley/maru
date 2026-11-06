;; check/exit-status.k: main's answer is the program's exit status (the exit_status case)
(define-function main int ((argc int) (argv char * *))
  (return (cast 3 int)))
