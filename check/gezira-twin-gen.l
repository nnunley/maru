;;; check/gezira-twin-gen.l -- the twin laws' kernel table, made from Gezira itself by make: each kernel's constructor in
;;; build/gezira.k (its float and process parameters, and the floats an element takes in and gives out, from its
;;; nile_Process call) and its declaration in gezira.nl (its stream types, and what kind of process each process
;;; parameter is).  It writes, to standard output, typed Maru for check/gezira-twin.k: gezira_twin_build, which reads a kernel number
;;; and its parameters from a float stream and makes the process, a process parameter read the same way, nested (mode k);
;;; and the table for check/laws/gezira-twin.l: (name number in-type out-type parameter-kinds in-floats out-floats) (l).
;;;   ./eval check/gezira-twin-gen.l build/gezira.k gezira/nile/gezira.nl k|l > OUT
(define gezira-k (pop *arguments*))
(define gezira-nl (pop *arguments*))
(define mode (pop *arguments*))	; k: the typed Maru; l: the table
(require "check/strings.l")

(define-function lookup (key alist) (let ((r ())) (while (and alist (not r)) (and (= key (car (car alist))) (set r (car alist))) (set alist (cdr alist))) r))
(define-function trim (s)	; s without spaces at either end
  (let ((a 0) (b (string-length s)))
    (while (and (< a b) (= 32 (string-at s a))) (set a (+ a 1)))
    (while (and (< a b) (= 32 (string-at s (- b 1)))) (set b (- b 1)))
    (string-copy s a (- b a))))
(define-function squeeze (s)	; s without spaces: a type's name, compared as written
  (let ((out ())) (for (i 0 (string-length s)) (or (= 32 (string-at s i)) (push out (string-at s i)))) (list->string (list-reverse! out))))
(define-function find (s sub from)	; the index of sub in s at or after from, or ()
  (let ((n (string-length sub)) (r ()))
    (while (and (not r) (<= (+ from n) (string-length s)))
      (if (= 0 (string-compare s sub from n)) (set r from) (set from (+ from 1))))
    r))
(define-function top-split (s)	; s split at its top-level commas
  (let ((parts ()) (depth 0) (start 0))
    (for (i 0 (string-length s))
      (let ((c (string-at s i)))
	(cond ((= c ?\() (set depth (+ depth 1)))
	      ((= c ?\)) (set depth (- depth 1)))
	      ((and (= c ?,) (= 0 depth)) (push parts (string-copy s start (- i start))) (set start (+ i 1))))))
    (push parts (string-copy s start (- (string-length s) start)))
    (list-reverse! parts)))

;; gezira.nl: type aliases (type X = A >> B) and declarations (Name (p:T, ...) : A >> B, or : Alias)
(define aliases ())	; (name . (in . out))
(define declared ())	; (name in out (param-type ...))
(define-function arrow (t)	; (in . out) of a stream type, an alias expanded, or ()
  (let ((at (find t ">>" 0)))
    (if at (cons (squeeze (string-copy t 0 at)) (squeeze (string-copy t (+ at 2) (- (- (string-length t) at) 2))))
      (cdr (lookup (squeeze t) aliases)))))
(list-do line (lines (contents-of-file-named gezira-nl))
  (cond ((= 0 (string-compare line "type " 0 5))
	 (let ((eq (find line "=" 0)))
	   (and eq (find line ">>" eq)
		(push aliases (cons (squeeze (string-copy line 5 (- eq 5))) (arrow (string-copy line (+ eq 1) (- (- (string-length line) eq) 1))))))))
	((and (< 0 (string-length line)) (<= ?A (string-at line 0)) (<= (string-at line 0) ?Z) (find line " (" 0) (find line ") : " 0))
	 (let* ((open (find line " (" 0)) (close (find line ") : " open)) (name (string-copy line 0 open))
		(params (trim (string-copy line (+ open 2) (- (- close open) 2))))
		(type (arrow (trim (string-copy line (+ close 4) (- (- (string-length line) close) 4))))))
	   (and type
		(push declared (list (concat-string "gezira_" name) (car type) (cdr type)
				     (if (= 0 (string-length params)) ()
				       (map (lambda (p) (let ((c (find p ":" 0))) (squeeze (string-copy p (+ c 1) (- (- (string-length p) c) 1)))))
					    (top-split params))))))))))

;; build/gezira.k: each constructor, (define-function gezira_X (nile_Process_t *) ((parent nile_Process_t *) …) …)
(define-function quanta (form)	; (in . out) from the body's (nile_Process parent IN OUT …), or ()
  (cond ((and (pair? form) (= 'nile_Process (car form)) (pair? (cdr form)) (= 'parent (cadr form))) (cons (caddr form) (cadddr form)))
	((pair? form) (or (quanta (car form)) (quanta (cdr form))))
	(else ())))
(define-function process-types (ts)	; the declared parameter types that are processes (an alias, or A >> B)
  (let ((out ())) (list-do t ts (and (or (lookup t aliases) (find t ">>" 0)) (push out t))) (list-reverse! out)))
(define kernels ())	; (name number in out kinds in-floats out-floats params)
(define number 0)
(list-do form (read gezira-k)
  (and (pair? form) (= 'define-function (car form)) (pair? (caddr form)) (= 'nile_Process_t (car (caddr form)))
       (let* ((name (symbol->string (cadr form))) (params (cadddr form)) (d (lookup name declared)) (q (quanta (cddddr form))))
	 (and d q (pair? params) (= 'parent (car (car params)))
	      (let ((kinds ()) (ts (process-types (cadddr d))))	; the process types, in order
		(list-do p (cdr params)	; a float stays one (a Point parameter is two); a process takes the next process type
		  (if (= 'float (cadr p)) (push kinds "float") (let () (push kinds (car ts)) (set ts (cdr ts)))))
		(push kernels (list name number (cadr d) (caddr d) (list-reverse! kinds) (car q) (cdr q)))
		(set number (+ number 1)))))))
(set kernels (list-reverse! kernels))

(define-function emit-k ()
  (println ";;; written by check/gezira-twin-gen.l from build/gezira.k and gezira.nl, by make; don't edit.")
  (println "(define-function gezira_twin_f float ((p float *) (at int *))	; the next float of the stream")
  (println "  (let (((v float) (indir p (indir at)))) (set (indir at) (+ 1 (indir at))) (return v)))")
  (println "(define-function gezira_twin_build (nile_Process_t *) ((i nile_Process_t *) (p float *) (at int *))")
  (println "  (let (((k int) (cast (gezira_twin_f p at) int)))")
  (list-do k kernels
    (let ((j 0) (binds "") (args ""))
      (list-do kind (car (cddddr k))
	(let ((v (concat-string "a" (long->string j))))
	  (set binds (concat-strings binds " ((" v (if (= kind "float") " float) (gezira_twin_f p at))" " nile_Process_t *) (gezira_twin_build i p at))")))
	  (set args (concat-strings args " " v))
	  (set j (+ j 1))))
      (println "    (if (= k " (cadr k) ") (let* (" binds ") (return (" (car k) " i" args "))))")))
  (println "    (return (cast 0 nile_Process_t *))))"))
(define-function emit-l ()
  (println ";;; written by check/gezira-twin-gen.l from build/gezira.k and gezira.nl, by make; don't edit.")
  (println ";;; (name number in-type out-type parameter-kinds in-floats out-floats)")
  (print "(define twin-kernel-table '(")
  (list-do k kernels (println) (dump k))
  (println "))"))
(if (= mode "k") (emit-k) (emit-l))
