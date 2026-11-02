;; dlextern (dlopen.k), as libsdl2.k uses it: a C function by name, through
;; subr in eval2 and through libffi in eval3.

(require "dlopen.k")

(init-dlopen)

(define c-strlen (dlextern "libc" "strlen" "s"))
(define c-labs   (dlextern "libc" "labs"   "i"))

(or (= 5 (c-strlen "hello")) (error "strlen: " (c-strlen "hello")))
(or (= 7 (c-labs -7))        (error "labs: " (c-labs -7)))

(println "dlextern ok")
