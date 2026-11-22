;;; gezira-twin.l -- Gezira's C build and its native image in one process, for check/laws/gezira-twin.law: the C
;;; library NILE_TWIN_LIB (build/gezira-twin.$(SO)) and the native image NILE_TWIN_IMAGE (native_nile's, with
;;; check/gezira-twin.k), each driven through gezira_twin_run on runtimes of its own.
;;;   (twin chain ps xs workers)            0 when both builds' outputs agree, else 1 (the first difference printed)
;;;   (twin_long chain ps xs k d workers)   the same over a long stream: xs repeated to k buffers' worth plus d elements
;;;   (twin_perturbed chain ps xs workers)  the same, the native output's first float moved past the band: must disagree
;;;   (twin_distinct workers)               1 when the two builds are two

;;; chain is a list of kernel names; ps and xs are floats the law engine drew (its float domain: simple values, every
;;; magnitude, the format's boundaries), parameters and input values.  Outputs agree when their counts are equal and each
;;; float is within 1e-5 of the larger magnitude,
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
(define twin-infinity (* 1e308 10.0))
(define-function twin-finite? (x) (and (= x x) (< (twin-magnitude x) twin-infinity)))
(define-function twin-near (a b)
  (or (= a b)
      (and (!= a a) (!= b b))	; both NaN
      (and (twin-finite? a) (twin-finite? b)	; an infinity or a NaN only equals its own kind: no band around it
	   (<= (twin-magnitude (- a b)) (max 1e-6 (* 1e-5 (max (twin-magnitude a) (twin-magnitude b))))))))
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

(define-function twin-params (chain ps)	; each kernel's parameters from the drawn floats, reused in turn
  (let ((out ()) (pool ps))
    (list-do name chain
      (for (j 0 (car (cddddr (twin-kernel name))))
	(or pool (set pool (or ps '(1.0))))
	(push out (car pool)) (set pool (cdr pool))))
    (list-reverse! out)))
(define-function twin-whole (chain xs)	; xs cut to whole elements of the chain's input type
  (let* ((w (caddr (twin-kernel (car chain)))) (n (* w (/ (list-length xs) w))) (out ()))
    (for (i 0 n) (push out (car xs)) (set xs (cdr xs)))
    (list-reverse! out)))
;; a long stream: the runtime's buffer holds 122 floats (nile-kernel.k's nile_Buffer_capacity: a 512-byte block less its
;; nile_Buffer), so w-float elements fill one every 122/w; the drawn elements, repeated, to k buffers' worth and d more
(define twin-buffer-floats 122)
(define-function twin-stream (chain xs k d)
  (let* ((w (caddr (twin-kernel (car chain)))) (xs (twin-whole chain xs)) (n (max 0 (+ (* k (/ twin-buffer-floats w)) d)))
	 (out ()) (v xs))
    (and xs (for (i 0 (* n w)) (or v (set v xs)) (push out (car v)) (set v (cdr v))))
    (list-reverse! out)))
(define-function twin-case (chain params xs workers move)	; move: the native output changed, for the self-test
  (twin-compare chain (twin-run twin-c chain params xs workers)
		(let ((n (twin-run twin-native chain params xs workers))) (if move (move n) n))))

(define-function twin (chain ps xs workers) (twin-case chain (twin-params chain ps) (twin-whole chain xs) workers ()))
(define-function twin_long (chain ps xs k d workers) (twin-case chain (twin-params chain ps) (twin-stream chain xs k d) workers ()))

;; the twin's own checks.  twin_distinct: the two builds are two (their entry points differ), so a twin that loaded one
;; build twice fails.  twin_perturbed: the native output's first float moved past the band (by 1 or a thousandth of
;; it, or an infinity made 0), so a comparison that never read the floats fails.
(define-function twin_distinct (workers)
  (if (and (!= (twin-c-entry "gezira_twin_run") (twin-native-entry "gezira_twin_run"))
	   (!= (twin-runtime twin-c workers) (twin-runtime twin-native workers)))
      1 0))
(define-function twin-moved (outs)
  (and outs
       (cons (let ((x (car outs)))
	       (cond ((or (!= x x) (> (twin-magnitude x) 1e38)) 0.0)
		     (else (+ x (max 1.0 (* 1e-3 (twin-magnitude x)))))))
	     (cdr outs))))
(define-function twin_perturbed (chain ps xs workers)
  (set twin-quiet 1)
  (let ((r (twin-case chain (twin-params chain ps) (twin-whole chain xs) workers twin-moved))) (set twin-quiet ()) r))
