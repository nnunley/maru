;;; Code images (draft-ndn-maru-native-ir2-00): the units check/native-image-save.l saved on eval2, loaded with
;;; native-image.l alone and called, on any evaluator.   ./eval check/native-image.l DIR
(define dir (pop *arguments*))
(define-function image-path (name) (concat-string dir (concat-string "/" (concat-string name ".image"))))
(load "native-image.l")
(require "check/native-child.l")
(let ((add (native-load (image-path "add"))) (flow (native-load (image-path "flow"))))
  (let ((fn (lambda (image name signature) (subr (cdr (assq name image)) signature))))
    (expect "add3 of 1, 2, 3" ((fn add 'add3 "lll>l") 1 2 3) 6)
    (expect "add3 of large and negative" ((fn add 'add3 "lll>l") 4000000000 -1 -2) 3999999997)
    (expect "neg of 5" ((fn add 'neg "l>l") 5) -5)
    (expect "gcd of 1071 and 462" ((fn flow 'gcd "ll>l") 1071 462) 21)
    (expect "sum below 100" ((fn flow 'sum-below "l>l") 100) 4950)
    (expect "every relation, signed" (map (lambda (ab) ((fn flow 'relations "ll>l") (car ab) (cadr ab))) '((-3 2) (2 -3) (7 7)))
	    '(35 44 26))))
(let ((image (native-load (image-path "image"))))
  (expect "a global, a C function and a string, through the table"
	  (list ((subr (cdr (assq 'greet image)) ">l")) ((subr (cdr (assq 'greet image)) ">l"))) '(46 47)))
;; an image made for another instruction set or system is refused before anything is installed
(let ((image (car (read (image-path "add")))))
  (list-do other (list (list (if (= 'arm64 (cadr image)) 'x64 'arm64) (caddr image))
		       (list (cadr image) (if (= 'darwin (caddr image)) 'linux 'darwin)))
    (refuses "an image for another machine"
	     (lambda () (native-load-image (cons 'native-image (concat-list other (cdddr image)))))
	     "can't run on")))
;; the host is known by uname's whole names, and no other machine or system is taken for one
(expect "the hosts' names" (list (native-host-of "arm64" "Darwin") (native-host-of "aarch64" "Linux") (native-host-of "x86_64" "Linux"))
	'((arm64 . darwin) (arm64 . linux) (x64 . linux)))
(refuses "another machine" (lambda () (native-host-of "armv7l" "Linux")) "no code for the machine armv7l")
(refuses "another system" (lambda () (native-host-of "arm64" "FreeBSD")) "no code for the system FreeBSD")
(println (if ok "image ok" "image FAILED"))
