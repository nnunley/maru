;;; native.l -- typed Maru to native code in this process (draft-ndn-maru-native-ir2-00).  On eval2, which runs maru.k:
;;;   (native-compile-file path)   => a unit: the file's typed definitions as intents
;;;   (native-install unit)        => ((name . address) …)
(require "osdefs.k")
(require "asm-table.l")
(require "asm-arm64.l")
(require "asm-x86.l")
(require "code-region.l")
(require "native-image.l")
(require "stub.l")
(require "native-gen.k")
(load "maru.k")		; no arguments left: definitions only
;; for native-arm64.g's actions.  X29 holds SP as it was before the frame, so leaving sets SP from it, a frame larger
;; than an immediate reaches is made from it, and a slot a load's scaled offset doesn't reach (too far, or not a multiple
;; of the access's size) has its address made in X15 (in neither abi.spec's scratch nor the calls' X17)
(define native-arm64-frame 0)	; the size of the frame being lowered
(define native-outgoing 0)	; and of the area at its bottom for calls' stack arguments
;; a call's stack arguments, out bytes, fit the area the generator reserved
(define-function native-within-outgoing (out)
  (or (<= out native-outgoing) (error "native: a call's " out " bytes of stack arguments overrun the frame's " native-outgoing)))
(define-function native-arm64-enter (n outgoing)
  (set native-arm64-frame n)
  (set native-outgoing outgoing)
  (concat-list (arm64-sites `((STP X29 X30 (pre SP -16)) (ADD X29 SP 0)))
	       (cond ((= 0 n) ())
		     ((< n 4096) (arm64-sites `((SUB SP SP (n ,n)))))
		     (else (concat-list (arm64-constant 'X15 n) (arm64-sites `((SUB X15 X29 X15) (ADD SP X15 0))))))))
(define-function native-arm64-far? (size at) (or (> at (* 4095 size)) (!= 0 (% at size))))
(define-function native-arm64-w (r)	; X9 to W9
  (let ((name (symbol->string r))) (string->symbol (concat-string "W" (string-copy name 1 (- (string-length name) 1))))))
(define-function native-arm64-address (slot r)
  (if (< slot 4096)
      (arm64-sites `((ADD (x ,r) SP (n ,slot))))
    (concat-list (arm64-constant r (- slot native-arm64-frame)) (arm64-sites `((ADD (x ,r) X29 (x ,r)))))))
(define-function native-arm64-access (size base at forms)	; an access's forms, its place reached first if far
  (if (and (= base 'SP) (native-arm64-far? size at))
      (concat-list (native-arm64-address at 'X15) (forms '(off X15 0)))
    (forms (list 'off base at))))
(define-function native-arm64-load (size r base at)	; sign-extending: ir2's integers are signed
  (native-arm64-access size base at
    (lambda (place)
      (cond ((= size 8) (arm64-sites `((LDR (x ,r) (mem ,place)))))
	    ((= size 4) (arm64-sites `((LDRSW (x ,r) (mem ,place)))))
	    ((= size 2) (arm64-sites `((LDRSH (x ,r) (mem ,place)))))
	    ((= size 1) (arm64-sites `((LDRSB (x ,r) (mem ,place)))))
	    (else (error "native: no load of " size " bytes"))))))
(define-function native-arm64-store (size r base at)
  (native-arm64-access size base at
    (lambda (place)
      (cond ((= size 8) (arm64-sites `((STR (x ,r) (mem ,place)))))
	    ((= size 4) (arm64-sites `((STR (w ,(native-arm64-w r)) (mem ,place)))))
	    ((= size 2) (arm64-sites `((STRH (w ,(native-arm64-w r)) (mem ,place)))))
	    ((= size 1) (arm64-sites `((STRB (w ,(native-arm64-w r)) (mem ,place)))))
	    (else (error "native: no store of " size " bytes"))))))
;; floating point: values stay as bits in slots and integer registers, and visit abi.spec's fscratch registers (D16, or
;; its 32-bit view S16) to be operated on; arguments and results use fargs and fresult
(define-function native-arm64-view (r width)	; D16 at 64 bits, S16 at 32; X9 at 64, W9 at 32
  (let ((name (symbol->string r)))
    (if (= 64 width)
	r
      (string->symbol (concat-string (if (= ?D (string-at name 0)) "S" "W") (string-copy name 1 (- (string-length name) 1)))))))
(define-function native-nth (l k) (if (= 0 k) (car l) (native-nth (cdr l) (- k 1))))
(define-function native-arm64-f (k width) (native-arm64-view (native-nth (abi 'arm64 'fscratch) k) width))
(define-function native-arm64-farg (n width) (native-arm64-view (native-nth (abi 'arm64 'fargs) n) width))
;; float forms: (f ,r) a D or S register and (r ,r) an X or W one (asm-arm64.l's union kinds), the registers in the
;; view width takes, so one template serves both widths
(define-function native-arm64-fmov-in (width f r) (arm64-sites `((FMOV (f ,f) (r ,(native-arm64-view r width))))))
(define-function native-arm64-fmov-out (width r f) (arm64-sites `((FMOV (r ,(native-arm64-view r width)) (f ,f)))))
(define-function native-arm64-fop (kind width d a b)
  (let ((f0 (native-arm64-f 0 width)) (f1 (native-arm64-f 1 width))
	(a (native-arm64-view a width)) (b (native-arm64-view b width)) (d (native-arm64-view d width)))
    (cond ((= kind 'neg) (arm64-sites `((FMOV (f ,f0) (r ,a)) (FNEG (f ,f0) (f ,f0)) (FMOV (r ,d) (f ,f0)))))
	  ((= kind 'add) (arm64-sites `((FMOV (f ,f0) (r ,a)) (FMOV (f ,f1) (r ,b)) (FADD (f ,f0) (f ,f0) (f ,f1)) (FMOV (r ,d) (f ,f0)))))
	  ((= kind 'sub) (arm64-sites `((FMOV (f ,f0) (r ,a)) (FMOV (f ,f1) (r ,b)) (FSUB (f ,f0) (f ,f0) (f ,f1)) (FMOV (r ,d) (f ,f0)))))
	  ((= kind 'mul) (arm64-sites `((FMOV (f ,f0) (r ,a)) (FMOV (f ,f1) (r ,b)) (FMUL (f ,f0) (f ,f0) (f ,f1)) (FMOV (r ,d) (f ,f0)))))
	  ((= kind 'div) (arm64-sites `((FMOV (f ,f0) (r ,a)) (FMOV (f ,f1) (r ,b)) (FDIV (f ,f0) (f ,f0) (f ,f1)) (FMOV (r ,d) (f ,f0)))))
	  (else (error "native: no float operation " kind)))))
(define-function native-arm64-fcompare (c width d a b)	; FCMP's flags: less than is MI, at most LS (false if unordered)
  (let ((f0 (native-arm64-f 0 width)) (f1 (native-arm64-f 1 width)) (a (native-arm64-view a width)) (b (native-arm64-view b width)))
    (arm64-sites `((FMOV (f ,f0) (r ,a)) (FMOV (f ,f1) (r ,b)) (FCMP (f ,f0) (f ,f1))
		   (CSET (x ,d) (c ,(cdr (assq c '((eq . EQ) (ne . NE) (lt . MI) (le . LS) (gt . GT) (ge . GE))))))))))
(define-function native-arm64-convert (from to d s)	; s64, f32 or f64 to another
  (let ((width (lambda (k) (if (= k 'f32) 32 64))))
    (cond ((= from 's64)
	   (let ((w (width to)) (f (native-arm64-f 0 (width to))))
	     (concat-list (arm64-sites `((SCVTF (f ,f) (x ,s)))) (native-arm64-fmov-out w d f))))
	  ((= to 's64)
	   (let ((w (width from)) (f (native-arm64-f 0 (width from))))
	     (concat-list (native-arm64-fmov-in w f s) (arm64-sites `((FCVTZS (x ,d) (f ,f)))))))
	  (else
	   (let ((fw (width from)) (tw (width to)) (ff (native-arm64-f 0 (width from))) (tf (native-arm64-f 0 (width to))))
	     (concat-list (native-arm64-fmov-in fw ff s)
			  (concat-list (arm64-sites `((FCVT (f ,tf) (f ,ff)))) (native-arm64-fmov-out tw d tf))))))))
;; the calling convention: AAPCS64, with Apple's rules on Darwin (a stack argument at its natural alignment, a variadic
;; one in an 8-byte stack slot).  A struct goes in general registers, in 8- and 4-byte pieces: C's rule only for one of
;; integers and pointers, at most 16 bytes, its size a multiple of 4, and native-gen.k refuses any other by value
(define native-darwin (= 'darwin (cdr native-host)))
(define-function native-x (n) (string->symbol (concat-string "X" (long->string n))))
(define-function native-function-label (name) (string->symbol (concat-string "fn." (symbol->string name))))
(define-function native-pieces (size)	; (offset . bytes) …
  (let ((out ()) (at 0))
    (while (< at size)
      (let ((n (cond ((>= (- size at) 8) 8) ((>= (- size at) 4) 4) (else (error "native: a struct of " size " bytes isn't 4-byte pieces")))))
	(push out (cons at n)) (set at (+ at n))))
    (list-reverse! out)))
;; a struct result's pieces: two registers' worth at most, as the generator refuses a larger one
(define-function native-result-pieces (size)
  (let ((pieces (native-pieces size)))
    (if (< 2 (list-length pieces)) (error "native: a struct result of " size " bytes is more than two registers") pieces)))
(define-function native-arm64-piece (op n r base at)	; a plain (zero-extending) load or store of 8 or 4 bytes
  (native-arm64-access n base at
    (lambda (place)
      (cond ((and (= op 'LDR) (= n 8))	(arm64-sites `((LDR (x ,r) (mem ,place)))))
	    ((= op 'LDR)		(arm64-sites `((LDR (w ,(native-arm64-w r)) (mem ,place)))))
	    ((= n 8)			(arm64-sites `((STR (x ,r) (mem ,place)))))
	    (else			(arm64-sites `((STR (w ,(native-arm64-w r)) (mem ,place)))))))))
(define-function native-onto (acc forms) (list-do f forms (set acc (cons f acc))) acc)	; pushed in order
(define-function native-flatten (ll) (let ((out ())) (list-do l ll (list-do x l (push out x))) (list-reverse! out)))
(define-function native-arm64-copy (size from to)
  (native-flatten (map (lambda (p) (concat-list (native-arm64-piece 'LDR (cdr p) 'X17 'SP (+ from (car p)))
						(native-arm64-piece 'STR (cdr p) 'X17 'SP (+ to (car p)))))
		       (native-pieces size))))
(define-function native-stack-align (off size variadic)
  (if (or variadic (not native-darwin)) (align off 8) (align off (min size 8))))
(define-function native-arm64-params (ps)
  (let ((gp 0) (fp 0) (stack 0) (out ()))
    (list-do p ps
      (let ((size (car p)) (slot (cadr p)) (kind (caddr p)))
	(if (= kind 'struct)
	    (let ((pieces (native-pieces size)))
	      (if (<= (+ gp (list-length pieces)) 8)
		  (list-do pc pieces (set out (native-onto out (native-arm64-piece 'STR (cdr pc) (native-x gp) 'SP (+ slot (car pc))))) (set gp (+ gp 1)))
		(set gp 8)
		(set stack (align stack 8))
		(list-do pc pieces
		  (set out (native-onto out (native-arm64-piece 'LDR (cdr pc) 'X17 'X29 (+ 16 (+ stack (car pc))))))
		  (set out (native-onto out (native-arm64-piece 'STR (cdr pc) 'X17 'SP (+ slot (car pc))))))
		(set stack (+ stack (align size 8)))))
	  (cond
	    ((and (= kind 'float) (< fp 8))
	     (set out (native-onto out (native-arm64-fmov-out (* 8 size) 'X17 (native-arm64-farg fp (* 8 size)))))
	     (set out (native-onto out (native-arm64-store size 'X17 'SP slot)))
	     (set fp (+ fp 1)))
	    ((and (not (= kind 'float)) (< gp 8))
	     (set out (native-onto out (native-arm64-store size (native-x gp) 'SP slot))) (set gp (+ gp 1)))
	    (else
	    (set stack (native-stack-align stack size ()))
	    (set out (native-onto out (native-arm64-load size 'X17 'X29 (+ 16 stack))))
	    (set out (native-onto out (native-arm64-store size 'X17 'SP slot)))
	    (set stack (+ stack (if native-darwin size 8))))))))
    (list-reverse! out)))
(define-function native-arm64-call (callee nfixed args ret)
  (let ((gp 0) (fp 0) (out 0) (forms ()) (i 0))
    (list-do a args
      (let* ((size (car a)) (slot (cadr a)) (kind (caddr a)) (variadic (and native-darwin (>= i nfixed))))
	(if (= kind 'struct)
	    (let ((pieces (native-pieces size)))
	      (if (and (not variadic) (<= (+ gp (list-length pieces)) 8))
		  (list-do pc pieces (set forms (native-onto forms (native-arm64-piece 'LDR (cdr pc) (native-x gp) 'SP (+ slot (car pc))))) (set gp (+ gp 1)))
		(or variadic (set gp 8))	; AAPCS64 C.15: no general register is used after a struct that spills
		(set out (align out 8))
		(list-do pc pieces
		  (set forms (native-onto forms (native-arm64-piece 'LDR (cdr pc) 'X17 'SP (+ slot (car pc)))))
		  (set forms (native-onto forms (native-arm64-piece 'STR (cdr pc) 'X17 'SP (+ out (car pc))))))
		(set out (+ out (align size 8)))))
	  (cond
	    ((and (not variadic) (= kind 'float) (< fp 8))
	     (set forms (native-onto forms (native-arm64-load size 'X17 'SP slot)))
	     (set forms (native-onto forms (native-arm64-fmov-in (* 8 size) (native-arm64-farg fp (* 8 size)) 'X17)))
	     (set fp (+ fp 1)))
	    ((and (not variadic) (not (= kind 'float)) (< gp 8))
	     (set forms (native-onto forms (native-arm64-load size (native-x gp) 'SP slot))) (set gp (+ gp 1)))
	    (else
	    (set out (native-stack-align out size variadic))
	    (set forms (native-onto forms (native-arm64-load size 'X17 'SP slot)))
	    (set forms (native-onto forms (if variadic (arm64-sites `((STR X17 (mem ,(list 'off 'SP out))))) (native-arm64-store size 'X17 'SP out))))
	    (set out (+ out (if (or variadic (not native-darwin)) 8 size)))))))
      (set i (+ i 1)))
    (native-within-outgoing out)
    (set forms (native-onto forms (arm64-sites `((LDR X17 (mem ,(list 'off 'SP callee))) (BLR X17)))))
    (when ret
      (let ((size (car ret)) (slot (cadr ret)))
	(if (= 'struct (caddr ret))
	    (let ((r 0)) (list-do pc (native-result-pieces size) (set forms (native-onto forms (native-arm64-piece 'STR (cdr pc) (native-x r) 'SP (+ slot (car pc))))) (set r (+ r 1))))
	  (when (= 'float (caddr ret))
	    (set forms (native-onto forms (native-arm64-fmov-out (* 8 size) 'X0 (native-arm64-view (car (abi 'arm64 'fresult)) (* 8 size))))))
	  (set forms (native-onto forms (native-arm64-store size 'X0 'SP slot))))))
    (list-reverse! forms)))
(define-function native-arm64-result (size slot kind)
  (if (= kind 'struct)
      (let ((r 0) (forms ())) (list-do pc (native-result-pieces size) (set forms (native-onto forms (native-arm64-piece 'LDR (cdr pc) (native-x r) 'SP (+ slot (car pc))))) (set r (+ r 1))) (list-reverse! forms))
    (if (= kind 'float)
	(concat-list (native-arm64-load size 'X17 'SP slot)
		     (native-arm64-fmov-in (* 8 size) (native-arm64-view (car (abi 'arm64 'fresult)) (* 8 size)) 'X17))
      (native-arm64-load size 'X0 'SP slot))))
(define-function native-arm64-cond (c)
  (cdr (assq c '((eq . EQ) (ne . NE) (lt . LT) (le . LE) (gt . GT) (ge . GE) (lo . LO) (ls . LS) (hi . HI) (hs . HS)))))
(define native-skips 0)
;; to l if r is nonzero (skip, the inverted test, is CBZ) or zero (CBNZ): the short branch skips over B
(define-function native-arm64-branch (skip r l)
  (let ((past (string->symbol (concat-string "skip" (long->string (set native-skips (+ native-skips 1)))))))
    (if (= skip 'CBZ)
	(arm64-sites `((CBZ (x ,r) (label ,past)) (B (label ,l)) (at ,past)))
      (arm64-sites `((CBNZ (x ,r) (label ,past)) (B (label ,l)) (at ,past))))))
(require "native-arm64.g.l")
(require "native-x64.l")
(require "native-x64.g.l")
(require "native-link.l")

;; a unit is one compilation: maru.k's declarations (structs, objects, types, exports) accumulate, as it compiles once a process,
;; so each unit starts from what maru.k itself declared
(define native-maru-state (list (array-length *maru-structs*) *maru-types* *maru-exports*))
(define-function native-compile-file (path)
  (let ((structs (array)))
    (for (i 0 (car native-maru-state)) (array-append structs (array-at *maru-structs* i)))
    (set *maru-structs* structs))
  (set *maru-types* (cadr native-maru-state))
  (set *maru-exports* (caddr native-maru-state))
  (set *maru-objects* (array))		; maru.k declares none itself
  (compile-begin)
  (load path)
  (compile-end)
  *native-unit*)
