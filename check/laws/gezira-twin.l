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

;; what has been compared: a kernel a case with input ran on both builds reached (the chain's first, and every one it
;; built when the output wasn't empty), so a kernel no case gave anything to is still owed a comparison
(define twin-ran (equal-hash-table))
(define *twin-built* ())	; the kernels a case built, nested ones too
(define twin-compared 0)	; cases whose outputs were compared
(define twin-skipped 0)	; cases outside Gezira's domain: the C build stopped (past capacity, failed, or past its time)

;; parameters: a kernel's number then its parameters, floats from the pool, a process parameter a kernel of its kind
(define-function twin-pool (ps) (cons ps ps))	; (remaining . all): drawn floats, reused in turn
(define-function twin-next (pool) (or (car pool) (set-car pool (or (cdr pool) '(1.0)))) (let ((v (car (car pool)))) (set-car pool (cdr (car pool))) v))
(define-function twin-index (x n)	; a drawn float as an index below n
  (if (or (!= x x) (> (if (< x 0) (- 0.0 x) x) 1e9)) 0 (% (double->long (if (< x 0) (- 0.0 x) x)) n)))
(define-function twin-nth (l n) (while (< 0 n) (set l (cdr l)) (set n (- n 1))) (car l))
(define-function twin-encode (k pool depth)	; floats: k's number and its parameters, prefix order
  (push *twin-built* (car k))
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
(define-function twin-fill (xs w least)	; xs over again to whole elements of w floats, at least least of them: never empty
  (let* ((n (max least (/ (+ (list-length xs) (- w 1)) w))) (out ()) (v xs))
    (and xs (for (i 0 (* n w)) (or v (set v xs)) (push out (car v)) (set v (cdr v))))
    (list-reverse! out)))
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
(define twin-limit 1)	; CPU seconds a build may take for one case (one takes milliseconds; a looping one costs the whole limit)
(define twin-file (concat-string (twin-env "NILE_TWIN_TMP") "/twin-case"))
(define twin-bits-buffer (data 4))
(define-function twin-bits (x) (set-float-at twin-bits-buffer 0 (* 1.0 x)) (int32-at twin-bits-buffer 0))	; a shrunk float may be a whole long
(define-function twin-of-bits (b) (set-int32-at twin-bits-buffer 0 b) (float-at twin-bits-buffer 0))
(define-function twin-ran? (r) (or (pair? r) (= r ())))
(define-function twin-copy-pool (p) (cons (cdr p) (cdr p)))
;; a case: the chain's segments and each boundary's second stream made once from ps, then run on both builds
(define-function twin-pool-take (pool n) (let ((out ())) (for (i 0 n) (push out (twin-next pool))) (list-reverse! out)))
(define-function twin-isolated-within (build segs xs workers zips limit)
  (let ((st (law-child (lambda ()
			 (law-limit limit)
			 (set twin-runtimes ())
			 (let ((r (twin-run-chain build segs xs workers (map twin-copy-pool zips))) (parts (list "ran")))
			   (if (= r 'failed) (set parts (list "failed"))
			     (list-do x r (push parts " ") (push parts (long->string (twin-bits x)))))
			   (contents-to-file-named (apply concat-strings (list-reverse! parts)) twin-file)
			   (_exit 0))))))
    (if (!= 0 st) 'stuck
      (let ((ws (words (contents-of-file-named twin-file))))
	(if (= "failed" (car ws)) 'failed (map (lambda (w) (twin-of-bits (string->long w))) (cdr ws)))))))
(define-function twin-isolated (build segs xs workers zips)	; under twin-limit CPU seconds (every thread's)
  (twin-isolated-within build segs xs workers zips twin-limit))
(define-function twin-case (chain ps xs workers move)
  (set *twin-built* ())
  (let* ((pool (twin-pool ps))
	 (segs (twin-segments chain pool))
	 (built *twin-built*)
	 (xs (twin-fill xs (twin-in-floats (twin-kernel (car chain))) 1))	; at least one whole element: never empty
	 (zips ()))
    (list-do s (cdr segs) (push zips (twin-pool (twin-pool-take pool 64))))
    (set zips (list-reverse! zips))
    (let* ((c (twin-isolated twin-c segs xs workers zips))
	   (n (if (twin-ran? c) (twin-isolated twin-native segs xs workers zips) c))	; outside the domain: nothing to compare
	   (n (if (and (twin-ran? c) (= n (quote stuck)))	; a limit counts every thread, and waiting workers burn CPU on a busy
		  (twin-isolated-within twin-native segs xs workers zips (* 8 twin-limit))	; machine: a native run past its time
		n))	; is a hang only if it doesn't finish in eight times that
	   (r (twin-compare chain c (if (and move (pair? n)) (move n) n))))
      (and xs (twin-ran? c) (twin-ran? n)	; compared, on input: the first kernel, and all it built if output came
	   (let ()
	     (set twin-compared (+ twin-compared 1))
	     (hash-at-put twin-ran (car chain) 1)
	     (and (pair? c) (list-do k built (hash-at-put twin-ran k 1)))))
      r)))

(define-function twin (chain ps xs workers) (twin-case chain ps xs workers ()))
;; a long stream: the runtime's buffer holds 122 floats (nile-kernel.k's nile_Buffer_capacity: a 512-byte block less its
;; nile_Buffer), so w-float elements fill one every 122/w; the drawn elements, repeated, to k buffers' worth and d more
(define twin-buffer-floats 122)
(define-function twin-stream (chain xs k d)
  (let* ((w (twin-in-floats (twin-kernel (car chain)))) (xs (twin-fill xs w 1)) (n (max 1 (+ (* k (/ twin-buffer-floats w)) d)))
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

;; values from drawn floats: a unit value (its fraction, an infinity or NaN 1), a moderate one (itself up to 1e4, larger
;; ones scaled into it, so tiny and subnormal values stay), a premultiplied colour (r g b alpha, the channels within it)
(define-function twin-fraction (a) (if (< a 1e15) (- a (long->double (double->long a))) 0.0))
(define-function twin-unit (x) (if (twin-finite? x) (twin-fraction (twin-magnitude x)) 1.0))
(define-function twin-f32 (x) (twin-of-bits (twin-bits x)))	; x rounded to float32, as a kernel reads it
(define-function twin-moderate-of (x)
  (cond ((not (twin-finite? x)) (if (= x x) (if (< x 0) -1e4 1e4) 0.0))
	((<= (twin-magnitude x) 1e4) x)
	(else (* (if (< x 0) -1e4 1e4) (twin-unit x)))))
(define-function twin-moderate (x) (twin-f32 (twin-moderate-of x)))

;; every kernel compared in every run: each one no case has compared yet is twinned alone on values from the engine's
;; own float generator (seeded by the law's seed, so a run replays), up to 25 cases, every other one with its values
;; made moderate (many kernels stop on the format's extremes), until one is compared; a kernel none compares fails,
;; named.  The disagreements and the uncompared count, and the run's tally is printed.
(define-function twin_every_kernel (workers)
  (let ((bad 0))
    (list-do k twin-kernel-table
      (let ((tries 0))
	(while (and (not (hash-includes? twin-ran (car k))) (< tries 25))
	  (let ((ps ()) (xs ()))
	    (for (i 0 16) (push ps (rules-float-draw)))
	    (for (i 0 (* 4 (twin-in-floats k))) (push xs (rules-float-draw)))
	    (and (= 1 (% tries 2)) (let () (set ps (map twin-moderate ps)) (set xs (map twin-moderate xs))))
	    (set bad (+ bad (twin-case (list (car k)) ps xs workers ())))
	    (set tries (+ tries 1))))
	(or (hash-includes? twin-ran (car k)) (let () (set bad (+ bad 1)) (println "  twin: no case compared " (car k))))))
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

;; ---------------------------------------------------------------- Gezira's algebra (check/laws/gezira-algebra.law)
;; several chains run by one build in one child: jobs (names ps xs), each its output, failed or stuck
(define-function twin-batch (build jobs workers)
  (let ((st (law-child (lambda ()
			 (law-limit (* twin-limit 2))
			 (set twin-runtimes ())
			 (let ((parts ()))
			   (list-do j jobs
			     (let ((r (twin-run-chain build (twin-segments (car j) (twin-pool (cadr j))) (caddr j) workers ())))
			       (if (= r 'failed) (push parts "failed") (let () (push parts "ran") (list-do x r (push parts " ") (push parts (long->string (twin-bits x))))))
			       (push parts "\n")))
			   (contents-to-file-named (apply concat-strings (list-reverse! parts)) twin-file)
			   (_exit 0))))))
    (if (!= 0 st) (map (lambda (j) 'stuck) jobs)
      (map (lambda (l) (let ((ws (words l))) (if (= "failed" (car ws)) 'failed (map (lambda (w) (twin-of-bits (string->long w))) (cdr ws)))))
	   (lines (contents-of-file-named twin-file))))))
(define twin-outside 0)	; cases outside a law's property: overflow, a near-singular matrix, a build that stopped
(define twin-law-tally (equal-hash-table))	; a law's name (the engine's *lname*) to its (cases outside)
(define-function twin-tally (outside)
  (let ((t (or (hash-at twin-law-tally *lname*) (list 0 0)))) (hash-at-put twin-law-tally *lname* (list (+ 1 (car t)) (+ outside (cadr t))))))
(define-function twin-out-of-law () (set twin-outside (+ twin-outside 1)) (twin-tally 1) 1)
(define-function twin-colour (c)
  (let ((alpha (twin-f32 (twin-unit (cadddr c)))))
    (map twin-f32 (list (* alpha (twin-unit (car c))) (* alpha (twin-unit (cadr c))) (* alpha (twin-unit (caddr c))) alpha))))

;; affine maps (a b c d e f): x' = a x + c y + e, y' = b x + d y + f
(define-function twin-at (l i) (twin-nth l i))
(define-function twin-apply (m x y)	; (x' y' sx sy), sx and sy the magnitudes of each output's terms
  (let ((a (twin-at m 0)) (b (twin-at m 1)) (c (twin-at m 2)) (d (twin-at m 3)) (e (twin-at m 4)) (f (twin-at m 5)))
    (list (+ (+ (* a x) (* c y)) e) (+ (+ (* b x) (* d y)) f)
	  (+ (+ (twin-magnitude (* a x)) (twin-magnitude (* c y))) (twin-magnitude e))
	  (+ (+ (twin-magnitude (* b x)) (twin-magnitude (* d y))) (twin-magnitude f)))))
(define-function twin-then (m n)	; the map m then n
  (let ((ma (twin-at m 0)) (mb (twin-at m 1)) (mc (twin-at m 2)) (md (twin-at m 3)) (me (twin-at m 4)) (mf (twin-at m 5))
	(na (twin-at n 0)) (nb (twin-at n 1)) (nc (twin-at n 2)) (nd (twin-at n 3)) (ne (twin-at n 4)) (nf (twin-at n 5)))
    (list (+ (* na ma) (* nc mb)) (+ (* nb ma) (* nd mb)) (+ (* na mc) (* nc md)) (+ (* nb mc) (* nd md))
	  (+ (+ (* na me) (* nc mf)) ne) (+ (+ (* nb me) (* nd mf)) nf))))
(define-function twin-inverse (m)	; m's inverse, or () when it is too near singular for float32 (an entry past 1e20 overflows a run)
  (let* ((a (twin-at m 0)) (b (twin-at m 1)) (c (twin-at m 2)) (d (twin-at m 3)) (e (twin-at m 4)) (f (twin-at m 5))
	 (det (- (* a d) (* b c))) (size (* (+ (twin-magnitude a) (twin-magnitude b)) (+ (twin-magnitude c) (twin-magnitude d)))))
    (and (< 0 size) (> (twin-magnitude det) (* 1e-3 size))
	 (let ((inv (list (/ d det) (/ (- 0.0 b) det) (/ (- 0.0 c) det) (/ a det) (/ (- (* c f) (* d e)) det) (/ (- (* b e) (* a f)) det))))
	   (and (not (list-detect v inv (not (< (twin-magnitude v) 1e20)))) inv)))))
(define-function twin-band (scale) (+ 1e-6 (* 1e-5 scale)))
(define-function twin-within (x y scale) (and (twin-finite? x) (twin-finite? y) (<= (twin-magnitude (- x y)) (twin-band scale))))
(define-function twin-same-floats (a b)	; exactly equal, element by element (NaN equal to NaN)
  (and (= (list-length a) (list-length b))
       (let ((ok 1)) (while (and ok a) (or (= (car a) (car b)) (and (!= (car a) (car a)) (!= (car b) (car b))) (set ok ())) (set a (cdr a)) (set b (cdr b))) ok)))
(define-function twin-moderates (xs) (map twin-moderate xs))
(define-function twin-both (check jobs workers)	; 1 when check holds of each build's outputs for jobs; outside when one stopped
  (let ((ok 1) (outside ()))
    (list-do build (list twin-c twin-native)
      (let ((rs (twin-batch build jobs workers)))
	(if (list-detect r rs (not (twin-ran? r))) (set outside 1)
	  (or (check rs) (let () (set ok 0) (println "  algebra: " (if (= build twin-c) "C" "native") " fails for " jobs " giving " rs))))))
    (if (and outside (= ok 1)) (twin-out-of-law) (let () (twin-tally 0) ok))))

;; the transform laws over points (w = 2) or Béziers (w = 6, three points each)
(define-function twin-points-of (xs w) (twin-fill (twin-moderates xs) w 1))	; never empty: one whole element at least
(define-function twin-map-near (m outs xs scale-of)	; each output point near m's image of its input point
  (let ((ok 1))
    (while (and ok xs (cdr xs))
      (let ((p (twin-apply m (car xs) (cadr xs))) (s (scale-of (car xs) (cadr xs))))
	(or (and (twin-within (car outs) (car p) s) (twin-within (cadr outs) (cadr p) s)) (set ok ())))
      (set xs (cddr xs)) (set outs (cddr outs)))
    ok))
(define-function twin-through (m n)	; the error scale of m then n at a point: n's largest entry times m's terms, and n's terms
  (let ((k (+ 1.0 (apply max (map twin-magnitude n)))))	; at m's image (an entry of n·m can cancel; these terms can't)
    (lambda (x y)
      (let* ((q (twin-apply m x y)) (r (twin-apply n (car q) (cadr q))))
	(+ (* k (+ (caddr q) (cadddr q))) (+ (caddr r) (cadddr r)))))))
(define-function twin-compose-law (kernel w m n xs workers)
  (let* ((m (twin-moderates m)) (n (twin-moderates n)) (xs (twin-points-of xs w)) (nm (twin-then m n)) (scale (twin-through m n)))
    (twin-both (lambda (rs)	; m then n, and their composite, each near the exact image
		 (and (twin-map-near nm (car rs) xs scale) (twin-map-near nm (cadr rs) xs scale)))
	       (list (list (list kernel kernel) (concat-list m n) xs) (list (list kernel) nm xs)) workers)))
(define-function twin-identity-law (kernel w xs workers)
  (let ((xs (twin-points-of xs w)))
    (twin-both (lambda (rs) (twin-same-floats (car rs) xs)) (list (list (list kernel) '(1.0 0.0 0.0 1.0 0.0 0.0) xs)) workers)))
(define-function twin-invertible (m)	; an invertible map from six drawn floats: a rotation (a rational one, from the first)
  (let* ((t (- (* 2.0 (twin-unit (twin-at m 0))) 1.0)) (co (/ (- 1.0 (* t t)) (+ 1.0 (* t t)))) (si (/ (* 2.0 t) (+ 1.0 (* t t))))	; after
	 (sx (rules-pow2 (- (twin-index (twin-at m 1) 33) 16))) (sy (rules-pow2 (- (twin-index (twin-at m 2) 33) 16)))	; scales 2^-16 to 2^16
	 (h (twin-unit (twin-at m 3))))	; after a shear, then moved by the last two made moderate
    (map twin-f32 (list (* co sx) (* si sx) (- (* (* co sx) h) (* si sy)) (+ (* (* si sx) h) (* co sy)) (twin-moderate (twin-at m 4)) (twin-moderate (twin-at m 5))))))
(define-function twin-inverse-law (kernel w m xs workers)
  (let* ((m (twin-invertible m)) (inv (twin-inverse m)) (xs (twin-points-of xs w)))
    (if (not inv) (twin-out-of-law)
      (twin-both (lambda (rs) (twin-map-near '(1.0 0.0 0.0 1.0 0.0 0.0) (car rs) xs (twin-through m inv)))	; m then its inverse
		 (list (list (list kernel kernel) (concat-list m inv) xs)) workers))))
(define-function transform_compose (m n xs workers) (twin-compose-law "gezira_TransformPoints" 2 m n xs workers))
(define-function transform_identity (xs workers) (twin-identity-law "gezira_TransformPoints" 2 xs workers))
(define-function transform_inverse (m xs workers) (twin-inverse-law "gezira_TransformPoints" 2 m xs workers))
(define-function beziers_compose (m n xs workers) (twin-compose-law "gezira_TransformBeziers" 6 m n xs workers))
(define-function beziers_identity (xs workers) (twin-identity-law "gezira_TransformBeziers" 6 xs workers))
(define-function beziers_inverse (m xs workers) (twin-inverse-law "gezira_TransformBeziers" 6 m xs workers))

;; compositing, premultiplied colours: a compositor run on one pair (a, b)
(define-function twin-near-floats (a b)	; within the band of values at most 1
  (and (= (list-length a) (list-length b))
       (let ((ok 1)) (while (and ok a) (or (twin-within (car a) (car b) 1.0) (set ok ())) (set a (cdr a)) (set b (cdr b))) ok)))
(define-function twin-pair-job (k a b) (list (list k) () (concat-list a b)))
(define-function over_associative (a b c workers)
  (let ((a (twin-colour a)) (b (twin-colour b)) (c (twin-colour c)) (o "gezira_CompositeOver") (ok 1) (outside ()))
    (list-do build (list twin-c twin-native)
      (let ((s1 (twin-batch build (list (twin-pair-job o a b) (twin-pair-job o b c)) workers)))
	(if (list-detect r s1 (not (pair? r))) (set outside 1)
	  (let ((s2 (twin-batch build (list (twin-pair-job o (car s1) c) (twin-pair-job o a (cadr s1))) workers)))
	    (cond ((list-detect r s2 (not (pair? r))) (set outside 1))
		  ((not (twin-near-floats (car s2) (cadr s2)))
		   (set ok 0) (println "  algebra: (a over b) over c is " (car s2) ", a over (b over c) " (cadr s2) (if (= build twin-c) " from C" " natively"))))))))
    (if (and outside (= ok 1)) (twin-out-of-law) (let () (twin-tally 0) ok))))
(define-function over_identity (a workers)
  (let ((a (twin-colour a)) (t '(0.0 0.0 0.0 0.0)) (o "gezira_CompositeOver"))
    (twin-both (lambda (rs) (and (twin-same-floats (car rs) a) (twin-same-floats (cadr rs) a)))
	       (list (twin-pair-job o t a) (twin-pair-job o a t)) workers)))
(define-function clear_absorbs (a b workers)
  (twin-both (lambda (rs) (twin-same-floats (car rs) '(0.0 0.0 0.0 0.0)))
	     (list (twin-pair-job "gezira_CompositeClear" (twin-colour a) (twin-colour b))) workers))
(define-function src_dst_project (a b workers)
  (let ((a (twin-colour a)) (b (twin-colour b)))
    (twin-both (lambda (rs) (and (twin-same-floats (car rs) a) (twin-same-floats (cadr rs) b)))
	       (list (twin-pair-job "gezira_CompositeSrc" a b) (twin-pair-job "gezira_CompositeDst" a b)) workers)))
(define-function separable_commutes (k a b workers)
  (let ((a (twin-colour a)) (b (twin-colour b)))
    (twin-both (lambda (rs) (twin-near-floats (car rs) (cadr rs))) (list (twin-pair-job k a b) (twin-pair-job k b a)) workers)))

;; paths
(define-function reverse_involution (xs workers)	; any floats: reversing moves them, it computes nothing
  (let ((xs (twin-fill xs 6 1)) (r "gezira_ReverseBeziers"))
    (twin-both (lambda (rs) (twin-same-floats (car rs) xs)) (list (list (list r r) () xs)) workers)))
(define-function twin-polygon (xs dx dy)	; a closed path of straight Béziers through the points xs makes on a 64-pixel
  (let ((pts ()) (out ()))			; canvas (8 in from its edges), moved by (dx, dy)
    (while (and xs (cdr xs)) (push pts (list (+ (+ 8.0 dx) (* 48.0 (twin-unit (car xs)))) (+ (+ 8.0 dy) (* 48.0 (twin-unit (cadr xs)))))) (set xs (cddr xs)))
    (set pts (list-reverse! pts))
    (let ((p pts))
      (while p
	(let ((a (car p)) (b (if (cdr p) (cadr p) (car pts))))
	  (set out (concat-list out (list (car a) (cadr a) (car a) (cadr a) (car b) (cadr b)))))
	(set p (cdr p))))
    out))
(define-function twin-moved-spans (spans dx dy)	; (x y coverage length) spans with x and y moved
  (let ((out ()))
    (while spans (push out (+ (car spans) dx)) (push out (+ (cadr spans) dy)) (push out (caddr spans)) (push out (cadddr spans)) (set spans (cddddr spans)))
    (list-reverse! out)))
;; coverage moves with its shape, pixel by pixel within the band of its coordinates' magnitudes: moving by whole pixels
;; changes how a coordinate's fraction rounds in float32 (its binade can change), so spans may also split differently
(define-function twin-pixels (spans dx dy)	; (x y c l) spans as a table from (x y) to coverage, moved back by (dx, dy)
  (let ((t (equal-hash-table)))
    (while spans
      (let ((x (- (car spans) dx)) (y (- (cadr spans) dy)) (c (caddr spans)) (l (cadddr spans)))
	(for (i 0 (if (twin-finite? l) (min 4096 (double->long l)) 0)) (hash-at-put t (list (+ x (long->double i)) y) c)))
      (set spans (cddddr spans)))
    t))
(define-function twin-coverage-moved? (a b dx dy scale)
  (let ((pa (twin-pixels a 0.0 0.0)) (pb (twin-pixels b dx dy)) (ok 1))
    (hash-do pa (lambda (k c) (or (twin-within c (or (hash-at pb k) 0.0) scale) (set ok ()))))
    (hash-do pb (lambda (k c) (or (twin-within c (or (hash-at pa k) 0.0) scale) (set ok ()))))
    ok))
(define-function coverage_translates (xs dx dy workers)
  (let ((dx (long->double (if (long? dx) dx (double->long dx)))) (dy (long->double (if (long? dy) dy (double->long dy)))))
    (let ((xs (twin-fill xs 6 1)))	; three points at least: a polygon
      (twin-both (lambda (rs) (twin-coverage-moved? (car rs) (cadr rs) dx dy (+ 64.0 (+ (twin-magnitude dx) (twin-magnitude dy)))))
		 (list (list (list "gezira_Rasterize") () (twin-polygon xs 0.0 0.0)) (list (list "gezira_Rasterize") () (twin-polygon xs dx dy)))
		 workers))))
(define-function gradient_affine (g xs workers)	; t = ((p - A).(B - A)) / |B - A|^2, so t of a midpoint is the mean
  (let* ((g (twin-moderates g)) (ax (car g)) (ay (cadr g)) (vx (- (caddr g) ax)) (vy (- (cadddr g) ay)) (len2 (+ (* vx vx) (* vy vy)))
	 (ps (twin-fill (twin-moderates xs) 4 1)))	; two points at least
    (cond
	  ((<= len2 (* 1e-6 (+ (* ax ax) (+ (* ay ay) 1.0)))) (twin-out-of-law))	; A and B too near for float32
	  (else
	   (let* ((px (car ps)) (py (cadr ps)) (qx (caddr ps)) (qy (cadddr ps)) (mx (/ (+ px qx) 2.0)) (my (/ (+ py qy) 2.0))
		  (scale (/ (* (+ (+ (twin-magnitude (- px ax)) (twin-magnitude (- py ay))) (+ (twin-magnitude (- qx ax)) (twin-magnitude (- qy ay))))
			       (+ (twin-magnitude vx) (twin-magnitude vy)))
			    len2)))
	     (twin-both (lambda (rs) (let ((t (car rs))) (twin-within (caddr t) (/ (+ (car t) (cadr t)) 2.0) scale)))
			(list (list (list "gezira_ProjectLinearGradient") (list ax ay (caddr g) (cadddr g)) (list px py qx qy mx my))) workers))))))

;; the algebra's own check: M then N against the wrong composite (N then M, i.e. M·N), wherever the two differ past the
;; band in exact arithmetic, must be told apart
(define-function algebra_detects (m n xs workers)
  (let* ((m (twin-moderates m)) (n (twin-moderates n)) (xs (twin-points-of xs 2)) (wrong (twin-then n m)) (right (twin-then m n)))
    (if (not xs) 1
      (let ((differ ()) (p xs))
	(while (and p (cdr p))
	  (let ((r (twin-apply right (car p) (cadr p))) (v (twin-apply wrong (car p) (cadr p))))
	    (or (and (twin-within (car r) (car v) (* 4.0 (+ (+ (caddr r) (cadddr r)) (+ (caddr v) (cadddr v)))))
		     (twin-within (cadr r) (cadr v) (* 4.0 (+ (+ (caddr r) (cadddr r)) (+ (caddr v) (cadddr v))))))
		(set differ 1)))
	  (set p (cddr p)))
	(if (not differ) 1
	  (let ((rs (twin-batch twin-native (list (list (list "gezira_TransformPoints" "gezira_TransformPoints") (concat-list m n) xs)) workers)))
	    (cond ((not (pair? (car rs))) (twin-out-of-law))
		  ((twin-map-near wrong (car rs) xs (lambda (x y) (let ((p (twin-apply wrong x y))) (+ (caddr p) (cadddr p))))) 0)	; seen as the wrong order: blind
		  (else 1))))))))

;; every algebra law held somewhere: each one's cases outside its property printed, and a law with none inside fails
;; (were the native build to stop on everything, every law would count its cases outside and hold)
(define twin-tally-shown ())	; the engine may run the law more than once: print once
(define-function algebra_inside (workers)
  (let ((ok 1))
    (hash-do twin-law-tally
	     (lambda (name t)
	       (and (< 0 (cadr t)) (not twin-tally-shown) (println "  algebra: " name ", " (cadr t) " of " (car t) " cases outside its property"))
	       (and (= (car t) (cadr t)) (let () (set ok 0) (println "  algebra: " name " held no case inside its property")))))
    (set twin-tally-shown 1)
    ok))
