;;; exe.l writes programs the operating system runs directly: each target's program prints a message and exits 42.
;;;
;;;   ./eval check/exe.l DIR        writes DIR/TARGET for each target, and checks SHA-256 and refusals
;;;   ./eval2 -b boot2.l check/exe.l --jit      the same arm64 code, run in this process through a code region
;;;   ./eval check/exe.l --import-on-linux      a static target refuses an import, by name
;;;   ./eval check/exe.l --no-entry, --unwritable   an entry outside the code, and a path it can't write, are errors
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

(define-function repeated (n)
  (let ((out (string n))) (for (i 0 n) (set-string-at out i ?a)) out))
(expect "sha256 63 bytes" (digest (repeated 63)) "7d3e74a05d7db15bce4ad9ec0658ea98e3f06eeecf16b4c6fff2da457ddc2f34")
(expect "sha256 64 bytes" (digest (repeated 64)) "ffe054fe7ae0cb6dc65c3af9b61d5209f439851db43d0ba5997337df154668eb")
(expect "sha256 65 bytes" (digest (repeated 65)) "635361c48bb9eab14198e76ea8ab7f1a41685d6ad62aa9146d301d4f17eb0ae0")
(expect "sha256 119 bytes" (digest (repeated 119)) "31eba51c313a5c08226adf18d4a359cfdfd8d2e816b13f4af952f7ea6584dcfb")
(expect "sha256 120 bytes" (digest (repeated 120)) "2f3d335432c70b580af0e8e1b3674a7c020d683aa5f73aaaedfdc55af904c21c")
(expect "sha256 4097 bytes" (digest (repeated 4097)) "4e369b5618643c3abddd027b650bfa54810be3b418028a7c9d82299a59d008e8")

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

(define-function message-buffer (target padding)	; the message, padding so the code is far from it, aligned for A64
  (let ((buffer (asm-buffer (exe-origin target))) (bytes (bytes-of-string message)))
    (for (i 0 (array-length bytes)) (array-append (asm-buffer-bytes buffer) (array-at bytes i)))
    (for (i 0 padding) (array-append (asm-buffer-bytes buffer) 0))
    (while (not (= 0 (& (array-length (asm-buffer-bytes buffer)) 3)))
      (array-append (asm-buffer-bytes buffer) 0))
    buffer))
(define-function write-program (target path padding)
  (let* ((origin (exe-origin target))
	 (buffer (message-buffer target padding)))
    (let ((entry (asm-buffer-pc buffer)))
      (program target buffer origin)
      (exe-write path target buffer entry))))

;; the same program through libSystem, the interface macOS keeps stable: write and exit are imports, not system calls
(define libsystem '("write" "exit"))
(define-function libsystem-program (target buffer at)
  (let ((n (string-length message))
	(write (exe-import-slot target "write" libsystem))
	(exit (exe-import-slot target "exit" libsystem)))
    (define-function slot-call-arm64 (slot)
      `((ADRP X16 ,(& slot -4096)) (LDR X16 (off X16 ,(& slot 4095))) (BLR X16)))
    (list-do form
	(if (= 'arm64 (exe-isa target))
	    (concat-list
	     `((MOVZ X0 1 (LSL 0)) (ADR X1 ,at) (MOVZ X2 ,n (LSL 0)))
	     (concat-list (slot-call-arm64 write)
			  (cons '(MOVZ X0 42 (LSL 0)) (slot-call-arm64 exit))))
	  `((PUSH RBP)					; a call needs the stack aligned, and main starts 8 off
	    (MOV RDI 1) (LEA RSI (m ,at RIP () 1)) (MOV RDX ,n) (CALL (m64 ,write RIP () 1))
	    (MOV RDI 42) (CALL (m64 ,exit RIP () 1))))
      (asm (exe-isa target) buffer form))))
(define-function write-libsystem-program (target path padding)
  (let* ((origin (exe-origin target))
	 (buffer (message-buffer target padding)))
    (let ((entry (asm-buffer-pc buffer)))
      (libsystem-program target buffer origin)
      (apply exe-write (cons path (cons target (cons buffer (cons entry libsystem))))))))

;; the one piece of code, written to a file and run in this process: it returns 42 either way
(define-function answer-buffer (origin)
  (let ((b (asm-buffer origin)))
    (asm 'arm64 b '(MOVZ X0 42 (LSL 0)))
    (asm 'arm64 b '(RET))
    b))

(let ((mode (next-argument)))
  (cond
    ((= mode "--import-on-linux") (exe-import-slot 'linux-x64 "write" libsystem))
    ((= mode "--no-entry") (exe-write "/dev/null" 'macos-arm64 (asm-buffer (exe-origin 'macos-arm64)) (exe-origin 'macos-arm64)))
    ((= mode "--unwritable") (write-program 'linux-x64 "/nonexistent/maru" 0))
    ((= mode "--jit")
     (let* ((region (code-region-allocate 4096))
	    (b (answer-buffer (code-region-next region))))
       (expect "the code through the JIT" ((code-callable (code-region-install region b) ">i")) 42)))
    (else
     (list-do target (exe-targets)
       (write-program target (concat-strings mode "/" (symbol->string target)) 0))
     (write-libsystem-program 'macos-arm64 (concat-strings mode "/macos-arm64-libsystem") 0)
     (write-libsystem-program 'macos-x64 (concat-strings mode "/macos-x64-libsystem") 0)
     ;; code past the first 16 KB segment page and several signature pages, or past an ELF's first page
     (write-libsystem-program 'macos-arm64 (concat-strings mode "/macos-arm64-big") 40000)
     (write-libsystem-program 'macos-x64 (concat-strings mode "/macos-x64-big") 40000)
     (write-program 'linux-x64 (concat-strings mode "/linux-x64-big") 5000)
     (exe-write (concat-strings mode "/answer") 'macos-arm64 (answer-buffer (exe-origin 'macos-arm64)) (exe-origin 'macos-arm64))
     (expect "a target nothing knows is refused" (exe-known? 'plan9-mips) ()))))
(and ok (println "exe ok"))
