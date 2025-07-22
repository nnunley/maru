;;; emit.l -- Code generation system
;;;
;;; This file loads the code generation infrastructure
;;; Currently configured for x86 assembly generation

(require "emit-base.l")         ; Core infrastructure
(require "emit-x86-operands.l") ; x86-specific operand printing
(require "emit-x86.l")          ; x86 assembly generation