;;; SHA-1 (FIPS 180-4), for git's object ids (git-object.l).  Broken for signatures, but it is what names a SHA-1
;;; repository's objects.
;;;   (sha1 array start length)   the digest of those bytes, as a list of 20 bytes
(require "sha256.l")	; sha-digest, sha-words
(define-function sha1-rotl (x n) (& (| (<< x n) (>> x (- 32 n))) 0xffffffff))
(define-function sha1-fk (i b c d)	; the round's function of b, c and d, and its constant, (f . k)
  (cond ((< i 20) (cons (| (& b c) (& (^ b 0xffffffff) d)) 0x5a827999))
	((< i 40) (cons (^ (^ b c) d) 0x6ed9eba1))
	((< i 60) (cons (| (| (& b c) (& b d)) (& c d)) 0x8f1bbcdc))
	(else (cons (^ (^ b c) d) 0xca62c1d6))))
;; one 64-byte block at bytes[at], into state h, an array of five words
(define-function sha1-block (h bytes at w)
  (sha-words w bytes at)
  (for (i 16 80)
    (set-array-at w i (sha1-rotl (^ (^ (array-at w (- i 3)) (array-at w (- i 8))) (^ (array-at w (- i 14)) (array-at w (- i 16)))) 1)))
  (let ((a (array-at h 0)) (b (array-at h 1)) (c (array-at h 2)) (d (array-at h 3)) (e (array-at h 4)))
    (for (i 0 80)
      (let* ((fk (sha1-fk i b c d))
	     (tmp (sha256-add (sha256-add (sha1-rotl a 5) (car fk)) (sha256-add e (sha256-add (cdr fk) (array-at w i))))))
	(set e d) (set d c) (set c (sha1-rotl b 30)) (set b a) (set a tmp)))
    (let ((i 0))
      (list-do v (list a b c d e)
	(set-array-at h i (sha256-add (array-at h i) v))
	(set i (+ i 1))))))
(define-function sha1 (bytes start length)
  (sha-digest (list->array '(0x67452301 0xefcdab89 0x98badcfe 0x10325476 0xc3d2e1f0)) sha1-block bytes start length))
