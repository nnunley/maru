;;; Erosion attribution (doc/rfc/draft-ndn-erosion-attribution-00.md): one grammar, diff.g, reads a change and jj's
;;; conflicts; the fixtures in check/erosion-attribution/ are git's and jj's own output.
(require "erosion-attribute.l")
(require "recover.l")
(define ok 1)
(define-function expect (what got want)
  (or (equal got want) (let () (set ok ()) (println "FAIL " what ": got " got ", want " want))))
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

(println (if ok "erosion attribution ok" "erosion attribution FAILED"))
