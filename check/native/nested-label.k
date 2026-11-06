;;; Refused (check/native.l): a label that is an if's branch, which ir2 never declares (only the top-level labels of a
;;; function's or a let's body are), so no goto can reach it.
(define-function count-up long ((n long))
  (if (> n 0) (label again))
  (return n))
