;;; The one encoder interface, answered by the arm64 and x64 rows alike.  Runs under ./eval and
;;; ./eval2 -b boot2.l alike; prints "asm interface ok" when everything holds.

(require "asm-table.l")
(require "asm-arm64.l")
(require "asm-x86.l")

(define failures 0)
(define-form expect (form value)
  `(let ((got ,form))
     (or (equal got ,value)
	 (let () (println "FAIL " ',form " => " got ", expected " ,value) (set failures (+ failures 1))))))
(define-function bytes (b) (array->list (asm-buffer-bytes b)))
(define-function byte-array (l) (let ((a (array))) (list-do x l (array-append a x)) a))

(let ((b (asm-buffer 0x1000)))
  (expect (asm 'arm64 b '(ADD X0 X1 X2)) ())
  (expect (bytes b) '(0x20 0x00 0x02 0x8b))
  (expect (asm-buffer-pc b) 0x1004)
  ;; a branch target is reported: operand 0, at byte offset 4 of the buffer
  (let ((reports (asm 'arm64 b '(B 0x1000))))
    (expect (list-length reports) 1)
    (expect (car (car reports)) 0)
    (expect (cadr (car reports)) 4))
  (expect (bytes b) '(0x20 0x00 0x02 0x8b 0xff 0xff 0xff 0x17))
  ;; a failed encode reports why and leaves the buffer as it was
  (expect (car (asm-attempt 'arm64 b '(ADD X0 W1 3))) 'error)
  (expect (asm-buffer-pc b) 0x1008))

(expect (if (<= 4 (list-length (asm-forms 'arm64 'ADD))) 'yes) 'yes)
(expect (asm-forms 'arm64 'NO-SUCH) ())
(expect (asm-decode 'arm64 (byte-array '(0x20 0x00 0x02 0x8b)) 0) '((ADD X0 X1 X2) . 4))
(expect (asm-decode 'arm64 (byte-array '(0xff 0xff 0xff 0x17)) 0x1004) '((B 0x1000) . 4))

;; (data byte...) is emitted unchanged on every instruction set; bytes are 0..255.
(let ((a (asm-buffer 0)) (x (asm-buffer 0)))
  (expect (asm 'arm64 a '(data 1 2 255)) ())
  (expect (bytes a) '(1 2 255))
  (expect (asm 'x64 x '(data 0x0f 0x0b)) ())
  (expect (bytes x) '(0x0f 0x0b))
  (expect (car (asm-attempt 'x64 x '(data 256))) 'error)
  (expect (bytes x) '(0x0f 0x0b)))

;; A patch never changes an instruction's length, even where a row would:
;; LIT's byte count grows with its value past 255.
(asm-register-isa 'grow '((LIT (imm)))
		  (lambda (row insn pc) (let ((v (cadr insn)))
					  (cons (cond ((pair? v) '(0)) ((< v 256) (list v)) (else (list (& v 255) (>> v 8))))
						(and (pair? v) '(0)))))
		  () (lambda (row position pc len) '(0 65535 1)) ())
(let* ((g (asm-buffer 0)) (r (car (asm 'grow g '(LIT (reloc))))))
  (expect (car (asm-patch-attempt 'grow g r 0x1234)) 'error)
  (expect (bytes g) '(0))
  (asm-patch 'grow g r 7)
  (expect (bytes g) '(7)))

;; The same calls for x64: no caller branches on the instruction set.
(let ((b (asm-buffer 0x1000)))
  (expect (asm 'x64 b '(ADD RAX R12)) ())
  (expect (bytes b) '(0x4c 0x01 0xe0))
  (let ((reports (asm 'x64 b '(CALL 0x1000))))
    (expect (car (car reports)) 0)
    (expect (cadr (car reports)) 3))
  (expect (bytes b) '(0x4c 0x01 0xe0 0xe8 0xf8 0xff 0xff 0xff))
  (expect (car (asm-attempt 'x64 b '(MOV AH R8B))) 'error)
  (expect (asm-buffer-pc b) 0x1008))
(expect (if (<= 4 (list-length (asm-forms 'x64 'ADD))) 'yes) 'yes)
(expect (asm-decode 'x64 (byte-array '(0x4c 0x01 0xe0)) 0) '((ADD RAX R12) . 3))

(if (= 0 failures) (println "asm interface ok"))
