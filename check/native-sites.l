;;; Lowering sites (asm-arm64.l's arm64-site): an instruction whose row is chosen when its rule loads emits its bytes
;;; as asm would, falls back to the symbolic form when an operand isn't of the kind declared or no row takes it, and is
;;; encoded once when nothing in it varies.  With LOADER (as native_nile writes it), the share of the Nile runtime's
;;; and Gezira's lowered forms that sites emitted is printed.  The last line is "native sites ok".
;;;   ./eval2 check/native-sites.l [LOADER]
(define loader (and *arguments* (pop *arguments*)))	; before native.l: maru.k loads any arguments left
(require "native.l")
(define failures 0)
(define-function expect (what got want)
  (or (equal got want) (let () (set failures (+ failures 1)) (println "FAIL " what ": got " got ", want " want))))
(define-function asm-bytes (insn)	; insn's bytes as asm encodes it, or its refusal
  (let* ((b (asm-buffer 0)) (r (asm-attempt 'arm64 b insn)))
    (if (and (pair? r) (= 'error (car r))) r (cons 'data (array->list (asm-buffer-bytes b))))))
(define-function as-asm (form insn)	; a site's answer: insn's bytes, or insn itself to be encoded by asm
  (if (= 'data (car form)) (equal form (asm-bytes insn)) (equal form insn)))

(define-function add3 (d a b) (arm64-site ADD (x d) (x a) (x b)))
(define-function addi (d a v) (arm64-site ADD (x d) (x a) (n v)))
(define-function ret () (arm64-site RET))
(expect "three registers, as asm" (add3 'X9 'X10 'X11) (asm-bytes '(ADD X9 X10 X11)))
(expect "SP where an X register was declared: the symbolic form" (add3 'SP 'X1 'X2) '(ADD SP X1 X2))
(expect "an immediate that fits" (addi 'X9 'X10 16) (asm-bytes '(ADD X9 X10 16)))
(list-do v '(4096 -1 4095 16777216)
  (expect (concat-string "an immediate at the edge " (long->string v)) (and (as-asm (addi 'X9 'X10 v) (list 'ADD 'X9 'X10 v)) 1) 1))
(expect "nothing varies: encoded once" (ret) '(data 192 3 95 214))

(when loader
  (let ((lower (cdr (assq 'arm64 native-lowerings))) (sites 0) (forms 0))
    (list-do f (car (native-symbols (<native-unit>-functions (native-compile-file loader))))
      (list-do fs (lower (cadr f))
	(list-do form fs
	  (or (= 'at (car form)) (let () (set forms (+ forms 1)) (and (= 'data (car form)) (set sites (+ sites 1))))))))
    (println "sites " sites " of " forms " forms")
    (expect "some forms emitted by sites" (and (< 0 sites) 1) 1)))
(or (= 0 failures) (error "native-sites: " failures " failures"))
(println "native sites ok")
