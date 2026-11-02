;;; text-parser.k -- the typed runtime for code tpeg generates (compile-tpeg.l's value-pe),
;;; once irl-grammar.l has lowered it for an irl grammar block (draft-ndn-maru-sat-00
;;; [R-irl-grammar]).  A grammar's struct begins string, limit, position, result, span, as
;;; text-parser.l's <text-parser> begins string, limit, position; a span is its start in
;;; result and its end in span, since typed Maru has no lists.

(define-function tp_match_at (long) ((s char *) (pos long) (limit long) (lit char *) (n long))
  (let (((i long) 0) ((ok long) 1))
    (while (and ok (< i n))
      (if (or (>= (+ pos i) limit) (!= (cast (indir s (+ pos i)) long) (cast (indir lit i) long))) (set ok 0))
      (set i (+ i 1)))
    (return ok)))

(define-function tp_in_class (long) ((cls char *) (c long))	; cls lists each character
  (let (((i long) 0) ((in long) 0))
    (while (and (not in) (!= (cast (indir cls i) long) 0))
      (if (= (cast (indir cls i) long) c) (set in 1))
      (set i (+ i 1)))
    (return in)))

(define-function tp_number (long) ((s char *) (i long) (end long) (base long))	; a leading - negates
  (let (((v long) 0) ((neg long) 0) ((c long) 0))
    (if (and (< i end) (= (cast (indir s i) long) 45)) (let () (set neg 1) (set i (+ i 1))))
    (while (< i end)
      (set c (cast (indir s i) long))
      (set v (+ (* v base) (if (<= c 57) (- c 48) (- (| c 32) 87))))
      (set i (+ i 1)))
    (return (if neg (- 0 v) v))))

(define-form tp-char (self) `(cast (indir (member ,self string) (member ,self position)) long))
(define-form tp-advance (self n) `(let () (set-member ,self position (+ (member ,self position) ,n)) 1))
(define-form tp-match-char (self c)
  `(if (and (< (member ,self position) (member ,self limit)) (= (tp-char ,self) ,c)) (tp-advance ,self 1) 0))
(define-form tp-match-any (self) `(if (< (member ,self position) (member ,self limit)) (tp-advance ,self 1) 0))
(define-form tp-match-string (self s n)
  `(if (!= (tp_match_at (member ,self string) (member ,self position) (member ,self limit) ,s ,n) 0) (tp-advance ,self ,n) 0))
(define-form tp-match-class (self cls)
  `(if (and (< (member ,self position) (member ,self limit)) (!= (tp_in_class ,cls (tp-char ,self)) 0)) (tp-advance ,self 1) 0))
(define-form tp-span (self start end) `(let () (set-member ,self span ,end) ,start))
(define-form tp-number (self start base) `(tp_number (member ,self string) ,start (member ,self span) ,base))
(define-form tp-nothing (self) `(set-member ,self span (member ,self span)))	; list building, typed: no list, and no warning
