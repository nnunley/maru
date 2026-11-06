;;; A frame over 4096 bytes compiled natively (check/native.l, which defines struct <wide>, 600 longs, before this): so
;;; the frame is made from X29 and slots past a load's reach are found through X15, with a call made from it and a
;;; struct copied from one far slot to another.  (ir2 can't lay out a struct inside another, or <wide> would be built so.)
(define-function twice long ((n long)) (return (* 2 n)))
(define-function far-frame long ((n long))
  (let (((big struct <wide>)) ((x long) n) ((y int) 3))
    (set (. big f599) (+ n 1))
    (set (. big f0) 2)
    (let (((copy struct <wide>) big))
      (return (+ (+ x (cast y long)) (+ (. copy f599) (+ (. big f0) (twice n))))))))
