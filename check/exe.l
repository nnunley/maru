;;; exe.l writes programs the operating system runs directly: each target's program prints a message and exits 42.
;;;
;;;   ./eval check/exe.l DIR        writes DIR/TARGET for each target, and checks SHA-256 and refusals
;;;   ./eval2 -b boot2.l check/exe.l --jit      the same arm64 code, run in this process through a code region
(require "osdefs.k")
(require "asm-table.l")
(require "asm-arm64.l")
(require "asm-x86.l")
(require "code-region.l")
(require "exe.l")

(define ok 1)
(define-function expect (what got want)
  (or (equal got want)
      (let () (set ok ()) (println "FAIL " what ": got " got ", want " want))))
(define-function bytes-of-string (s)
  (let ((a (array)))
    (for (i 0 (string-length s)) (array-append a (string-at s i)))
    a))
(define-function hex (bytes)
  (let ((out ""))
    (list-do b bytes
      (set out (concat-string out (format "%02x" b))))
    out))
(define-function digest (s) (hex (sha256 (bytes-of-string s) 0 (string-length s))))

;; FIPS 180-4's vectors, and lengths around where padding spills into a second block
(expect "sha256 empty" (digest "") "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
(expect "sha256 abc" (digest "abc") "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
(expect "sha256 two blocks" (digest "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq")
	"248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1")
(expect "sha256 55" (digest "1234567890123456789012345678901234567890123456789012345")
	"03c3a70e99ed5eeccd80f73771fcf1ece643d939d9ecc76f25544b0233f708e9")
(expect "sha256 56" (digest "12345678901234567890123456789012345678901234567890123456")
	"0be66ce72c2467e793202906000672306661791622e0ca9adf4a8955b2ed189c")

;; message, then code, entered just past the message; on 64 bits it's found relative to the code, wherever that's loaded
(define message "hello from maru\n")
(define-function syscalls (target)	; write, exit
  (cadr (assq target '((linux-i386 (4 1)) (linux-x64 (1 60)) (linux-arm64 (64 93))
		       (macos-x64 (0x2000004 0x2000001)) (macos-arm64 (4 1))))))
(define-function program (target buffer at)
  (let ((nr (syscalls target)) (n (string-length message)))
    (let ((isa (exe-isa target)))
      (list-do form
	  (cond
	    ((= isa 'x86)
	     `((MOV EAX ,(car nr)) (MOV EBX 1) (MOV ECX ,at) (MOV EDX ,n) (INT 0x80)
	       (MOV EAX ,(cadr nr)) (MOV EBX 42) (INT 0x80)))
	    ((= isa 'x64)
	     `((MOV RAX ,(car nr)) (MOV RDI 1)
	       (LEA RSI (m ,at RIP () 1))
	       (MOV RDX ,n) (SYSCALL)
	       (MOV RAX ,(cadr nr)) (MOV RDI 42) (SYSCALL)))
	    (else
	     (let ((r (if (= target 'macos-arm64) 'X16 'X8)) (svc (if (= target 'macos-arm64) 0x80 0)))
	       `((MOVZ X0 1 (LSL 0))
		 (ADR X1 ,at)
		 (MOVZ X2 ,n (LSL 0))
		 (MOVZ ,r ,(car nr) (LSL 0))
		 (SVC ,svc)
		 (MOVZ X0 42 (LSL 0))
		 (MOVZ ,r ,(cadr nr) (LSL 0))
		 (SVC ,svc)))))
	(asm isa buffer form)))))

(define-function write-program (target path)
  (let* ((origin (exe-origin target))
	 (buffer (asm-buffer origin))
	 (bytes (bytes-of-string message)))
    (for (i 0 (array-length bytes)) (array-append (asm-buffer-bytes buffer) (array-at bytes i)))
    (while (not (= 0 (& (array-length (asm-buffer-bytes buffer)) 3)))	; A64 code is aligned
      (array-append (asm-buffer-bytes buffer) 0))
    (let ((entry (asm-buffer-pc buffer)))
      (program target buffer origin)
      (exe-write path target buffer entry))))

;; the one piece of code, written to a file and run in this process: it returns 42 either way
(define-function answer-buffer (origin)
  (let ((b (asm-buffer origin)))
    (asm 'arm64 b '(MOVZ X0 42 (LSL 0)))
    (asm 'arm64 b '(RET))
    b))

(let ((mode (next-argument)))
  (cond
    ((= mode "--jit")
     (let* ((region (code-region-allocate 4096))
	    (b (answer-buffer (code-region-next region))))
       (expect "the code through the JIT" ((code-callable (code-region-install region b) ">i")) 42)))
    (else
     (list-do target (exe-targets)
       (write-program target (concat-strings mode "/" (symbol->string target))))
     (exe-write (concat-strings mode "/answer") 'macos-arm64 (answer-buffer (exe-origin 'macos-arm64)) (exe-origin 'macos-arm64))
     (expect "a target nothing knows is refused" (exe-known? 'plan9-mips) ()))))
(and ok (println "exe ok"))
