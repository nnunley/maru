;;; SHA-256 (FIPS 180-4), which exe.l signs Mach-O files with.
;;;   (sha256 array start length)   the digest of those bytes, as a list of 32 bytes
(define sha256-k
  (list->array
   '(0x428a2f98 0x71374491 0xb5c0fbcf 0xe9b5dba5 0x3956c25b 0x59f111f1 0x923f82a4 0xab1c5ed5
     0xd807aa98 0x12835b01 0x243185be 0x550c7dc3 0x72be5d74 0x80deb1fe 0x9bdc06a7 0xc19bf174
     0xe49b69c1 0xefbe4786 0x0fc19dc6 0x240ca1cc 0x2de92c6f 0x4a7484aa 0x5cb0a9dc 0x76f988da
     0x983e5152 0xa831c66d 0xb00327c8 0xbf597fc7 0xc6e00bf3 0xd5a79147 0x06ca6351 0x14292967
     0x27b70a85 0x2e1b2138 0x4d2c6dfc 0x53380d13 0x650a7354 0x766a0abb 0x81c2c92e 0x92722c85
     0xa2bfe8a1 0xa81a664b 0xc24b8b70 0xc76c51a3 0xd192e819 0xd6990624 0xf40e3585 0x106aa070
     0x19a4c116 0x1e376c08 0x2748774c 0x34b0bcb5 0x391c0cb3 0x4ed8aa4a 0x5b9cca4f 0x682e6ff3
     0x748f82ee 0x78a5636f 0x84c87814 0x8cc70208 0x90befffa 0xa4506ceb 0xbef9a3f7 0xc67178f2)))
(define-function sha256-add (a b) (& (+ a b) 0xffffffff))
(define-function sha256-rotr (x n) (& (| (>> x n) (<< x (- 32 n))) 0xffffffff))
(define-function sha256-xor3 (a b c) (^ (^ a b) c))

;; one 64-byte block at bytes[at], into state h, an array of eight words
(define-function sha256-block (h bytes at w)
  (for (i 0 16)
    (let ((j (+ at (* i 4))))
      (set-array-at w i (| (<< (array-at bytes j) 24)
			   (| (<< (array-at bytes (+ j 1)) 16)
			      (| (<< (array-at bytes (+ j 2)) 8) (array-at bytes (+ j 3))))))))
  (for (i 16 64)
    (let* ((x (array-at w (- i 15))) (y (array-at w (- i 2)))
	   (s0 (sha256-xor3 (sha256-rotr x 7) (sha256-rotr x 18) (>> x 3)))
	   (s1 (sha256-xor3 (sha256-rotr y 17) (sha256-rotr y 19) (>> y 10))))
      (set-array-at w i (sha256-add (sha256-add (array-at w (- i 16)) s0) (sha256-add (array-at w (- i 7)) s1)))))
  (let ((a (array-at h 0)) (b (array-at h 1)) (c (array-at h 2)) (d (array-at h 3))
	(e (array-at h 4)) (f (array-at h 5)) (g (array-at h 6)) (k (array-at h 7)))
    (for (i 0 64)
      (let* ((s1 (sha256-xor3 (sha256-rotr e 6) (sha256-rotr e 11) (sha256-rotr e 25)))
	     (ch (^ (& e f) (& (^ e 0xffffffff) g)))
	     (t1 (sha256-add (sha256-add k s1) (sha256-add ch (sha256-add (array-at sha256-k i) (array-at w i)))))
	     (s0 (sha256-xor3 (sha256-rotr a 2) (sha256-rotr a 13) (sha256-rotr a 22)))
	     (maj (sha256-xor3 (& a b) (& a c) (& b c)))
	     (t2 (sha256-add s0 maj)))
	(set k g) (set g f) (set f e) (set e (sha256-add d t1))
	(set d c) (set c b) (set b a) (set a (sha256-add t1 t2))))
    (let ((i 0))
      (list-do v (list a b c d e f g k)
	(set-array-at h i (sha256-add (array-at h i) v))
	(set i (+ i 1))))))

(define-function sha256 (bytes start length)
  (let ((h (list->array '(0x6a09e667 0xbb67ae85 0x3c6ef372 0xa54ff53a 0x510e527f 0x9b05688c 0x1f83d9ab 0x5be0cd19)))
	(w (array 64))
	(at start)
	(end (+ start length))
	(last (array)))
    (while (<= (+ at 64) end)
      (sha256-block h bytes at w)
      (set at (+ at 64)))
    ;; what's left, the 1 bit, zeros, and the length in bits, as one block or two
    (while (< at end) (array-append last (array-at bytes at)) (set at (+ at 1)))
    (array-append last 0x80)
    (while (not (= 56 (& (array-length last) 63))) (array-append last 0))
    (let ((bits (* length 8)))
      (for (i 0 8) (array-append last (& (>> bits (* 8 (- 7 i))) 255))))
    (for (i 0 (/ (array-length last) 64)) (sha256-block h last (* i 64) w))
    (let ((out ()))
      (for (i 0 8)
	(let ((word (array-at h (- 7 i))))
	  (for (j 0 4) (push out (& (>> word (* 8 j)) 255)))))
      out)))
