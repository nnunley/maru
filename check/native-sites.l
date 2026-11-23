;;; Lowering sites (asm-arm64.l's arm64-site): an instruction whose row is chosen when its rule loads emits its bytes
;;; as asm would, falls back to the symbolic form when an operand isn't of the kind declared or no row takes it, and is
;;; encoded once when nothing in it varies.  The share of maru-check.k's forms that sites emit (or with LOADER, as
;;; native_nile writes it, the Nile runtime's and Gezira's) is printed.  The last line is "native sites ok".
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

(define-function add3 (d a b) (car (arm64-sites `((ADD (x ,d) (x ,a) (x ,b))))))
(define-function addi (d a v) (car (arm64-sites `((ADD (x ,d) (x ,a) (n ,v))))))
(define-function ret () (car (arm64-sites `((RET)))))
(expect "three registers, as asm" (add3 'X9 'X10 'X11) (asm-bytes '(ADD X9 X10 X11)))
(expect "SP where an X register was declared: the symbolic form" (add3 'SP 'X1 'X2) '(ADD SP X1 X2))
(expect "an immediate that fits" (addi 'X9 'X10 16) (asm-bytes '(ADD X9 X10 16)))
(list-do v '(4096 -1 4095 16777216)
  (expect (concat-string "an immediate at the edge " (long->string v)) (and (as-asm (addi 'X9 'X10 v) (list 'ADD 'X9 'X10 v)) 1) 1))
(expect "nothing varies: encoded once" (ret) '(data 192 3 95 214))

;; label sites: the row asm-select chooses for the instruction with (reloc) at the label, its bytes and report, as
;; (label-data BYTES POSITION ROW INSN L), chosen from the grammar's open rule when the template loads
(define-function asm-label-data (insn l)	; what asm-select gives the instruction, as a label site answers it
  (let ((found (asm-select 'arm64 insn 0 (asm-candidate-rows 'arm64 insn))))
    (list 'label-data (cadr found) (car (cddr found)) (car found) insn l)))
(define-function cbz (r l) (car (arm64-sites `((CBZ (x ,r) (label ,l))))))
(define-function b (l) (car (arm64-sites `((B (label ,l))))))
(define-function adr (r l) (car (arm64-sites `((ADR (x ,r) (label ,l))))))
(expect "a CBZ to a label" (cbz 'X9 'L1) (asm-label-data '(CBZ X9 (reloc)) 'L1))
(expect "a B to a label" (b 'L2) (asm-label-data '(B (reloc)) 'L2))
(expect "an ADR of a label" (adr 'X17 'L3) (asm-label-data '(ADR X17 (reloc)) 'L3))
(expect "SP where a CBZ's X register was declared: the symbolic form" (cbz 'SP 'L1) '(CBZ SP (label L1)))

(require "recover.l")
(define-function refused? (thunk) (try (let () (thunk) ()) (lambda (c) 't)))
;; a number where a row takes a PC-relative offset: a site encodes as it loads, not at its address, so the template is
;; refused (a label, (label ,l), is how a branch names its target)
(expect "a literal branch offset refused" (refused? (lambda () (arm64-insn-code '(CBZ (x (unquote r)) 8)))) 't)
(expect "a number hole in a branch's offset refused" (refused? (lambda () (arm64-insn-code '(B (n (unquote v)))))) 't)
;; the grammar's rules as data name their rows by index: a rule that doesn't fit its row (the data older than
;; arm64.spec) is refused, not followed to another row's encoding
(expect "a rule naming another mnemonic's row refused"
	(refused? (lambda () (arm64-row-rule-parts '(match-all (match-list (match-all (match-object NOSUCH)))
							       (result-expr (arm64-row-result 0 (list)))))))
	't)
;; union kinds: (f ,r) a D or S register, (r ,r) an X or W one; each row tests its own, so either width finds its row
(define-function fmov-in (f r) (car (arm64-sites `((FMOV (f ,f) (r ,r))))))
(define-function fadd (d a b) (car (arm64-sites `((FADD (f ,d) (f ,a) (f ,b))))))
(expect "FMOV from X to D" (fmov-in 'D16 'X9) (asm-bytes '(FMOV D16 X9)))
(expect "FMOV from W to S" (fmov-in 'S16 'W9) (asm-bytes '(FMOV S16 W9)))
(expect "FADD of D registers" (fadd 'D16 'D16 'D17) (asm-bytes '(FADD D16 D16 D17)))
(expect "FADD of S registers" (fadd 'S16 'S16 'S17) (asm-bytes '(FADD S16 S16 S17)))
(expect "FMOV of S and X: the symbolic form" (fmov-in 'S16 'X9) '(FMOV S16 X9))
;; a memory hole without a shape: one site for SP's base and another register's
(define-function ldr (r p) (car (arm64-sites `((LDR (x ,r) (mem ,p))))))
(expect "a load from SP" (ldr 'X9 '(off SP 16)) (asm-bytes '(LDR X9 (off SP 16))))
(expect "a load through X10" (ldr 'X9 '(off X10 8)) (asm-bytes '(LDR X9 (off X10 8))))
(expect "a negative offset no LDR row takes: the symbolic form" (ldr 'X9 '(off X10 -8)) '(LDR X9 (off X10 -8)))
(expect "ZR as a base: the symbolic form" (ldr 'X9 '(off XZR 8)) '(LDR X9 (off XZR 8)))
;; loads and stores: near, through another register, unaligned or far (the address made in X15 first); each form, as a
;; site emits it or as asm encodes it, gives the same bytes as the forms the access means
(define-function encoded (forms) (map (lambda (f) (if (= 'data (car f)) f (asm-bytes f))) forms))
(set native-arm64-frame 40000)
(expect "a near load" (encoded (native-arm64-load 8 'X9 'SP 16)) (encoded '((LDR X9 (off SP 16)))))
(expect "a load through a register" (encoded (native-arm64-load 4 'X9 'X10 8)) (encoded '((LDRSW X9 (off X10 8)))))
(expect "a byte store" (encoded (native-arm64-store 1 'X9 'SP 3)) (encoded '((STRB W9 (off SP 3)))))
(expect "an unaligned load" (encoded (native-arm64-load 8 'X9 'SP 12)) (encoded '((ADD X15 SP 12) (LDR X9 (off X15 0)))))
(expect "a far load" (encoded (native-arm64-load 8 'X9 'SP 32768))
	(encoded (concat-list (arm64-constant 'X15 (- 32768 40000)) '((ADD X15 X29 X15) (LDR X9 (off X15 0))))))
(expect "a far address" (encoded (native-arm64-address 5000 'X9))
	(encoded (concat-list (arm64-constant 'X9 (- 5000 40000)) '((ADD X9 X29 X9)))))

;; every form comes from a site, a label's (branches, ADR) from a label site: of LOADER's forms, else maru-check.k's
(let ((lower (cdr (assq 'arm64 native-lowerings))) (sites 0) (forms 0) (others ()))
  (list-do f (car (native-symbols (<native-unit>-functions (native-compile-file (or loader "maru-check.k")))))
    (list-do fs (lower (cadr f))
      (list-do form fs
	(unless (= 'at (car form))
	  (set forms (+ forms 1))
	  (if (memq (car form) '(data label-data)) (set sites (+ sites 1)) (push others form))))))
  (println "sites " sites " of " forms " forms")
  (expect "every form from a site" others ()))
(or (= 0 failures) (error "native-sites: " failures " failures"))
(println "native sites ok")
