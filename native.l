;;; native.l -- typed Maru to native code in this process (draft-ndn-maru-native-ir2-00).  On eval2, which runs maru.k:
;;;   (native-compile-file path)   => a unit: the file's typed definitions as intents
;;;   (native-install unit)        => ((name . address) …)
(require "osdefs.k")
(require "asm-table.l")
(require "asm-arm64.l")
(require "asm-x86.l")
(require "code-region.l")
(require "stub.l")
(require "native-gen.k")
(load "maru.k")		; no arguments left: definitions only
;; for native-arm64.g's actions: moving SP by a frame's size, and the ith argument register
(define-function native-arm64-sp (op n)
  (cond ((= 0 n) ())
	((< n 4096) (list (list op 'SP 'SP n)))
	(else (error "native: a frame of " n " bytes is larger than arm64's immediate reaches"))))
(define-function native-arm64-arg (i)
  (let ((args (abi 'arm64 'args)))
    (for (k 0 i) (set args (cdr args)))
    (or (car args) (error "native: argument " i " isn't in a register"))))
(require "native-arm64.g.l")
(require "native-link.l")

(define-function native-compile-file (path)
  (compile-begin)
  (load path)
  (compile-end)
  *native-unit*)
