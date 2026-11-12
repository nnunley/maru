;;; png.l -- (png-load path) reads a PNG (8-bit RGBA or RGB, not interlaced) to a <png>: its width, height and pixels,
;;; width x height ARGB words (alpha in the top byte, not premultiplied) in C memory, as a Gezira image holds them.
;;; The decoding is png.irl's, typed and lowered through ir2 into build/png.dylib (make builds it): every chunk's CRC-32
;;; checked, the image data inflated (RFC 1950 and 1951: stored, fixed and dynamic Huffman blocks) and checked against its
;;; Adler-32, and each row's filter undone (PNG 9.2); ancillary chunks are skipped and an unknown critical one refused.
;;; Anything else is an error naming it.  png-encode writes an image back, for the round trip PNG's losslessness promises.
(require "file-bytes.l")

(define-structure <png> (width height pixels))

(require "spawn.l")
(define png-library-path (if (darwin?) "build/png.dylib" "build/png.so"))
(define png-library
  (let ((lib ((subr "dlopen" "si>p") png-library-path 2)))
    (and (= 0 lib) (error "png: " png-library-path " not built; run make " png-library-path))
    lib))
(define png-decode-entry (subr ((subr "dlsym" "ps>p") png-library "png_decode") "plp>l"))
(define png-encode-entry (subr ((subr "dlsym" "ps>p") png-library "png_encode") "plllpllp"))
(define png-errors
  '((1 . "not a PNG") (2 . "a chunk's CRC doesn't match") (3 . "a bit depth other than 8 isn't read")
    (4 . "a colour type other than RGB and RGBA isn't read") (5 . "interlaced images aren't read")
    (6 . "the image data isn't zlib's deflate") (7 . "the file ends early") (8 . "a Huffman code no table holds")
    (9 . "a distance past the start") (10 . "a deflate block of an unknown type") (11 . "the image data is the wrong size")
    (12 . "the image data's Adler-32 doesn't match") (13 . "a row has an unknown filter")
    (14 . "a repeat with no length before it") (15 . "an unknown critical chunk")
    (16 . "IHDR isn't the first chunk") (17 . "IHDR isn't 13 bytes") (18 . "the width or height is 0")
    (19 . "the image is too large") (20 . "a compression or filter method other than 0") (21 . "there is no IEND")
    (22 . "the image data asks for a preset dictionary") (23 . "a stored block's length doesn't match its complement")
    (24 . "a Huffman code with more codes than its lengths allow") (25 . "a length or distance code no stream may use")))

;; the PNG held at address, size bytes long: (error-number . <png>), the image when the number is 0
(define-function png-decode-status (address size)
  (let* ((info ((subr "calloc" "ll>p") 3 8))
	 (err (png-decode-entry address size info))
	 (img (and (= 0 err) (new <png> (long-at info 0) (long-at info 1) (long-at info 2)))))
    ((subr "free" "p") info)
    (cons err img)))
(define-function png-refuse (what err) (error "png: " what ": " (or (cdr (assq err png-errors)) err)))

;; the PNG held at address, size bytes long; what names it says where it came from
(define-function png-decode (address size what)
  (let ((r (png-decode-status address size)))
    (or (= 0 (car r)) (png-refuse what (car r)))
    (cdr r)))

;; the file's bytes are freed whether the image is read or refused
(define-function png-load (path)
  (let* ((file (file-bytes path)) (r (png-decode-status (car file) (cdr file))))
    ((subr "free" "p") (car file))
    (or (= 0 (car r)) (png-refuse path (car r)))
    (cdr r)))

;; an image written as a PNG: (address . length), RGBA if rgba is 1 (else RGB, alpha dropped), row y filtered as the
;; yth of filters, deflated in stored blocks (block 0) or fixed Huffman ones (1), its data in IDAT chunks of at most
;; chunk bytes
(define-function png-encode (img rgba filters block chunk)
  (let ((rows ((subr "malloc" "l>p") (* 8 (<png>-height img)))) (info ((subr "calloc" "ll>p") 2 8)) (y 0))
    (list-do f filters (set-long-at rows y f) (set y (+ y 1)))
    (png-encode-entry (<png>-pixels img) (<png>-width img) (<png>-height img) rgba rows block chunk info)
    ((subr "free" "p") rows)
    (cons (long-at info 0) (long-at info 1))))

;; a pixel as an ARGB word
(define-function png-pixel (img x y)
  (let ((d (* 4 (+ (* y (<png>-width img)) x))) (px (<png>-pixels img)))
    (+ (<< (byte-at px (+ d 3)) 24) (+ (<< (byte-at px (+ d 2)) 16) (+ (<< (byte-at px (+ d 1)) 8) (byte-at px d))))))
