;;; The pointer in KSWorld.ks (ksworld-events.l): a press lands on the text box under it and puts the caret at the nearest
;;; gap, a drag selects from there, the redraw asks a Gezira for the selection in the layout's colour under the text, and a
;;; release puts the drag back to sleep, as the document's own buttonUp says.  Needs the dbjr documents (MARU_DBJR).
(require "ksworld-run.l")
(require "check/temp.l")
(define dir (env-var "MARU_DBJR"))
(define ok 1)
(define-function expect (what got want)
  (or (equal got want) (let () (set ok ()) (println "FAIL " what ": got " got ", want " want))))
(define-function near (a b) (let ((d (- a b))) (< (* d d) 0.00000001)))

;; a Gezira that keeps each path's paint and first point
(define-structure <gezira-points> (paths))
(define-method gezira-fill-path <gezira-points> (m width height paint floats count)
  (let ((p (ks-apply-matrix m (ks-point (float-at floats 0) (float-at floats 1)))))
    (push self.paths (list paint (<ks-point>-x p) (<ks-point>-y p)))))

(if (not dir)
    (println "KSWorld.ks's pointer: skipped, MARU_DBJR names no dbjr documents")
  (set *ks-font-path* (cons (concat-string dir "/fonts") *ks-font-path*))
  (let* ((r (ksworld-run (concat-string dir "/KSWorld.ks/index.pp") 3))
	 (s (ksworld-session r))
	 (box (array-at (cdr (assq 'table r)) 204))	; "Viewpoints Research Institute", centred
	 (layout (ks-slot box 'handler))
	 (m (let ((f ())) (list-do bm (ks-boxes-in (<ksworld-session>-root s)) (and (= box (car bm)) (set f (cdr bm)))) f))
	 (at (lambda (x y) (ks-apply-matrix m (ks-point x y)))))
    (expect "every method the document names is answered" (cdr (assq 'failures r)) ())
    (expect "a press where no box listens goes nowhere" (ksworld-pointer s 'down (ks-point -50 -50)) ())
    (expect "a press lands on the box under it" (ksworld-pointer s 'down (at 200 13)) box)
    (expect "the caret at the nearest gap, shown, the drag awake and the hand holding the box"
	    (list (ks-selection-gaps layout) (ks-val box 'showSelection) (ks-awake? (ks-slot box 'buttonUp))
		  (ks-awake? (ks-slot box 'pointerMotion)) (<ks-hand>-focus (<ksworld-session>-hand s)))
	    (list '(5 . 5) 'true 't 't box))
    (expect "a drag goes to the box the hand holds" (ksworld-pointer s 'move (at 300 13)) box)
    (expect "and selects from the press" (ks-selection-gaps layout) '(5 . 18))
    (let ((g (new <gezira-points> ())) (c (ks-slot layout 'selectionColor)) (corner (at 199.634033 2)) (found ()))
      (ksworld-render (<ksworld-session>-root s) g 1024 768)
      (list-do p (<gezira-points>-paths g)
	(and (equal (car p) (list 'uniform (<ks-color>-a c) (<ks-color>-r c) (<ks-color>-g c) (<ks-color>-b c)))
	     (near (cadr p) (<ks-point>-x corner)) (near (caddr p) (<ks-point>-y corner))
	     (set found 1)))
      (expect "the redraw shows the selection, in the layout's colour" found 1))
    (ksworld-pointer s 'up (at 300 13))
    (expect "a release puts the drag to sleep and the hand lets go"
	    (list (ks-awake? (ks-slot box 'buttonUp)) (ks-awake? (ks-slot box 'pointerMotion)) (<ks-hand>-focus (<ksworld-session>-hand s)))
	    '(() () nil))
    (expect "so a motion after it goes nowhere" (ksworld-pointer s 'move (at 100 13)) ())))

(println (if ok "ksworld mouse ok" "ksworld mouse FAILED"))
