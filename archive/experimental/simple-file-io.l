;;; simple-file-io.l -- Simple file I/O functions for assembly generation

(define-function output-stream-open (filename)
  "Open a file for writing"
  (let ((port (open filename "w")))
    (if port
        port
      (error "Cannot open file: " filename))))

(define-function output-stream-close (port)
  "Close an output stream"
  (close port))

(define-function println (port . args)
  "Print a line to a port or stdout"
  (if (pair? args)
      ;; Writing to a port
      (let ()
        (list-do arg args
          (display arg port))
        (display "\n" port))
    ;; port is actually the first argument, print to stdout
    (let ()
      (print port)
      (print "\n"))))