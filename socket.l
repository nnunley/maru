;;; socket.l: TCP on 127.0.0.1, through subr.  A sockaddr_in is laid out by hand, as check/jobs.l lays out a rusage: Darwin's
;;; starts with a length byte and Linux's doesn't, so the system's name (uname's first field) picks the layout and the
;;; socket option numbers.  Strings pass through one C buffer.
;;;   (socket-connect port seconds)  a connected descriptor, reads timing out after seconds, or () if nothing answers
;;;   (socket-send fd text)          true, or () if the peer has gone
;;;   (socket-receive-all fd)        what arrives to the end of the stream, or () on a timeout or reset
;;;   (socket-listen port)           (descriptor . port), port 0 letting the system choose; (socket-accept fd) takes one
;;;   (socket-close fd)
;;; What a peer can do is answered, not signalled, so a caller needs no handler (recover.l); setting up a socket that
;;; fails is an error, and closes it first.
(define socket-c	(subr "socket" "iii>i"))
(define socket-bind-c	(subr "bind" "ipi>i"))
(define socket-listen-c	(subr "listen" "ii>i"))
(define socket-accept-c	(subr "accept" "ipp>i"))
(define socket-connect-c (subr "connect" "ipi>i"))
(define socket-option-c	(subr "setsockopt" "iiipi>i"))
(define socket-name-c	(subr "getsockname" "ipp>i"))
(define socket-send-c	(subr "send" "ipli>l"))
(define socket-read-c	(subr "read" "ipl>l"))
(define socket-close	(subr "close" "i>i"))
(define socket-buffer-size 4096)
(define socket-buffer ((subr "malloc" "l>p") socket-buffer-size))
(define socket-address ((subr "malloc" "l>p") 16))
(define socket-scratch ((subr "malloc" "l>p") 16))
(define socket-darwin?
  (let ((names ((subr "malloc" "l>p") 1280)))
    ((subr "uname" "p>i") names)
    (and (= ?D (byte-at names 0)) (= ?a (byte-at names 1)))))
;; SOL_SOCKET, and the options under it
(define socket-level (if socket-darwin? 65535 1))
(define socket-reuse (if socket-darwin? 4 2))
(define socket-receive-timeout (if socket-darwin? 4102 20))
;; a peer that closes early is an error, not SIGPIPE ending the program: SO_NOSIGPIPE on Darwin, MSG_NOSIGNAL on Linux
(define socket-no-sigpipe (if socket-darwin? 4130 ()))
(define socket-send-flags (if socket-darwin? 0 16384))

(define-function socket-fill (buffer n byte) (for (i 0 n) (set-byte-at buffer i byte)) buffer)
(define-function socket-check (what r) (if (< r 0) (error "socket: " what " failed") r))
(define-function socket-check-open (fd what r)	; closes fd before failing, so nothing leaks
  (if (< r 0) (let () (socket-close fd) (error "socket: " what " failed")) r))
(define-function socket-option (fd name value bytes)
  (socket-fill socket-scratch 16 0)
  (set-byte-at socket-scratch 0 (& 255 value))
  (set-byte-at socket-scratch 1 (& 255 (>> value 8)))
  (socket-check-open fd "setsockopt" (socket-option-c fd socket-level name socket-scratch bytes)))
(define-function socket-sockaddr (port)		; family, port big-endian, 127.0.0.1, eight zeros
  (socket-fill socket-address 16 0)
  (if socket-darwin?
      (let () (set-byte-at socket-address 0 16) (set-byte-at socket-address 1 2))
    (set-byte-at socket-address 0 2))
  (set-byte-at socket-address 2 (& 255 (>> port 8)))
  (set-byte-at socket-address 3 (& 255 port))
  (set-byte-at socket-address 4 127)
  (set-byte-at socket-address 7 1)
  socket-address)
(define-function socket-tcp ()			; AF_INET, SOCK_STREAM
  (let ((fd (socket-check "socket" (socket-c 2 1 0))))
    (and socket-no-sigpipe (socket-option fd socket-no-sigpipe 1 4))
    fd))
(define-function socket-connect (port seconds)
  (let ((fd (socket-tcp)))
    (socket-option fd socket-receive-timeout seconds 16)	; a struct timeval: seconds, then microseconds
    (if (< (socket-connect-c fd (socket-sockaddr port) 16) 0)
	(let () (socket-close fd) ())
      fd)))
(define-function socket-listen (port)
  (let ((fd (socket-tcp)))
    (socket-option fd socket-reuse 1 4)
    (socket-check-open fd "bind" (socket-bind-c fd (socket-sockaddr port) 16))
    (socket-check-open fd "listen" (socket-listen-c fd 8))
    (set-byte-at (socket-fill socket-scratch 4 0) 0 16)
    (socket-check-open fd "getsockname" (socket-name-c fd socket-address socket-scratch))
    (cons fd (+ (<< (byte-at socket-address 2) 8) (byte-at socket-address 3)))))
(define-function socket-accept (fd) (socket-check "accept" (socket-accept-c fd 0 0)))
(define-function socket-send (fd text)
  (let ((n (string-length text)) (at 0) (gone ()))
    (while (and (< at n) (not gone))
      (let ((count (min socket-buffer-size (- n at))) (sent 0))
	(for (i 0 count) (set-byte-at socket-buffer i (string-at text (+ at i))))
	(while (and (< sent count) (not gone))
	  (let ((r (socket-send-c fd (+ socket-buffer sent) (- count sent) socket-send-flags)))
	    (if (< r 0) (set gone 1) (set sent (+ sent r)))))
	(set at (+ at count))))
    (not gone)))
(define-function socket-receive-all (fd)
  (let ((parts ()) (r 1))
    (while (< 0 r)
      (set r (socket-read-c fd socket-buffer socket-buffer-size))
      (when (< 0 r)
	(let ((s (string r)))
	  (for (i 0 r) (set-string-at s i (byte-at socket-buffer i)))
	  (push parts s))))
    (and (= r 0) (apply concat-strings (list-reverse! parts)))))
