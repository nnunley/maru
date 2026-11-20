;;; check/git-object.l -- git object ids computed in Maru (git-object.l, doc/measures.md): SHA-1 against NIST's vectors;
;;; a file's blob id against git hash-object's, in SHA-1 and SHA-256 repositories and a worktree.
(require "sha1.l")
(require "git-object.l")
(require "erosion-files.l")	; text-lines
(require "recover.l")	; try

(require "check/erosion-common.l")	; ok, expect
(require "check/bytes.l")	; bytes-of-string, hex
(define-function digest (s) (hex (sha1 (bytes-of-string s) 0 (string-length s))))
(define-function a-times (n) (let ((s "")) (for (i 0 n) (set s (concat-string s "a"))) s))

(expect "sha1 empty" (digest "") "da39a3ee5e6b4b0d3255bfef95601890afd80709")
(expect "sha1 abc" (digest "abc") "a9993e364706816aba3e25717850c26c9cd0d89d")
(expect "sha1 two blocks" (digest "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq") "84983e441c3bd26ebaae4aa1f95129e5e54670f1")
(expect "sha1 55" (digest (a-times 55)) "c1c8bbdc22796e28c0e15163d20899b65621d65a")
(expect "sha1 56" (digest (a-times 56)) "c2db330f6083854c99d4b5bfb6e8f29f201be699")
(expect "sha1 64" (digest (a-times 64)) "0098ba824b5c16427bd7a1122a5a442a25ec644d")

;; ---- blob ids: git is the oracle, in repositories made in the check's scratch directory
(define scratch (concat-strings (or (spawn-getenv "MARU_CHECK_TMP") "/tmp") "/git-object-" (long->string ((subr "getpid" ">i")))))
(remove-tree scratch)
(make-directory scratch)
(define-function git-in (dir . args)	; git's output there, its first line
  (car (text-lines (cdr (program-result (concat-list (list "git" "-c" "user.email=t@t" "-c" "user.name=t") args) dir)))))
(define-function new-repo (name format)
  (let ((dir (concat-strings scratch "/" name))) (make-directory dir) (git-in dir "init" "-q" (concat-string "--object-format=" format) ".") dir))
(define-function write-bytes (path bytes)	; bytes written one by one, a NUL among them if need be
  (let ((f ((subr "fopen" "ss>p") path "wb")) (fputc (subr "fputc" "ip>i")))
    (list-do b bytes (fputc b f))
    ((subr "fclose" "p>i") f)))
(define-function gits-id (dir name) (git-in dir "hash-object" "--no-filters" name))
(define sha1-repo (new-repo "one" "sha1"))
(define sha256-repo (new-repo "two" "sha256"))
(contents-to-file-named "héllo → wörld\n" (concat-string sha1-repo "/text"))
(contents-to-file-named "héllo → wörld\n" (concat-string sha256-repo "/text"))
(expect "a file's id, SHA-1" (list (git-blob-id (concat-string sha1-repo "/text") sha1-repo) (gits-id sha1-repo "text"))
	'("5157042005afd04924712f06029d845980ea00f9" "5157042005afd04924712f06029d845980ea00f9"))
(expect "a file's id, SHA-256" (list (git-blob-id (concat-string sha256-repo "/text") sha256-repo) (gits-id sha256-repo "text"))
	'("6799f2cef17ebee190dd8212caaff632212b99d0c699d3b3cb810cc759af4143" "6799f2cef17ebee190dd8212caaff632212b99d0c699d3b3cb810cc759af4143"))
(contents-to-file-named "" (concat-string sha1-repo "/empty"))
(expect "an empty file" (git-blob-id (concat-string sha1-repo "/empty") sha1-repo) "e69de29bb2d1d6434b8b29ae775ad8c2e48c5391")
(write-bytes (concat-string sha1-repo "/nul") '(97 0 98))
(expect "a NUL inside" (git-blob-id (concat-string sha1-repo "/nul") sha1-repo) (gits-id sha1-repo "nul"))
(git-in sha256-repo "add" "text") (git-in sha256-repo "commit" "-qm" "text")
(define tree (concat-string scratch "/tree"))
(git-in sha256-repo "worktree" "add" "-q" tree)
(expect "in a worktree" (list (git-object-format tree) (git-blob-id (concat-string tree "/text") tree)) (list 'sha256 (gits-id tree "text")))
(define moved (concat-string scratch "/moved"))
(make-directory moved)
(contents-to-file-named "gitdir: ../two/.git/worktrees/tree\n" (concat-string moved "/.git"))
(expect "a relative gitdir" (git-object-format moved) 'sha256)
(define cased (new-repo "cased" "sha1"))
(contents-to-file-named "[core]\n\trepositoryformatversion = 1\n[Extensions]\n\tobjectFormat = sha256\n" (concat-string cased "/.git/config"))
(expect "objectFormat in another case" (git-object-format cased) 'sha256)
;; the value as git reads it: whitespace, a comment, quotes and CRLF around it; anything but sha1 or sha256 refused
(define-function format-written (name value)	; a SHA-1 repository whose config is rewritten with value
  (let ((dir (new-repo name "sha1")))
    (contents-to-file-named (concat-strings "[core]\n\trepositoryformatversion = 1\n[extensions]\n\tobjectformat =" value)
			    (concat-string dir "/.git/config"))
    (git-object-format dir)))
(expect "the value with a comment, CRLF, quotes, a trailing space"
	(list (format-written "comment" " sha256 ; a comment\n") (format-written "crlf" " sha256\r\n")
	      (format-written "quoted" " \"sha256\"\n") (format-written "trailing" " sha256 \n"))
	'(sha256 sha256 sha256 sha256))
(expect "a format git doesn't know is refused, not taken for sha1"
	(try (format-written "misspelt" " sha265\n") (lambda (c) 'refused)) 'refused)
(expect "no repository" (try (git-object-format "/nonexistent") (lambda (c) 'refused)) 'refused)
;; ---- the ledger reads with no git process: its fingerprints are computed here
(define-function ledger-read-with (env)	; check/ledger-read.l's output, run with env
  (let ((out (concat-string scratch "/ledger-read.out")))
    (command-status (make <command> argv: '("./eval" "check/ledger-read.l") out: out err: out env: env))
    (contents-of-file-named out)))
(let ((without (ledger-read-with '(("PATH" . "/nonexistent")))) (with (ledger-read-with ())))
  (expect "the ledger reads with no git on PATH, as it does with git" (list (and (string-find without "moved since") 'moved) without) (list () with)))
(remove-tree scratch)

(println (if ok "git object ok" "git object FAILED"))
