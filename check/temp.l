;;; Where a check writes: a directory of its own, so that two checkouts running at once don't wipe or read each other's files.
;;; MARU_CHECK_TMP says where (check/parallel.l gives each case one); otherwise it's named after this checkout.  One run
;;; at a time per checkout: a second would share its directory.
;; an environment variable as a string, or ()
(define-function env-var (name)
  (let ((p ((subr "getenv" "s>p") name)))
    (and p (!= 0 p)
	 (let ((chars ()) (i 0))
	   (while (< 0 (byte-at p i)) (push chars (byte-at p i)) (set i (+ i 1)))
	   (list->string (list-reverse! chars))))))
;; only letters, digits, and - and . survive, so the name is one plain word in a path
(define-function checkout-name ()
  (let* ((buffer ((subr "malloc" "l>p") 4096))
	 (_ ((subr "getcwd" "pl>p") buffer 4096))
	 (chars ())
	 (i 0))
    (while (< 0 (byte-at buffer i))
      (let ((c (byte-at buffer i)))
	(push chars (if (or (and (<= ?a c) (<= c ?z)) (and (<= ?A c) (<= c ?Z)) (and (<= ?0 c) (<= c ?9)) (= c ?-) (= c ?.)) c ?_)))
      (set i (+ i 1)))
    (list->string (list-reverse! chars))))
;; everything here gets removed with rm -rf, so a directory someone names must be somewhere safe to remove, one word
(define-function safe-tmp? (path)
  (let ((ok (and (< 5 (string-length path)) (= "/tmp/" (string-copy path 0 5)))) (i 0))
    (while (and ok (< i (string-length path)))
      (let ((c (string-at path i)))
	(or (and (<= ?a c) (<= c ?z)) (and (<= ?A c) (<= c ?Z)) (and (<= ?0 c) (<= c ?9)) (= c ?-) (= c ?.) (= c ?_) (= c ?/)
	    (set ok ()))
	(and (= c ?.) (< (+ i 1) (string-length path)) (= ?. (string-at path (+ i 1))) (set ok ())))
      (set i (+ i 1)))
    ok))
(define check-tmp
  (let ((named (env-var "MARU_CHECK_TMP")))
    (if named
	(if (safe-tmp? named) named (error "MARU_CHECK_TMP must be a plain path under /tmp/: " named))
      (concat-strings "/tmp/maru-check/" (checkout-name)))))
(require "spawn.l")
(command-status (make <command> argv: (list "mkdir" "-p" check-tmp)))
