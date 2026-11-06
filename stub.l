;;; stub.l: small pieces of native code written once, as intents, for every instruction set.  abi.spec says what each
;;; calling convention keeps where, stub-*.g lower intents to forms by matching them as a tree, asm-table.l encodes those,
;;; and code-region.l installs the result.  What the evaluator then calls is a primitive like its own, whose function
;;; is the stub, so it's handed the evaluator's args and environment untouched.
;;;
;;;   (stub-isa)                       the instruction set this process runs
;;;   (stub-primitive intents)         a primitive that runs them, with no C
(require "osdefs.k")
(require "source-parser.l")
(require "text-parser.l")
(require "abi.g.l")

;; the machine uname names, where osdefs.k says its field is
(define stub-host-isa
  (let* ((u ((subr "malloc" "l>p") utsname_size))
	 (_ ((subr "uname" "p>i") u)))
    (if (= ?a (byte-at u utsname_machine)) 'arm64 'x64)))	; arm64, aarch64; x86_64
(define-function stub-isa () stub-host-isa)

(define stub-abi-rows (parse-string <abispec> $file (contents-of-file-named "abi.spec")))
;; the registers of one row, as symbols
(define-function abi (isa kind)
  (let ((found ()))
    (list-do row stub-abi-rows
      (and (= (car row) isa) (= (cadr row) kind) (set found (caddr row))))
    found))
(define-function stub-reg (isa r)
  (cond ((= r 'result) (car (abi isa 'result)))
	((= r 'a0) (car (abi isa 'args)))
	((= r 'a1) (cadr (abi isa 'args)))
	(else (let* ((name (symbol->string r))
		     (scratch (abi isa 'scratch))
		     (n (- (string-at name 1) ?0)))
		(while (< 0 n) (set scratch (cdr scratch)) (set n (- n 1)))
		(car scratch)))))

;; forms for the lowering grammars' actions
(define-function arm64-constant (r v)
  (list (list 'MOVZ r (& v 0xffff) '(LSL 0))
	(list 'MOVK r (& (>> v 16) 0xffff) '(LSL 16))
	(list 'MOVK r (& (>> v 32) 0xffff) '(LSL 32))
	(list 'MOVK r (& (>> v 48) 0xffff) '(LSL 48))))
;; each two registers of each list as one instruction, first to last
(define-function arm64-pairs (op mode step integers floats)
  (let ((out ()))
    (list-do regs (list integers floats)
      (while regs
	(push out (list op (car regs) (cadr regs) (list mode 'SP step)))
	(set regs (cddr regs))))
    (list-reverse! out)))
(define-function reverse-pairs (forms) (list-reverse! forms))
;; the return address and six saved registers leave the stack 8 off, and the frame after them is two words
(define-function x64-save ()
  (let ((forms ()))
    (list-do r (abi 'x64 'saved) (push forms (list 'PUSH r)))
    (concat-list (list-reverse! forms) '((SUB RSP 8)))))
(define-function x64-restore ()
  (let ((forms ()))
    (list-do r (abi 'x64 'saved) (push forms (list 'POP r)))
    (cons '(ADD RSP 8) forms)))

(require "stub-arm64.g.l")
(require "stub-x64.g.l")

(define stub-region (code-region-allocate 65536))
(define stub-lowerings (list (cons 'arm64 (lambda (intents) (parse-source <stub-arm64> $program intents)))
			     (cons 'x64 (lambda (intents) (parse-source <stub-x64> $program intents)))))
;; the address of the code the intents lower to
(define-function stub-install (intents)
  (let* ((isa (stub-isa))
	 (forms ((cdr (assq isa stub-lowerings)) intents))
	 (buffer (asm-buffer (code-region-next stub-region))))
    (list-do intent forms	; each intent lowers to a list of forms
      (list-do form intent (asm isa buffer form)))
    (code-region-install stub-region buffer)))

;; a word of an object or of memory, by bytes, since long-at isn't on every evaluator
(define-function stub-word-at (object i)
  (let ((word 0))
    (for (j 0 8) (set word (+ word (<< (byte-at object (+ (* i 8) j)) (* 8 j)))))
    word))
(define-function stub-set-word-at (object i value)
  (for (j 0 8) (set-byte-at object (+ (* i 8) j) (& (>> value (* 8 j)) 255))))
(define-function stub-symbol (name)		; RTLD_DEFAULT is -2 on macOS and 0 on Linux; a symbol not found is 0
  (let ((address ((subr "dlsym" "ps>p") RTLD_DEFAULT name)))
    (if (= 0 address) (error "stub: no symbol " name) address)))

;; the primitive: a copy of apply's object, not scanned by the collector, with the stub as its function
(define-function stub-primitive (intents)
  (let ((primitive (allocate-atomic (type-of apply) 32)))
    (for (i 0 4) (stub-set-word-at primitive i (stub-word-at apply i)))
    (stub-set-word-at primitive 1 (stub-install intents))
    primitive))
(define stub-apply (stub-word-at apply 1))	; what apply's primitive calls, with the evaluator's args and environment
