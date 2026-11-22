;;; gezira-twin.l -- Gezira's C build and its native image in one process, for check/laws/gezira-twin.law: the C
;;; library NILE_TWIN_LIB (build/gezira-twin.$(SO)) and the native image NILE_TWIN_IMAGE (native_nile's, with
;;; check/gezira-twin.k), each driven through gezira_twin_run on runtimes of its own.  The kernels are
;;; build/gezira-twin-kernels.l's table, made from Gezira by check/gezira-twin-gen.l.
;;;   (twin_kernel_facts)                   kernel(name, in, out) and connects(out, in) for the law's chains
;;;   (twin chain ps xs workers)            0 when both builds' outputs agree, else 1 (the first difference printed)
;;;   (twin_long chain ps xs k d workers)   the same over a long stream: xs repeated to k buffers' worth plus d elements
;;;   (twin_perturbed chain ps xs workers)  the same, the native output's first float moved past the band: must disagree
;;;   (twin_distinct workers)               1 when the two builds are two
;;;   (twin_every_kernel workers)           each kernel no chain reached, twinned alone: the disagreements
;;; chain is a list of kernel names; ps and xs are floats the law engine drew (its float domain), parameters and input
;;; values.  A chain runs as segments, one Nile pipeline each: where a kernel reads a tuple (A, B) after a stream of A,
;;; the A stream is zipped with B elements drawn from ps.  A process parameter (a Texturer, a Compositor, a gradient's
;;; extender or colour) is a kernel of that type, picked and parameterised from ps, nested at most three deep.  Outputs
;;; agree when their counts are equal and each finite float is within 1e-5 of the larger magnitude, at least 1e-6; an
;;; infinity or NaN equals only its own kind.

(define-function twin-env (name)
  (let ((p ((subr "getenv" "s>p") name)) (chars ()) (i 0))
    (or (and p (!= 0 p)) (error name " is not set"))
    (while (< 0 (byte-at p i)) (push chars (byte-at p i)) (set i (+ i 1)))
    (list->string (list-reverse! chars))))
(load "build/gezira-twin-kernels.l")
(require "check/strings.l")

;; the two builds: (start run stop) each, from a function from name to address
(define twin-lib ((subr "dlopen" "si>p") (twin-env "NILE_TWIN_LIB") 2))
(or (!= 0 twin-lib) (error "gezira-twin: can't open " (twin-env "NILE_TWIN_LIB")))
(define-function twin-c-entry (name) ((subr "dlsym" "ps>p") twin-lib name))
(load "native-image.l")
(define twin-native-entries (native-load (twin-env "NILE_TWIN_IMAGE")))
(define-function twin-native-entry (name) (or (cdr (assq (string->symbol name) twin-native-entries)) 0))
(define-function twin-build (entry)
  (let ((start (entry "gezira_start")) (run (entry "gezira_twin_run")) (stop (entry "gezira_stop")))
    (or (and (!= 0 start) (!= 0 run) (!= 0 stop)) (error "gezira-twin: a build lacks gezira_start, gezira_stop or gezira_twin_run"))
    (list (subr start "i>l") (subr run "lpipipi>i") (subr stop "l"))))
(define twin-c (twin-build twin-c-entry))
(define twin-native (twin-build twin-native-entry))
(define twin-runtimes ())	; ((build workers . init) …), a runtime for each build and worker count, replaced if it fails
(define-function twin-runtime (build workers)
  (let ((found (list-detect r twin-runtimes (and (= (car r) build) (= (cadr r) workers)))))
    (if found
	(cddr found)
      (let ((init ((car build) workers))) (push twin-runtimes (cons build (cons workers init))) init))))
(define-function twin-drop-runtime (build workers)	; a failed runtime stays failed: stop it, and the next run makes another
  (let ((keep ()))
    (list-do r twin-runtimes (if (and (= (car r) build) (= (cadr r) workers)) ((caddr build) (cddr r)) (push keep r)))
    (set twin-runtimes keep)))

;; the kernels, by name; types as the table writes them ("Point", "(Color,Color)")
(define-function twin-kernel (name) (or (list-detect k twin-kernel-table (= name (car k))) (error "gezira-twin: no kernel " name)))
(define-function twin-number-of (k) (cadr k))
(define-function twin-in (k) (caddr k))
(define-function twin-out (k) (cadddr k))
(define-function twin-kinds (k) (car (cddddr k)))
(define-function twin-in-floats (k) (cadr (cddddr k)))
(define-function twin-out-floats (k) (caddr (cddddr k)))
;; a process parameter's kind as the stream type its kernel must have
(define twin-process-types '(("Texturer" "Point" . "Color") ("Compositor" "(Color,Color)" . "Color")
			     ("GradientExtender" "Number" . "Number") ("GradientColor" "(Number,Color)" . "(Number,Color)")))
(define-function twin-of-kind (kind)	; the kernels a process parameter of kind may be
  (let ((t (cdr (list-detect p twin-process-types (= kind (car p))))) (out ()))
    (list-do k twin-kernel-table (and (= (car t) (twin-in k)) (= (cdr t) (twin-out k)) (push out k)))
    (list-reverse! out)))
(define-function twin-tuple-head (t)	; A of a tuple type "(A,B)", or ()
  (and (< 2 (string-length t)) (= ?\( (string-at t 0))
       (let ((i 1)) (while (and (< i (string-length t)) (!= ?, (string-at t i))) (set i (+ i 1))) (string-copy t 1 (- i 1)))))
(define-function twin_kernel_facts ()
  (let ((out ()) (ins ()) (outs ()))
    (list-do k twin-kernel-table
      (push out (list 'kernel (car k) (twin-in k) (twin-out k)))
      (or (member? (twin-in k) ins) (push ins (twin-in k)))
      (or (member? (twin-out k) outs) (push outs (twin-out k))))
    (list-do o outs (list-do i ins (and (or (= o i) (= o (twin-tuple-head i))) (push out (list 'connects o i)))))
    out))

;; what has run: every kernel a case built, nested ones too
(define twin-ran (equal-hash-table))
(define twin-compared 0)	; cases whose outputs were compared
(define twin-skipped 0)	; cases outside Gezira's domain: the C build stopped (past capacity, failed, or past its time)

;; parameters: a kernel's number then its parameters, floats from the pool, a process parameter a kernel of its kind
(define-function twin-pool (ps) (cons ps ps))	; (remaining . all): drawn floats, reused in turn
(define-function twin-next (pool) (or (car pool) (set-car pool (or (cdr pool) '(1.0)))) (let ((v (car (car pool)))) (set-car pool (cdr (car pool))) v))
(define-function twin-index (x n)	; a drawn float as an index below n
  (if (or (!= x x) (> (if (< x 0) (- 0.0 x) x) 1e9)) 0 (% (double->long (if (< x 0) (- 0.0 x) x)) n)))
(define-function twin-nth (l n) (while (< 0 n) (set l (cdr l)) (set n (- n 1))) (car l))
(define-function twin-encode (k pool depth)	; floats: k's number and its parameters, prefix order
  (hash-at-put twin-ran (car k) 1)
  (let ((out (list (long->double (twin-number-of k)))))
    (list-do kind (twin-kinds k)
      (set out (concat-list out
			    (if (= kind "float") (list (twin-next pool))
			      (let* ((ks (twin-of-kind kind))
				     (sub (if (< depth 3) (twin-nth ks (twin-index (twin-next pool) (list-length ks)))
					    (list-detect s ks (not (twin-kinds s))))))	; deep enough: one with no parameters of its own
				(twin-encode (or sub (car ks)) pool (+ depth 1)))))))
    out))

(define-function twin-floats (values)	; a C buffer of 32-bit floats
  (let ((d (data (* 4 (max 1 (list-length values))))) (i 0))
    (list-do v values (set-float-at d i (* 1.0 v)) (set i (+ i 1)))
    d))
(define-function twin-run-segment (build kernels params xs workers)	; the output floats, or 'failed
  (let* ((capacity (+ 4096 (* 8 (list-length xs))))
	 (out (data (* 4 capacity)))
	 (n ((cadr build) (twin-runtime build workers) (twin-floats params) (list-length kernels) (twin-floats xs) (list-length xs) out capacity)))
    (if (< n 0)
	(let () (twin-drop-runtime build workers) 'failed)
      (let ((floats ())) (for (i 0 n) (push floats (float-at out i))) (list-reverse! floats)))))
(define-function twin-whole (xs w)	; xs cut to whole elements of w floats
  (let ((n (* w (/ (list-length xs) w))) (out ())) (for (i 0 n) (push out (car xs)) (set xs (cdr xs))) (list-reverse! out)))
(define-function twin-zip (as aw pool bw)	; each element of as (aw floats) followed by bw floats from the pool
  (let ((out ()))
    (while as
      (for (i 0 aw) (push out (car as)) (set as (cdr as)))
      (for (i 0 bw) (push out (twin-next pool))))
    (list-reverse! out)))
(define-function twin-last (l) (while (cdr l) (set l (cdr l))) (car l))
;; a chain as segments: (kernels . params) each, a new one where a kernel reads a tuple its predecessor's stream heads
(define-function twin-segments (chain pool)
  (let ((segs ()) (cur ()) (params ()) (prev ()))
    (list-do name chain
      (let ((k (twin-kernel name)))
	(and prev (!= (twin-out prev) (twin-in k))
	     (let () (push segs (cons (list-reverse! cur) params)) (set cur ()) (set params ())))
	(push cur k) (set params (concat-list params (twin-encode k pool 0)))
	(set prev k)))
    (push segs (cons (list-reverse! cur) params))
    (list-reverse! segs)))
(define-function twin-run-chain (build segs xs workers zips)	; the final output, or 'failed; zips: each boundary's B floats
  (let ((data xs) (failed ()) (prev ()))
    (list-do seg segs
      (or failed
	  (let ((first (car (car seg))))
	    (and prev (set data (twin-zip data (twin-out-floats prev) (car zips) (- (twin-in-floats first) (twin-out-floats prev)))))
	    (and prev (set zips (cdr zips)))
	    (let ((r (twin-run-segment build (car seg) (cdr seg) data workers)))
	      (if (= r 'failed) (set failed 1) (set data r)))
	    (set prev (twin-last (car seg))))))
    (if failed 'failed data)))

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
  (cond ((or (= c 'stuck) (= c 'failed))	; the C build stopped: outside Gezira's domain, nothing to hold the native to
	 (set twin-skipped (+ twin-skipped 1))
	 (if (or (= n 'stuck) (= n 'failed)) 0
	   (let () (twin-say "  twin " chain ": C " c ", the native build ran") 0)))	; the native may finish what C can't
	((= n 'stuck)	(twin-say "  twin " chain ": the native build ran past its time, C finished") 1)
	((= n 'failed)	(twin-say "  twin " chain ": the native build failed, C ran") 1)
	((!= (list-length c) (list-length n))
	 (twin-say "  twin " chain ": " (list-length c) " floats from C, " (list-length n) " natively") 1)
	(else
	 (let ((i 0) (bad ()))
	   (while (and c (not bad))
	     (or (twin-near (car c) (car n)) (set bad (list i (car c) (car n))))
	     (set c (cdr c)) (set n (cdr n)) (set i (+ i 1)))
	   (if bad (let () (twin-say "  twin " chain ": float " (car bad) " is " (cadr bad) " from C, " (caddr bad) " natively") 1) 0)))))

;; each build runs a case in a child of its own (the law engine's law-child), under a CPU limit: a kernel can loop on
;; inputs outside its domain (a subdivision handed a NaN never converges), in either build, and only a process limit
;; stops it.  The child starts its own runtimes (worker threads don't survive a fork) and writes the output's float bits
;; to NILE_TWIN_TMP's file; the parent reads them back.  A run is its floats, failed (past capacity, or the runtime
;; failed) or stuck (past its time).
(define twin-limit 3)	; CPU seconds a build may take for one case
(define twin-file (concat-string (twin-env "NILE_TWIN_TMP") "/twin-case"))
(define twin-bits-buffer (data 4))
(define-function twin-bits (x) (set-float-at twin-bits-buffer 0 x) (int32-at twin-bits-buffer 0))
(define-function twin-of-bits (b) (set-int32-at twin-bits-buffer 0 b) (float-at twin-bits-buffer 0))
(define-function twin-ran? (r) (or (pair? r) (= r ())))
(define-function twin-copy-pool (p) (cons (cdr p) (cdr p)))
;; a case: the chain's segments and each boundary's second stream made once from ps, then run on both builds
(define-function twin-pool-take (pool n) (let ((out ())) (for (i 0 n) (push out (twin-next pool))) (list-reverse! out)))
(define-function twin-isolated (build segs xs workers zips)
  (let ((st (law-child (lambda ()
			 (law-limit twin-limit)
			 (set twin-runtimes ())
			 (let ((r (twin-run-chain build segs xs workers (map twin-copy-pool zips))) (parts (list "ran")))
			   (if (= r 'failed) (set parts (list "failed"))
			     (list-do x r (push parts " ") (push parts (long->string (twin-bits x)))))
			   (contents-to-file-named (apply concat-strings (list-reverse! parts)) twin-file)
			   (_exit 0))))))
    (if (!= 0 st) 'stuck
      (let ((ws (words (contents-of-file-named twin-file))))
	(if (= "failed" (car ws)) 'failed (map (lambda (w) (twin-of-bits (string->long w))) (cdr ws)))))))
(define-function twin-case (chain ps xs workers move)
  (let* ((pool (twin-pool ps))
	 (segs (twin-segments chain pool))
	 (xs (twin-whole xs (twin-in-floats (twin-kernel (car chain)))))
	 (zips ()))
    (list-do s (cdr segs) (push zips (twin-pool (twin-pool-take pool 64))))
    (set zips (list-reverse! zips))
    (let* ((c (twin-isolated twin-c segs xs workers zips))
	   (n (twin-isolated twin-native segs xs workers zips))
	   (r (twin-compare chain c (if (and move (pair? n)) (move n) n))))
      (and (twin-ran? c) (twin-ran? n) (set twin-compared (+ twin-compared 1)))
      r)))

(define-function twin (chain ps xs workers) (twin-case chain ps xs workers ()))
;; a long stream: the runtime's buffer holds 122 floats (nile-kernel.k's nile_Buffer_capacity: a 512-byte block less its
;; nile_Buffer), so w-float elements fill one every 122/w; the drawn elements, repeated, to k buffers' worth and d more
(define twin-buffer-floats 122)
(define-function twin-stream (chain xs k d)
  (let* ((w (twin-in-floats (twin-kernel (car chain)))) (xs (twin-whole xs w)) (n (max 0 (+ (* k (/ twin-buffer-floats w)) d)))
	 (out ()) (v xs))
    (and xs (for (i 0 (* n w)) (or v (set v xs)) (push out (car v)) (set v (cdr v))))
    (list-reverse! out)))
(define-function twin_long (chain ps xs k d workers) (twin-case chain ps (twin-stream chain xs k d) workers ()))

;; the twin's own checks.  twin_distinct: the two builds are two (their entry points differ), so a twin that loaded one
;; build twice fails.  twin_perturbed: the native output's first float moved past the band (by 1 or a thousandth of
;; it, or an infinity made 0), so a comparison that never read the floats fails.
(define-function twin_distinct (workers)
  (if (!= (twin-c-entry "gezira_twin_run") (twin-native-entry "gezira_twin_run"))	; no runtime in this process: children make theirs
      1 0))
(define-function twin-moved (outs)
  (and outs
       (cons (let ((x (car outs)))
	       (cond ((or (!= x x) (> (twin-magnitude x) 1e38)) 0.0)
		     (else (+ x (max 1.0 (* 1e-3 (twin-magnitude x)))))))
	     (cdr outs))))
(define-function twin_perturbed (chain ps xs workers)
  (set twin-quiet 1)
  (let ((r (twin-case chain ps xs workers twin-moved))) (set twin-quiet ()) r))

;; every kernel twinned in every run: each one no chain has reached, alone, on values from the engine's own float
;; generator (seeded by the law's seed, so a run replays); the disagreements, and the run's tally printed
(define-function twin_every_kernel (workers)
  (let ((bad 0))
    (list-do k twin-kernel-table
      (or (hash-includes? twin-ran (car k))
	  (let ((ps ()) (xs ()))
	    (for (i 0 16) (push ps (rules-float-draw)))
	    (for (i 0 (* 4 (twin-in-floats k))) (push xs (rules-float-draw)))
	    (set bad (+ bad (twin-case (list (car k)) ps xs workers ()))))))
    (println "  twin: " twin-compared " cases compared, " twin-skipped " outside Gezira's domain")
    bad))

;; Gezira's algebra (check/laws/gezira-algebra.law): kernels held to mathematics on both builds, so a fault both share
;; shows, which the twin can't see.  A kernel run alone on xs: its output on a build, or failed or stuck.
(define-function twin-alone (build name xs workers)
  (let ((pool (twin-pool ())))
    (twin-isolated build (twin-segments (list name) pool) xs workers ())))
(define-function twin-whole? (r)	; a float32 with no fraction: every one of magnitude 2^23 or more is one
  (or (>= (twin-magnitude r) 8388608.0) (= r (long->double (double->long r)))))
(define-function twin-floor-right? (x r up)	; r is x's floor (or, with up, its ceiling)
  (cond ((!= x x)		(!= r r))
	((not (twin-finite? x))	(= r x))
	((>= (twin-magnitude x) 8388608.0) (= r x))	; whole already (2^23 and up): its own floor, where double's x + 1 is x
	(else (and (twin-finite? r) (twin-whole? r)	; below 2^23 the inequalities are exact in doubles
		   (if up (and (>= r x) (< (- r 1.0) x)) (and (<= r x) (> (+ r 1.0) x)))))))
(define-function twin-rounds (name x up workers)	; 1 when both builds give x's floor (or ceiling)
  (let ((ok 1))
    (list-do build (list twin-c twin-native)
      (let ((out (twin-alone build name (list x) workers)))
	(or (and (pair? out) (twin-floor-right? x (car out) up))
	    (let () (set ok 0) (println "  " name " of " x " is " out (if (= build twin-c) " from C" " natively"))))))
    ok))
(define-function floor_right (x workers) (twin-rounds "gezira_Floors" x () workers))
(define-function ceiling_right (x workers) (twin-rounds "gezira_Ceilings" x 1 workers))
