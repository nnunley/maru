;;; gezira-twin.l -- Gezira's C build and its native image in one process, for check/laws/gezira-twin.law: the C
;;; library NILE_TWIN_LIB (build/gezira-twin.$(SO)) and the native image NILE_TWIN_IMAGE (native_nile's, with
;;; check/gezira-twin.k), each driven through gezira_twin_run on runtimes of its own.
;;;   (twin chain ps xs workers)            0 when both builds' outputs agree, else 1 (the first difference printed)
;;;   (twin_perturbed chain ps xs workers)  the same, the native side's translation moved by 1: must disagree
;;;   (twin_edges chain workers)            0 when both agree on every edge case of the chain's types, else 1
;;; chain is a list of kernel names; ps and xs are the integers the law engine drew, parameters and input values, each
;;; k the float k/16.  Outputs agree when their counts are equal and each float is within 1e-5 of the larger magnitude,
;;; at least 1e-6 (or both are the same infinity, or both NaN).

(define-function twin-env (name)
  (let ((p ((subr "getenv" "s>p") name)) (chars ()) (i 0))
    (or (and p (!= 0 p)) (error name " is not set"))
    (while (< 0 (byte-at p i)) (push chars (byte-at p i)) (set i (+ i 1)))
    (list->string (list-reverse! chars))))

;; the two builds: each a function from name to address
(define twin-lib ((subr "dlopen" "si>p") (twin-env "NILE_TWIN_LIB") 2))
(or (!= 0 twin-lib) (error "gezira-twin: can't open " (twin-env "NILE_TWIN_LIB")))
(define-function twin-c-entry (name) ((subr "dlsym" "ps>p") twin-lib name))
(load "native-image.l")
(define twin-native-entries (native-load (twin-env "NILE_TWIN_IMAGE")))
(define-function twin-native-entry (name) (or (cdr (assq (string->symbol name) twin-native-entries)) 0))
(define-function twin-build (entry)	; (start . run) for a build
  (let ((start (entry "gezira_start")) (run (entry "gezira_twin_run")))
    (or (and (!= 0 start) (!= 0 run)) (error "gezira-twin: a build lacks gezira_start or gezira_twin_run"))
    (cons (subr start "i>l") (subr run "lpippipi>i"))))
(define twin-c (twin-build twin-c-entry))
(define twin-native (twin-build twin-native-entry))
(define twin-runtimes ())	; ((build workers . init) …), a runtime made once for each build and worker count
(define-function twin-runtime (build workers)
  (let ((found (list-detect r twin-runtimes (and (= (car r) build) (= (cadr r) workers)))))
    (if found
	(cddr found)
      (let ((init ((car build) workers))) (push twin-runtimes (cons build (cons workers init))) init))))

;; the kernels: (name number input-floats output-floats parameter-floats); the number is gezira_twin_kernel's
(define twin-kernels '(("TransformPoints" 0 2 2 6)))
(define-function twin-kernel (name) (or (list-detect k twin-kernels (= name (car k))) (error "gezira-twin: no kernel " name)))

(define-function twin-floats (values)	; a C buffer of 32-bit floats
  (let ((d (data (* 4 (max 1 (list-length values))))) (i 0))
    (list-do v values (set-float-at d i (* 1.0 v)) (set i (+ i 1)))
    d))
(define-function twin-run (build chain params xs workers)	; the output floats, or () if it overflowed or failed
  (let* ((steps (list-length chain))
	 (numbers (data (* 4 (max 1 steps))))
	 (_ (let ((i 0)) (list-do name chain (set-int32-at numbers i (cadr (twin-kernel name))) (set i (+ i 1)))))
	 (capacity (+ 64 (* 4 (list-length xs))))
	 (out (data (* 4 capacity)))
	 (n ((cdr build) (twin-runtime build workers) numbers steps (twin-floats params) (twin-floats xs) (list-length xs) out capacity)))
    (and (<= 0 n)
	 (let ((floats ())) (for (i 0 n) (push floats (float-at out i))) (list-reverse! floats)))))

(define-function twin-magnitude (x) (if (< x 0) (- 0.0 x) x))
(define-function twin-near (a b)
  (or (= a b)
      (and (!= a a) (!= b b))	; both NaN
      (<= (twin-magnitude (- a b)) (max 1e-6 (* 1e-5 (max (twin-magnitude a) (twin-magnitude b)))))))
(define twin-quiet ())	; set while the perturbed twin runs: its differences are expected, not news
(define-function twin-say parts (or twin-quiet (apply println parts)))
(define-function twin-compare (chain c n)	; 0 when the outputs agree, else 1, the first difference printed
  (cond ((and (not c) (not n))	0)
	((or (not c) (not n))	(twin-say "  twin " chain ": one build failed (C " (if c "ran" "failed") ")") 1)
	((!= (list-length c) (list-length n))
	 (twin-say "  twin " chain ": " (list-length c) " floats from C, " (list-length n) " natively") 1)
	(else
	 (let ((i 0) (bad ()))
	   (while (and c (not bad))
	     (or (twin-near (car c) (car n)) (set bad (list i (car c) (car n))))
	     (set c (cdr c)) (set n (cdr n)) (set i (+ i 1)))
	   (if bad (let () (twin-say "  twin " chain ": float " (car bad) " is " (cadr bad) " from C, " (caddr bad) " natively") 1) 0)))))

(define-function twin-number (k) (/ (* 1.0 k) 16.0))
(define-function twin-params (chain ps)	; each kernel's parameters from the drawn integers, reused in turn
  (let ((out ()) (pool ps))
    (list-do name chain
      (for (j 0 (car (cddddr (twin-kernel name))))
	(or pool (set pool (or ps '(16))))
	(push out (twin-number (car pool))) (set pool (cdr pool))))
    (list-reverse! out)))
(define-function twin-whole (chain xs)	; xs cut to whole elements of the chain's input type
  (let* ((w (caddr (twin-kernel (car chain)))) (n (* w (/ (list-length xs) w))) (out ()))
    (for (i 0 n) (push out (car xs)) (set xs (cdr xs)))
    (list-reverse! out)))
(define-function twin-case (chain params xs workers perturb)
  (let ((xs (twin-whole chain xs)))
    (twin-compare chain (twin-run twin-c chain params xs workers)
		  (twin-run twin-native chain (if perturb (perturb params) params) xs workers))))

(define-function twin (chain ps xs workers) (twin-case chain (twin-params chain ps) (map twin-number xs) workers ()))
;; the translation e (TransformPoints' fifth parameter) moved by 1: every output moves by 1, past the band for any
;; value the integers can draw (|x'| under 4e4, so the band is under 0.4)
(define-function twin-perturb (params)
  (let ((i 0)) (map (lambda (p) (set i (+ i 1)) (if (= i 5) (+ p 1.0) p)) params)))
(define-function twin_perturbed (chain ps xs workers)
  (set twin-quiet 1)
  (let ((r (twin-case chain (twin-params chain ps) (map twin-number xs) workers twin-perturb))) (set twin-quiet ()) r))

;; edge cases: values (zero both signs, ±1, tiny, huge, on and between pixels), matrices (identity, singular, flips, a
;; large scale), and lengths in elements crossing the runtime's buffer (122 floats: 61 points)
(define twin-edge-values (list 0.0 (* -1.0 0.0) 1.0 -1.0 1e-30 -1e-30 1e30 -1e30 0.5 1.5 -0.5 255.0 256.0 65535.5))
(define twin-edge-matrices '((1.0 0.0 0.0 1.0 0.0 0.0) (0.0 0.0 0.0 0.0 0.0 0.0) (-1.0 0.0 0.0 1.0 0.5 0.0)
			     (0.0 1.0 1.0 0.0 0.0 -0.5) (1000.0 0.0 0.0 1000.0 -3.5 7.25)))
(define twin-edge-lengths '(0 1 2 60 61 62 121 122 123))
(define-function twin-cycle (values n)	; n floats, values over again
  (let ((out ()) (v values)) (for (i 0 n) (or v (set v values)) (push out (car v)) (set v (cdr v))) out))
(define-function twin_edges (chain workers)
  (let ((bad 0) (w (caddr (twin-kernel (car chain)))))
    (list-do m twin-edge-matrices
      (list-do len twin-edge-lengths
	(and (= 1 (twin-case chain (twin-cycle m (* 6 (list-length chain))) (twin-cycle twin-edge-values (* w len)) workers ()))
	     (set bad 1))))
    bad))
