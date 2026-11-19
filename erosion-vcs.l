;;; erosion-vcs.l -- a change and its base's files from git or jj, in a repository at root, submodules followed
;;; (doc/rfc/draft-ndn-erosion-attribution-00.md).  Every program starts directly (spawn.l), the revision one argument.
(require "erosion-attribute.l")
(require "erosion-files.l")

(define-function vcs-kind (root)	; MARU_VCS, else jj where root holds .jj/, else git
  (let ((named (spawn-getenv "MARU_VCS")))
    (cond (named (string->symbol named)) ((exists? (concat-string root "/.jj")) 'jj) (else 'git))))
(define-function vcs-output (dir argv)	; argv's standard output, or () if it failed
  (let ((r (program-result argv dir))) (and (= 0 (car r)) (cdr r))))
(define-function vcs-commit (root rev)	; the git commit a revision names, or ()
  (let ((out (if (= 'jj (vcs-kind root))
		 (vcs-output root (list "jj" "log" "--no-graph" "-r" rev "-T" "commit_id"))
	       (vcs-output root (list "git" "rev-parse" "--verify" "--quiet" (concat-string rev "^{commit}"))))))
    (and out (< 0 (string-length out)) (car (text-lines out)))))
(define-function vcs-revision? (root rev) (and (vcs-commit root rev) 't))
(define-function vcs-diff (root rev)
  (if (= 'jj (vcs-kind root))
      (vcs-output root (list "jj" "diff" "--git" "--context" "0" "--from" rev "--to" "@"))
    (vcs-output root (list "git" "diff" "--unified=0" "--no-color" "--no-ext-diff" rev "--"))))
(define-function vcs-show (root rev path)	; a file's text at a revision, or ()
  (if (= 'jj (vcs-kind root))
      (vcs-output root (list "jj" "file" "show" "-r" rev path))
    (vcs-output root (list "git" "show" (concat-strings rev ":" path)))))
(define-function vcs-ledger-at (root rev)	; the base's ledger values, (erosion . verbosity), or ()
  (let ((text (vcs-show root rev "check/erosion"))) (and text (erosion-ledger text))))

;; a change for one file of a diff, its paths prefixed (a submodule's directory), its base read by show
(define-function hunk-numbers (hs side)
  (hunk-lines hs (lambda (h) (if (= side 'new) (<hunk>-new-start h) (<hunk>-old-start h)))
	      (lambda (h) (if (= side 'new) (<hunk>-new-count h) (<hunk>-old-count h)))))
(define-function current-text (root path) (let ((f (concat-strings root "/" path))) (and (exists? f) (contents-of-file-named f))))
(define-function diff-change (root prefix fd show)
  (let ((was (<file-diff>-old-path fd)) (now (<file-diff>-new-path fd)) (hs (<file-diff>-hunks fd)))	; not new: make uses it
    (make <change> path: (concat-string prefix (or now was)) old-path: (concat-string prefix (or was now))
	  base-text: (and was (show was)) current-text: (and now (current-text root (concat-string prefix now)))
	  added: (hunk-numbers hs 'new) removed: (hunk-numbers hs 'old))))
(define-function measured-change? (fd prefix)
  (and (not (= 'submodule (<file-diff>-status fd)))
       (measured-file? (concat-string prefix (or (<file-diff>-new-path fd) (<file-diff>-old-path fd))))))
(define-function untracked (dir prefix)	; new files git doesn't ignore, as changes that add them
  (let ((out ()))
    (list-do f (text-lines (or (vcs-output dir '("git" "ls-files" "-o" "--exclude-standard")) ""))
      (and (measured-file? (concat-string prefix f)) (push out f)))
    (list-reverse! out)))
(define-function added-change (root path)
  (let ((text (current-text root path)))
    (make <change> path: path old-path: path base-text: () current-text: text added: (let ((n (list-length (text-lines text))) (out ())) (for (i 1 (+ n 1)) (push out i)) (list-reverse! out)) removed: ())))
(define-function changes-from (root dir prefix text show)	; a diff's measured changes, then untracked files, under prefix
  (let ((out ()))
    (list-do fd (if text (read-diff text) ()) (and (measured-change? fd prefix) (push out (diff-change root prefix fd show))))
    (list-do f (untracked dir prefix) (push out (added-change root (concat-string prefix f))))
    (list-reverse! out)))

;; submodules: each path .gitmodules names, its commit as recorded at the base, against its working copy, by git inside it
(define-function submodule-paths (root)
  (let ((out ()))
    (list-do l (text-lines (or (current-text root ".gitmodules") ""))
      (let ((i 0)) (while (and (< i (string-length l)) (= ?\t (string-at l i))) (incr i))
	   (and (< (+ i 7) (string-length l)) (= "path = " (string-copy l i 7)) (push out (string-copy l (+ i 7) (- (string-length l) (+ i 7)))))))
    (list-reverse! out)))
(define-function recorded-commit (root commit path)	; "160000 commit SHA\tpath" -> SHA
  (let ((out (vcs-output root (list "git" "ls-tree" commit path))))
    (and out (< 54 (string-length out)) (string-copy out 14 40))))	; "160000 commit " is 14 characters
(define-function submodule-changes (root commit path)
  (let ((old (recorded-commit root commit path)) (dir (concat-strings root "/" path)) (prefix (concat-string path "/")))
    (and old (changes-from root dir prefix (vcs-output dir (list "git" "diff" "--unified=0" "--no-color" "--no-ext-diff" old "--"))
			   (lambda (p) (vcs-output dir (list "git" "show" (concat-strings old ":" p))))))))
(define-function vcs-changes (root rev)	; the superproject's changes, its untracked files', then each submodule's
  (let ((commit (vcs-commit root rev)) (out ()))
    (set out (changes-from root (if (= 'jj (vcs-kind root)) "/nonexistent" root) "" (vcs-diff root rev) (lambda (p) (vcs-show root rev p))))
    (list-do s (submodule-paths root) (set out (concat-list out (submodule-changes root commit s))))
    out))

;; ---- the command's lines: the report for the working copy against rev
(define-function string-search-text (text sub)
  (let ((i 0) (n (- (string-length text) (string-length sub))) (hit ()))
    (while (and (not hit) (<= i n)) (and (= sub (string-copy text i (string-length sub))) (set hit 't)) (incr i))
    hit))
(define-function conflicted? (text) (and text (or (= 0 (string-compare text "<<<<<<< conflict " 0 17)) (string-search-text text "\n<<<<<<< conflict "))))
(define-function tree-now-of (root)	; the whole tree measured now, conflicted files left out (their markers aren't Maru)
  (let ((sources ()))
    (list-do f (measured-files root)
      (let ((text (current-text root f)))
	(or (not text) (conflicted? text) (push sources (cons f (erosion-read-file (concat-strings root "/" f)))))))
    (erosion-of (list-reverse! sources))))
(define-function conflicted-lines (changes)	; each conflicted file's sides, each side's report under its label
  (let ((out ()))
    (list-do c changes
      (list-do s (attribute-conflicted (<change>-path c) (<change>-base-text c) (<change>-current-text c))
	(set out (concat-list out (cons (concat-strings "side " (car s) " of " (<change>-path c) ":") (attribution-report (cdr s)))))))
    out))
(define-function attribution-command-lines (root rev)
  (let* ((changes (vcs-changes root rev)) (plain ()) (sides ()))
    (list-do c changes (if (conflicted? (<change>-current-text c)) (push sides c) (push plain c)))
    (if (not changes)
	(list (concat-string "no change against " rev))
      (concat-list (attribution-report (attribute (list-reverse! plain) (tree-now-of root) (vcs-ledger-at root rev)))
		   (conflicted-lines sides)))))
