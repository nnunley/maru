;;; Refused (check/native.l): a struct by value whose size isn't a multiple of 4, which the 8- and 4-byte pieces of a
;;; register can't carry.
(define-struct <rgb> ((r char) (g char) (b char)))
(define-function red long ((c struct <rgb>)) (return (cast (. c r) long)))
