(define (atoi   (int	char *		) *) (extern atoi))
(define (printf (int	char * ...	) *) (extern printf))

(define-function nfibs int ((n int))
    (return (if (< n  2) 1 
            (+ (nfibs (- n 1)) (nfibs (- n 2))))))

(define-function main int ((argc int) (argv char * *))
  (let ((i 0))
    (printf "Starting test\n")
    (for (i 1 argc)
      (let ((c (atoi (indir argv i))))
          (printf "c = %d\n" c)
          (printf "nfibs(%d) = %d\n" c (nfibs c))
    )
  ))
  
  (return 0))
