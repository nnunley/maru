;;; emit-x86-operands.l -- x86-specific operand printing
;;;
;;; This file extends the operands with x86-specific printing

;;; Override the TI32 printing for x86
(define-method do-print <TI32> () (print (<TI32>-offset self)"(%esp)"))