;;; socket.l: TCP on 127.0.0.1, through subr.  Every constant and layout is osdefs.k's, measured from this system's
;;; headers by system.osdefs: the socket numbers, and where a sockaddr_in keeps its family, port and address.  Strings pass
;;; through one C buffer.
;;;   (socket-connect port seconds)  a connected descriptor, reads timing out after seconds, or () if nothing answers
;;;   (socket-send fd text)          true, or () if the peer has gone
;;;   (socket-receive-all fd)        what arrives to the end of the stream, or () on a timeout or reset
;;;   (socket-listen port)           (descriptor . port), port 0 letting the system choose; (socket-accept fd) takes one
;;;   (socket-close fd)
;;; What a peer can do is answered, not signalled, so a caller needs no handler (recover.l); setting up a socket that
;;; fails is an error, and closes it first.  A peer that closes early is never SIGPIPE: SO_NOSIGPIPE where the system has
;;; it, and MSG_NOSIGNAL on every send where it has that.
(require "osdefs.k")
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
(define socket-address ((subr "malloc" "l>p") sockaddr_in_size))
(define socket-scratch ((subr "malloc" "l>p") timeval_size))

(define-function socket-fill (buffer n byte) (for (i 0 n) (set-byte-at buffer i byte)) buffer)
(define-function socket-check (what r) (if (< r 0) (error "socket: " what " failed") r))
(define-function socket-check-open (fd what r)	; closes fd before failing, so nothing leaks
  (if (< r 0) (let () (socket-close fd) (error "socket: " what " failed")) r))
(define-function socket-option (fd name value bytes)	; value in the first bytes, little-endian
  (socket-fill socket-scratch timeval_size 0)
  (set-byte-at socket-scratch 0 (& 255 value))
  (set-byte-at socket-scratch 1 (& 255 (>> value 8)))
  (socket-check-open fd "setsockopt" (socket-option-c fd SOL_SOCKET name socket-scratch bytes)))
(define-function socket-sockaddr (port)		; family, port big-endian, 127.0.0.1, the rest zeros
  (socket-fill socket-address sockaddr_in_size 0)
  ;; a byte before the family is BSD's length (the kernel takes it from the call), and the family is little-endian here
  (and (< 0 sockaddr_in_family) (set-byte-at socket-address 0 sockaddr_in_size))
  (for (i 0 sockaddr_in_family_size) (set-byte-at socket-address (+ sockaddr_in_family i) (& 255 (>> AF_INET (* 8 i)))))
  (set-byte-at socket-address sockaddr_in_port (& 255 (>> port 8)))
  (set-byte-at socket-address (+ sockaddr_in_port 1) (& 255 port))
  (set-byte-at socket-address sockaddr_in_addr 127)
  (set-byte-at socket-address (+ sockaddr_in_addr 3) 1)
  socket-address)
(define-function socket-tcp ()
  (let ((fd (socket-check "socket" (socket-c AF_INET SOCK_STREAM 0))))
    (or (= 0 SO_NOSIGPIPE) (socket-option fd SO_NOSIGPIPE 1 4))
    fd))
(define-function socket-connect (port seconds)
  (let ((fd (socket-tcp)))
    (socket-option fd SO_RCVTIMEO seconds timeval_size)	; a struct timeval, its seconds first
    (if (< (socket-connect-c fd (socket-sockaddr port) sockaddr_in_size) 0)
	(let () (socket-close fd) ())
      fd)))
(define-function socket-listen (port)
  (let ((fd (socket-tcp)))
    (socket-option fd SO_REUSEADDR 1 4)
    (socket-check-open fd "bind" (socket-bind-c fd (socket-sockaddr port) sockaddr_in_size))
    (socket-check-open fd "listen" (socket-listen-c fd 8))
    (set-byte-at (socket-fill socket-scratch 4 0) 0 sockaddr_in_size)
    (socket-check-open fd "getsockname" (socket-name-c fd socket-address socket-scratch))
    (cons fd (+ (<< (byte-at socket-address sockaddr_in_port) 8) (byte-at socket-address (+ sockaddr_in_port 1))))))
(define-function socket-accept (fd) (socket-check "accept" (socket-accept-c fd 0 0)))
(define-function socket-send (fd text)
  (let ((n (string-length text)) (at 0) (gone ()))
    (while (and (< at n) (not gone))
      (let ((count (min socket-buffer-size (- n at))) (sent 0))
	(for (i 0 count) (set-byte-at socket-buffer i (string-at text (+ at i))))
	(while (and (< sent count) (not gone))
	  (let ((r (socket-send-c fd (+ socket-buffer sent) (- count sent) MSG_NOSIGNAL)))
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
