;;; Erosion attribution (doc/rfc/draft-ndn-erosion-attribution-00.md): one grammar, diff.g, reads a change and jj's
;;; conflicts; the fixtures in check/erosion-attribution/ are git's and jj's own output.
(require "erosion-attribute.l")
(require "recover.l")
(require "check/erosion-common.l")	; ok, expect, ifs
(define-function fixture (name) (contents-of-file-named (concat-string "check/erosion-attribution/" name)))

;; a unified diff: git's, with its extended headers
(define files (read-diff (fixture "git.diff")))
(define-function file-named (path) (let ((hit ())) (list-do f files (and (= path (<file-diff>-new-path f)) (set hit f))) hit))
(expect "each file's status" (map (lambda (f) (<file-diff>-status f)) files)
	'(modified added deleted renamed modified modified modified submodule))
(expect "a hunk's ranges" (map (lambda (h) (list (<hunk>-old-start h) (<hunk>-old-count h) (<hunk>-new-start h) (<hunk>-new-count h)))
			      (<file-diff>-hunks (file-named "a.l")))
	'((4 1 4 2) (7 1 8 2)))
(expect "a count left out is 1, a 0 is 0" (map (lambda (p) (let ((h (car (<file-diff>-hunks (file-named p))))) (list (<hunk>-old-count h) (<hunk>-new-count h))))
					      '("b.l" "e.l"))
	'((0 1) (1 1)))
(expect "a hunk's lines, a content line of pluses among them"
	(<hunk>-lines (cadr (<file-diff>-hunks (file-named "a.l"))))
	'((- "  2)") (+ "  3)") (+ "++++++ text")))
(expect "no newline at the end counts on neither side" (<hunk>-lines (car (<file-diff>-hunks (file-named "n.l"))))
	'((- "(define n 1)") (+ "(define n 2)")))
(expect "a rename's paths" (let ((r (file-named "e.l"))) (list (<file-diff>-old-path r) (<file-diff>-new-path r))) '("d.l" "e.l"))
(expect "an added file has no old path, a deleted one no new path"
	(list (<file-diff>-old-path (file-named "b.l")) (let ((d ())) (list-do f files (and (= "c.g" (<file-diff>-old-path f)) (set d (<file-diff>-new-path f)))) d))
	'(() ()))
(expect "a path with a space, which git leaves unquoted" (<file-diff>-old-path (file-named "x y.l")) "x y.l")
(expect "a binary file has no hunks" (<file-diff>-hunks (file-named "p.png")) ())
(expect "a submodule's commits" (<file-diff>-submodule (file-named "nile"))
	'("1111111111111111111111111111111111111111" . "2222222222222222222222222222222222222222"))
(expect "a path git quotes, read as the bytes it names" (<file-diff>-new-path (car (read-diff (fixture "quoted.diff"))))
	(list->string (list 195 169 ?. ?l)))
(expect "jj's git format" (map (lambda (f) (<file-diff>-new-path f)) (read-diff (fixture "jj.diff"))) '("f.l"))
(expect "a diff that stops reading says where"
	(try (let () (read-diff "diff --git a/x b/x\ngarbage\n") 'read) (lambda (c) 'refused)) 'refused)

;; jj's conflicts: n sides, each written as a diff or as a snapshot, with the bases between snapshots
(define conflicts (select-conflicts (read-conflicts (fixture "conflict-diff.txt"))))
(expect "two conflicts of three sides" (map (lambda (c) (list (<conflict>-index c) (<conflict>-of c) (list-length (<conflict>-sides c)))) conflicts)
	'((1 2 3) (2 2 3)))
(expect "kinds" (map (lambda (s) (<side>-kind s)) (<conflict>-sides (car conflicts))) '(diff diff snapshot))
(expect "a diff side's label is from and to" (<side>-label (car (<conflict>-sides (car conflicts))))
	'("kyspwnsp 77789aaf \"base\"" . "lsvwuuum 90725a19 \"one\""))
(expect "a diff side's lines are a hunk's" (<side>-lines (car (<conflict>-sides (car conflicts)))) '((- "b") (+ "b-one")))
(expect "a snapshot side's lines are plain" (<side>-lines (caddr (<conflict>-sides (car conflicts)))) '("b-three"))
(expect "snapshot style: bases between the sides"
	(map (lambda (s) (<side>-kind s)) (<conflict>-sides (car (select-conflicts (read-conflicts (fixture "conflict-snapshot.txt"))))))
	'(snapshot base snapshot base snapshot))
(expect "each side's whole file" (conflict-sides (fixture "conflict-small.txt"))
	'(("nkzqsnom 2af2415a \"one\"" . "a\nB1\nc\n") ("xxkslomr 1fa76d66 \"two\"" . "a\nB2\nc\n")))
(expect "both styles give the same sides" (conflict-sides (fixture "conflict-diff.txt")) (conflict-sides (fixture "conflict-snapshot.txt")))

;; ---- attribution: a change's moves, to its edits and to share
(define-function defn (name body) (concat-strings "(define-function " name " ()\n  " body ")\n"))
(define-function select-current (triples) (let ((out ())) (list-do t triples (and (cadddr t) (push out t))) (list-reverse! out)))
(define-function attribution-of (triples . ledger)	; triples: (path old-path base current), texts or () for none
  (let ((changes (map (lambda (t) (text-change (car t) (cadr t) (caddr t) (cadddr t))) triples)))
    (attribute changes (measure-texts (map (lambda (t) (cons (car t) (cadddr t))) (select-current triples))) (car ledger))))
(define-function move-named (a name) (let ((hit ())) (list-do m (<attribution>-moves a) (and (= name (<move>-name m)) (set hit m))) hit))
(define-function sums? (metric) (= (caddr metric) (+ (cadddr metric) (car (cddddr metric)))))

(define crossing (attribution-of (list (list "a.l" "a.l" (concat-string (defn "f" (ifs 9)) (defn "k" "1")) (concat-string (defn "f" (ifs 10)) (defn "k" "1"))))))
(expect "an edited callable crossing 10" (let ((m (move-named crossing 'f))) (list (<move>-edited m) (<move>-cc-before m) (<move>-cc-after m))) '(t 10 11))
(expect "edited + share = whole, for both metrics" (list (sums? (<attribution>-erosion crossing)) (sums? (<attribution>-verbosity crossing))) '(t t))
(expect "the move is all edited" (let ((e (<attribution>-erosion crossing))) (list (> (caddr e) 0) (= (caddr e) (cadddr e)))) '(t t))
(expect "a callable below an edit isn't edited" (let ((m (move-named crossing 'k))) (and m (<move>-edited m))) ())
(expect "a line added alone marks its callable edited"
	(<move>-edited (move-named (attribution-of (list (list "i.l" "i.l" "(define-function f ()\n  1)\n" "(define-function f ()\n  (g)\n  1)\n"))) 'f)) 't)
(expect "a line removed alone marks its callable edited"
	(<move>-edited (move-named (attribution-of (list (list "i.l" "i.l" "(define-function f ()\n  (g)\n  1)\n" "(define-function f ()\n  1)\n"))) 'f)) 't)
(define deleted (attribution-of (list (list "a.l" "a.l" (defn "f" "1") (defn "f" "1")) (list "z.l" "z.l" (defn "z" (ifs 12)) ()))))
(expect "a deleted file's eroded callable: removed, edited, the move negative"
	(let ((m (move-named deleted 'z))) (list (<move>-edited m) (<move>-cc-before m) (<move>-cc-after m) (< (caddr (<attribution>-erosion deleted)) 0)))
	'(t 13 () t))
(define renamed (attribution-of (list (list "e.l" "d.l" (concat-string (defn "d" "1") (defn "e" "2")) (concat-string (defn "d" "1") (defn "e" (ifs 2)))))))
(expect "rename and edit: one move, under the new path" (map (lambda (m) (list (<move>-path m) (<move>-name m) (<move>-edited m))) (<attribution>-moves renamed))
	'(("e.l" e t)))
(define body "(h (+ a 1) (+ a 2) (+ a 3) (+ a 4) 9 8)")
(define clone (attribution-of (list (list "c.l" "c.l" (defn "g" body) (concat-string (defn "g" body) (defn "h" body))))))
(expect "an unedited callable whose clone partner was added moves share, and is named"
	(let ((g (move-named clone 'g))) (list (<move>-edited g) (< (<move>-flagged-before g) (<move>-flagged-after g)) (<move>-edited (move-named clone 'h))))
	'(() t t))
(expect "a ledger that doesn't hold is rebuilt from, and says so"
	(<attribution>-rebuilt (attribution-of (list (list "a.l" "a.l" (defn "f" "1") (defn "f" "2"))) '(999 . 0))) 't)
(expect "a ledger that holds is used" (<attribution>-rebuilt (attribution-of (list (list "a.l" "a.l" (defn "f" "1") (defn "f" "2"))) '(0 . 0))) ())

(define-function select-moves (lines) (let ((out ())) (list-do l lines (and (< 7 (string-length l)) (= "edited " (string-copy l 0 7)) (push out l))) (list-reverse! out)))
;; a function copied from a file the change didn't touch is a clone the edit made: the current side's callables are the
;; whole tree's, whose clones span files
(define copied
  (let ((ch (text-change "b.l" "b.l" (defn "m" "1") (concat-string (defn "m" "1") (defn "h" body)))))
    (attribute (list ch) (measure-texts (list (cons "a.l" (defn "g" body)) (cons "b.l" (<change>-current-text ch)))) ())))
(expect "a copy from an untouched file: its flagged forms are the edit's"
	(let ((h (move-named copied 'h))) (list (<move>-edited h) (< 0 (<move>-flagged-after h)) (< 0 (cadddr (<attribution>-verbosity copied)))))
	'(t t t))

;; ---- the report: worked out by hand for crossing's change (f: CC 10 over 10 forms to CC 11 over 11; k: CC 1, 1 form):
;; erosion now 11 sqrt 11 / (11 sqrt 11 + 1) = 973 per mille, all of it f's edit; no ledger, so the base is rebuilt: 0
(define ledger-before (contents-of-file-named "check/erosion"))
(expect "the report" (attribution-report crossing)
	'("erosion 0 -> 973: whole +973, edited +973, share 0"
	  "verbosity 0 -> 0: whole 0, edited 0, share 0"
	  "the base's values rebuilt from the changed files: no ledger at the base holds"
	  "edited a.l f: CC 10 -> 11 (crossed 10), forms 10 -> 11, flagged 0 -> 0"
	  "ledger:"
	  "erosion +973 edits: f (CC 10 to 11); share 0"))
(expect "a drafted entry reads as the ledger's, to its whole move" (erosion-ledger (concat-string (car (attribution-ledger-entries crossing)) "\n")) '(973 . 0))
(expect "a callable added or removed shows none on that side"
	(car (select-moves (attribution-report deleted))) "edited z.l z: CC 13 -> none, forms 13 -> none, flagged 0 -> none")
(expect "the report writes no file" (contents-of-file-named "check/erosion") ledger-before)

;; ---- a conflicted file, side by side: each side attributed against the conflict's base as a change of its own
(define conflicted-text (concat-strings "(define-function k () 1)\n<<<<<<< conflict 1 of 1\n%%%%%%% diff from: kyspwnsp 77789aaf \"base\"\n"
					"\\\\\\\\\\\\\\        to: lsvwuuum 90725a19 \"one\"\n+(define-function z () " (ifs 12) ")\n"
					"+++++++ ltsypwlm 8cffb44e \"two\"\n>>>>>>> conflict 1 of 1 ends\n"))
(define sides (attribute-conflicted "k.l" "(define-function k () 1)\n" conflicted-text))
(expect "one attribution per side, labelled as jj labels them" (map car sides) '("lsvwuuum 90725a19 \"one\"" "ltsypwlm 8cffb44e \"two\""))
(expect "the side that adds an eroded callable shows it edited; the other doesn't"
	(map (lambda (s) (let ((z (move-named (cdr s) 'z))) (and z (<move>-edited z)))) sides) '(t ()))

;; ---- git and jj, on repositories made here: a superproject with a submodule, edits in both and an untracked file
(require "erosion-vcs.l")
(define scratch (concat-string (attribution-scratch) "/repos"))
(remove-tree scratch)
(define-function git-in (dir . args) (program-result (concat-list (list "git" "-c" "user.email=t@t" "-c" "user.name=t" "-c" "protocol.file.allow=always") args) dir))
(define-function write-in (dir name text) (contents-to-file-named text (concat-strings dir "/" name)))
(define-function new-repo (name files)	; a repository holding files, ((name . text) ...), committed
  (let ((dir (concat-strings scratch "/" name)))
    (make-directory dir)
    (git-in dir "init" "-q" ".")
    (list-do f files (write-in dir (car f) (cdr f)))
    (git-in dir "add" "-A") (git-in dir "commit" "-qm" "base")
    dir))
(define sub (new-repo "sub" (list (cons "x.l" "(define-function x () 1)\n"))))
(define super (new-repo "super" (list (cons "a.l" "(define-function a () 1)\n"))))
(git-in super "submodule" "add" "-q" sub "nile")
(git-in super "commit" "-qm" "submodule")
(write-in super "a.l" "(define-function a () 1)\n(define-function b () 2)\n")
(write-in super "nile/x.l" "(define-function x () 2)\n")
(write-in super "u.l" "(define-function u () 3)\n")
(define changes (vcs-changes super "HEAD"))
(expect "the superproject's file, the untracked one, and the submodule's, prefixed"
	(map (lambda (c) (<change>-path c)) changes) '("a.l" "u.l" "nile/x.l"))
(expect "an untracked file has no base; a submodule's base is its recorded commit's"
	(map (lambda (c) (<change>-base-text c)) changes) '("(define-function a () 1)\n" () "(define-function x () 1)\n"))
(expect "the lines a change added" (<change>-added (car changes)) '(2))
(expect "a revision that doesn't exist" (vcs-revision? super "nosuch") ())
(expect "a clean repository: no change" (attribution-command-lines (new-repo "clean" (list (cons "c.l" "(define c 1)\n"))) "HEAD")
	'("no change against HEAD"))
(expect "the command refuses a revision that doesn't exist"
	(let ((r (program-result '("./eval" "erosion-attribute-run.l" "nosuch") ()))) (list (car r) (cdr r))) '(256 "erosion: no revision nosuch\n"))
(if (find-program "jj")
    (let ((dir (concat-strings scratch "/jj")))
      (make-directory dir)
      (program-result '("jj" "git" "init" "--colocate" ".") dir)
      (write-in dir "j.l" "(define-function j () 1)\n")
      (program-result '("jj" "describe" "-m" "base") dir) (program-result '("jj" "new") dir)
      (write-in dir "j.l" "(define-function j () 2)\n")
      (expect "jj's change" (map (lambda (c) (<change>-path c)) (vcs-changes dir "@-")) '("j.l")))
  (println "no jj on PATH: its changes not checked"))

(println (if ok "erosion attribution ok" "erosion attribution FAILED"))
