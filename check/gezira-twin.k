;;; check/gezira-twin.k -- a chain of Gezira's kernels run as one Nile pipeline on a buffer of floats, for the twin laws
;;; (check/laws/gezira-twin.law): compiled with Gezira and build/gezira-twin-kernels.k (gezira_twin_build, written by
;;; check/gezira-twin-gen.l) into a C library (build/gezira-twin, by make) and into native_nile's native image, so the
;;; same chain runs in both builds and their outputs can be held to each other.
;;;   (gezira_twin_run init params steps input count out capacity) => the output's float count, or -1 if it passed
;;;   capacity or the runtime reports an error
;;; params holds steps kernels, each its number then its parameters, a process parameter a kernel the same way, nested
;;; (gezira_twin_build reads them); input holds count floats; init is gezira_start's runtime, which a run that fails
;;; leaves failed (a caller makes another).

;; the output, collected as nile_Capture does, but a chain whose output passes capacity is stopped: the runtime is
;; failed, as an allocation that fails it would, so a kernel given a span of 1e30 pixels doesn't run on
(define-struct gezira_twin_capture_vars ((data float *) (n int *) (size int)))
(define-function gezira_twin_capture_body int
  ((p nile_Process_t *) (in float *) (i int) (m int) (out float *) (j int) (n int))
  (let (((v struct gezira_twin_capture_vars *) (nile_Process_memory p))
	((status int) 0))
    (while (= status 0)
      (while (< i m)
	(if (< (indir (. (indir v) n)) (. (indir v) size))
	    (set (indir (. (indir v) data) (indir (. (indir v) n))) (indir in i)))
	(set (indir (. (indir v) n)) (+ (indir (. (indir v) n)) 1))
	(set i (+ i 1)))
      (if (> (indir (. (indir v) n)) (. (indir v) size))
	  (nile_Process_fail p NILE_STATUS_OUT_OF_MEMORY))
      (set status (nile_Process_advance_input p (addressof in) (addressof i) (addressof m))))
    (return (nile_Process_return p i j status))))
(define-function gezira_twin_capture (nile_Process_t *) ((parent nile_Process_t *) (data float *) (n int *) (size int))
  (let* (((p nile_Process_t *)
	  (nile_Process parent 1 1 (sizeof struct gezira_twin_capture_vars)
			(cast 0 nile_Process_work_function_t) gezira_twin_capture_body (cast 0 nile_Process_work_function_t))))
    (if (!= 0 (cast p long))
	(let (((v struct gezira_twin_capture_vars *) (nile_Process_memory p)))
	  (set (. (indir v) data) data)
	  (set (. (indir v) n) n)
	  (set (. (indir v) size) size)))
    (return p)))

(define-function gezira_twin_run int
  ((init long) (params float *) (steps int) (input float *) (count int) (out float *) (capacity int))
  (let* (((i nile_Process_t *) (cast init nile_Process_t *))
	 ((n int) 0)
	 ((at int) 0)
	 ((s int) 0)
	 ((head nile_Process_t *) (nile_Funnel i)))
    (while (< s steps)	; each kernel after the chain so far (nile_Process_pipe appends)
      (set head (nile_Process_pipe head (gezira_twin_build i params (addressof at))))
      (set s (+ s 1)))
    (set head (nile_Process_pipe head (gezira_twin_capture i out (addressof n) capacity)))
    (nile_Funnel_pour head input count 1)
    (nile_sync i)
    (if (or (!= 0 (nile_error i)) (> n capacity))
	(return -1))
    (return n)))

(export gezira_twin_run)
