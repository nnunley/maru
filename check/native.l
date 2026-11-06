;;; Typed Maru to native code in-process (draft-ndn-maru-native-ir2-00): each unit compiled by native.l, installed in a
;;; code region, and its functions called by address through subr.  Runs on eval2, which runs maru.k.
(require "native.l")
(define ok 1)
(define-function expect (what got want)
  (or (equal got want) (let () (set ok ()) (println "FAIL " what ": got " got ", want " want))))
(define-function fn (image name signature) (subr (cdr (assq name image)) signature))

(let ((image (native-install (native-compile-file "check/native/add.k"))))
  (expect "add3 of 1, 2, 3" ((fn image 'add3 "lll>l") 1 2 3) 6)
  (expect "add3 of large and negative" ((fn image 'add3 "lll>l") 4000000000 -1 -2) 3999999997)
  (expect "neg of 5" ((fn image 'neg "l>l") 5) -5))

(println (if ok "native ok" "native FAILED"))
