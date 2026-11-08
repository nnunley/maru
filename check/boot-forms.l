;;; The class and dispatch forms boot.l and boot2.l share, on every evaluator: a structure, a class extending its base's
;;; fields, make with keyword pairs (Piumarta 2013), a method reading fields as self.x, and a selector inheriting
;;; through the bases.
(define ok 1)
(define-function expect (what got want)
  (or (= got want) (let () (set ok ()) (println "FAIL " what ": got " got ", want " want))))
(define-structure <shape> (name))
(define-class <circle> <shape> (radius))
(define-selector describe)
(define-method describe <shape> () self.name)
(define-method area <circle> () (* (* self.radius self.radius) 3))
(let ((c (make <circle> name: 'disc radius: 2)))
  (expect "make with keyword pairs sets each field" (<circle>-radius c) 2)
  (expect "a class extends its base's fields" (<shape>-name c) 'disc)
  (expect "a method reads its fields as self.x" (area c) 12)
  (expect "a selector inherits through the bases" (describe c) 'disc))
(println (if ok "boot forms ok" "boot forms FAILED"))
