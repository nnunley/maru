;;; git-object.l -- git object ids computed in Maru (doc/plans/2026-11-20-git-blob-ids-design.md), with no git process.
;;;   (git-object-format root)   'sha1 or 'sha256: the repository's extensions.objectformat, sha1 when absent
;;;   (git-blob-id path root)    the hex id git gives the file at path, in root's repository's format
;;; The id is git's: the header "blob SIZE", a NUL, then the file's bytes, never a string (a string stops at a NUL and
;;; holds characters).  These ids are content addresses: on bare metal they are the keys of history's store (roadmap).
(define compile-tpeg-definitions-only 1)
(require "compile-tpeg.l")
(require "spawn.l")	; exists?
(require "file-bytes.l")
(require "sha1.l")
(tpeg-load "git-repo.g")

(define-function git-repo-read (rule text)	; what rule reads of all of text
  (let ((p (text-parser-for-on <git-repo> text))) (and (rule p) (<text-parser>-result p))))
(define-function git-lower (s)	; ASCII letters lowercased, as git compares a config's names
  (let ((out (string-copy s 0 (string-length s))))
    (for (i 0 (string-length s)) (let ((c (string-at s i))) (and (<= ?A c) (<= c ?Z) (set-string-at out i (+ c 32)))))
    out))
(define-function git-path (base p)	; p, against base when relative
  (if (and (< 0 (string-length p)) (= ?/ (string-at p 0))) p (concat-strings base "/" p)))
(define-function git-dir (root)	; the directory holding root's config: .git, a gitdir: it names, its commondir
  (let ((dot (concat-string root "/.git")))
    (or (exists? dot) (error "git-object: no repository at " root))
    (let ((dir (if (exists? (concat-string dot "/HEAD")) dot
		 (git-path root (or (git-repo-read $gitfile (contents-of-file-named dot)) (error "git-object: can't read " dot))))))
      (let ((common (concat-string dir "/commondir")))
	(if (exists? common) (git-path dir (git-repo-read $line (contents-of-file-named common))) dir)))))
(define-function git-object-format (root)
  (let ((section "") (format 'sha1))
    (list-do x (or (git-repo-read $config (or (contents-of-file-named (concat-string (git-dir root) "/config")) "")) ())
      (cond ((not x))
	    ((= 'section (car x)) (set section (git-lower (cdr x))))
	    ((and (= section "extensions") (= "objectformat" (git-lower (car x)))) (set format (string->symbol (git-lower (cdr x)))))))
    (or (member? format '(sha1 sha256)) (error "git-object: " root "'s object format is " format ", neither sha1 nor sha256"))
    format))
(define-function git-blob-id (path root)
  (let* ((file (file-bytes path)) (size (cdr file)) (header (concat-string "blob " (long->string size))) (bytes (array)))
    (for (i 0 (string-length header)) (array-append bytes (string-at header i)))
    (array-append bytes 0)
    (for (i 0 size) (array-append bytes (byte-at (car file) i)))
    (let ((digest (if (= 'sha256 (git-object-format root)) (sha256 bytes 0 (array-length bytes)) (sha1 bytes 0 (array-length bytes))))
	  (out ""))
      (list-do b digest (set out (concat-string out (format "%02x" b))))
      out)))
