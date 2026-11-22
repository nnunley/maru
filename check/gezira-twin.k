;;; check/gezira-twin.k -- a chain of Gezira's kernels run as one Nile pipeline on a buffer of floats, for the twin laws
;;; (check/laws/gezira-twin.law): compiled with Gezira into a C library (build/gezira-twin, by make) and into native_nile's
;;; native image, so the same chain runs in both builds and their outputs can be held to each other.
;;;   (gezira_twin_run init chain steps params input count out capacity) => the output's float count, or -1 if it would
;;;   pass capacity or the runtime reports an error
;;; chain holds steps kernel numbers (gezira_twin_kernel's), params their parameters as floats in chain order (each
;;; kernel taking gezira_twin_arity of them), input count floats; init is gezira_start's runtime.

;; kernel k's process, its parameters read from p
(define-function gezira_twin_kernel (nile_Process_t *) ((i nile_Process_t *) (k int) (p float *))
  (if (= k 0) (return (gezira_TransformPoints i (indir p 0) (indir p 1) (indir p 2) (indir p 3) (indir p 4) (indir p 5))))
  (return (cast 0 nile_Process_t *)))
;; how many parameter floats kernel k takes
(define-function gezira_twin_arity int ((k int))
  (if (= k 0) (return 6))
  (return 0))

(define-function gezira_twin_run int
  ((init long) (chain int *) (steps int) (params float *) (input float *) (count int) (out float *) (capacity int))
  (let* (((i nile_Process_t *) (cast init nile_Process_t *))
	 ((n int) 0)
	 ((at int) 0)
	 ((s int) 0)
	 ((head nile_Process_t *) (nile_Capture i out (addressof n) capacity)))
    (while (< s steps)	; the parameters' end, so the chain can be built from its last kernel back
      (set at (+ at (gezira_twin_arity (indir chain s))))
      (set s (+ s 1)))
    (while (> s 0)
      (set s (- s 1))
      (set at (- at (gezira_twin_arity (indir chain s))))
      (set head (nile_Process_pipe (gezira_twin_kernel i (indir chain s) (+ params at)) head)))
    (set head (nile_Process_pipe (nile_Funnel i) head))
    (nile_Funnel_pour head input count 1)
    (nile_sync i)
    (if (or (!= 0 (nile_error i)) (> n capacity))
	(return -1))
    (return n)))

(export gezira_twin_run)
