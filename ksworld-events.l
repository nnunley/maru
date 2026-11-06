;;; ksworld-events.l -- the pointer in a running KSWorld document: (ksworld-session run) continues what ksworld-run left,
;;; and (ksworld-pointer session kind point) delivers a press, a motion or a release at a point in the document, as an
;;; event in the stream KSWorld's boxes listen to (buttonDown, pointerMotion, buttonUp), then runs one tick so the streams
;;; that read it fire.  A press goes to the topmost box under the point that has a buttonDown; a motion or a release to the
;;; box the hand holds, if its stream isn't dormant.  An event's position is in its box's own coordinates.
;;; KSTextLayout's handlers were Squeak methods in an image that didn't survive, so these are ours: a press puts the caret
;;; at the nearest gap and wakes the drag (the inverse of the documents' own buttonUp, which puts it back to sleep), a
;;; motion extends the selection from where the press landed, and installSelection answers where it shows.  A selection
;;; is an Interval of gaps, (from to: to + 1), as every one the documents kept is one wide.
(require "ksworld-render.l")

(define-structure <ks-hand> (focus))
(define-structure <ks-event> (position hand))
(define-method ks-kind <ks-hand> () 'Hand)
(define-method ks-kind <ks-event> () 'Event)
(ks-methods Hand (focus (set (<ks-hand>-focus recv) (car args)) (car args)))
(ks-methods Event (hand (<ks-event>-hand recv)) (position (<ks-event>-position recv)))

(define-function ks-apply-matrix (m p)
  (ks-point (+ (+ (* (<ks-matrix>-a m) (<ks-point>-x p)) (* (<ks-matrix>-c m) (<ks-point>-y p))) (<ks-matrix>-e m))
	    (+ (+ (* (<ks-matrix>-b m) (<ks-point>-x p)) (* (<ks-matrix>-d m) (<ks-point>-y p))) (<ks-matrix>-f m))))

;; every visible box in drawing order, with the matrix from it to the document
(define-function ks-boxes (box m out)
  (when (and (ks-object? box) (not (= 'false (ks-val box 'visible))))
    (let ((here (ks-compose m (ks-matrix-of (ks-val box 'transformation)))))
      (set-car out (cons (cons box here) (car out)))
      (list-do part '(backgroundParts contents parts)
	(list-do child (ks-items (ks-val box part)) (ks-boxes child here out))))))
(define-function ks-boxes-in (root) (let ((out (list ()))) (ks-boxes root ks-identity out) (list-reverse! (car out))))

(define-function ks-inside? (box p)
  (let ((extent (ks-val box 'extent)))
    (and (ks-point? extent)
	 (<= 0 (<ks-point>-x p)) (< (<ks-point>-x p) (<ks-point>-x extent))
	 (<= 0 (<ks-point>-y p)) (< (<ks-point>-y p) (<ks-point>-y extent)))))

;; the topmost box under a document point that listens for presses
(define-function ksworld-box-at (root point)
  (let ((found ()))
    (list-do bm (ks-boxes-in root)
      (and (ks-stream? (ks-slot (car bm) 'buttonDown)) (ks-inside? (car bm) (ks-apply-matrix (ks-invert (cdr bm)) point))
	   (set found (car bm))))
    found))
(define-function ks-local-point (root box point)
  (let ((found ()))
    (list-do bm (ks-boxes-in root) (and (= box (car bm)) (set found (ks-apply-matrix (ks-invert (cdr bm)) point))))
    found))

(define-function ks-fire (stream value)
  (ks-set-slot stream '__currentValue__ value)
  (ks-set-slot stream '__firedAt__ *ks-logical-time*))
(define-function ks-awake? (stream) (and (ks-stream? stream) (not (= (ks-attr stream ':__dormant__) "true"))))

(define-structure <ksworld-session> (root evaluator time hand))
;; the time after an event's: a whole tick on, headless; in a window, whose time is its clock's milliseconds, 1/1024 of
;; the way to the next millisecond (*ks-event-limit*, ksworld-window.l), so events keep their order and never reach it,
;; however many there are
(define *ks-event-limit* ())
(define-function ks-time-after-event (t)
  (if *ks-event-limit* (+ t (/ (- *ks-event-limit* t) 1024.0)) (+ t 1)))
(define-function ksworld-session (run)
  (new <ksworld-session> (cdr (assq 'root run)) (cdr (assq 'evaluator run)) (cdr (assq 'time run)) (new <ks-hand> 'nil)))

;; kind is down, move or up; answers the box the event went to, or ()
(define-function ksworld-pointer (session kind point)
  (let* ((root (<ksworld-session>-root session)) (hand (<ksworld-session>-hand session))
	 (held (and (ks-object? (<ks-hand>-focus hand)) (<ks-hand>-focus hand)))
	 (box (if (= kind 'down) (ksworld-box-at root point) held))
	 (stream (and box (ks-slot box (cdr (assq kind '((down . buttonDown) (move . pointerMotion) (up . buttonUp))))))))
    (when (ks-awake? stream)
      (set *ks-logical-time* (<ksworld-session>-time session))
      (ks-fire stream (new <ks-event> (ks-local-point root box point) hand))
      (ks-sort-and-evaluate-at (<ksworld-session>-evaluator session) *ks-logical-time*)
      (set (<ksworld-session>-time session) (ks-time-after-event *ks-logical-time*))
      box)))

;; a text layout's selection, from gap to gap
(define-function ks-select (layout from to)
  (ks-fire (ks-slot layout 'selection)
	   (new <ks-object> 'Interval 0 () (list (cons 'start from) (cons 'stop (+ to 1)) (cons 'step 1)) () 0)))
(define-function ks-selection-gaps (layout)
  (let ((i (ks-val layout 'selection))) (cons (ks-slot i 'start) (- (ks-slot i 'stop) 1))))

(ks-methods KSTextLayout
  (handleButtonDown
   (let ((ev (car args)) (box (ks-slot recv 'whole)))
     (if (not (= <ks-event> (type-of ev)))
	 'undefined
       (let ((gap (ks-text-gap box (<ks-event>-position ev))))
	 (ks-set-slot recv 'selectionAnchor gap)
	 (ks-select recv gap gap)
	 (list-do s '(buttonUp pointerMotion)
	   (set (<ks-object>-attrs (ks-slot box s)) (cons ':__dormant__ (cons "false" (<ks-object>-attrs (ks-slot box s))))))
	 (set (<ks-hand>-focus (<ks-event>-hand ev)) box)
	 (ks-fire (ks-slot box 'showSelection) 'true)
	 gap))))
  (handlePointerMotion
   (let ((ev (car args)) (box (ks-slot recv 'whole)))
     (if (not (= <ks-event> (type-of ev)))
	 'undefined
       (let ((gap (ks-text-gap box (<ks-event>-position ev))) (anchor (ks-slot recv 'selectionAnchor)))
	 (ks-select recv (min anchor gap) (max anchor gap))
	 gap))))
  (installSelection
   (let ((gaps (ks-selection-gaps recv)))
     (ks-text-selection-rects (ks-slot recv 'whole) (car gaps) (cdr gaps)))))
