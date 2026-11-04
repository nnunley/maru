;;; exe.l: programs the operating system runs directly, with no compiler, linker or codesign.  What code-region.l does
;;; for the JIT, this does for a file: it takes an assembly buffer (asm-table.l) whose origin is (exe-origin target).
;;;
;;;   (exe-targets)                      the targets, by name
;;;   (exe-isa target)                   the instruction set asm-table.l knows it by
;;;   (exe-origin target)                the address its code is loaded at
;;;   (exe-write path target buffer entry)   writes the program, executable, starting at address entry
;;;
;;; A target is data: its format and the numbers that format names it by.  ELF is static, one loaded segment.  Mach-O
;;; keeps dyld, because the kernel kills a fully static one, and signs itself, because it kills unsigned arm64 code.
(require "sha256.l")

(define *exe-targets*
  '((linux-i386	 x86   elf32 3)		; EM_386
    (linux-x64	 x64   elf64 62)	; EM_X86_64
    (linux-arm64 arm64 elf64 183)	; EM_AARCH64
    (macos-arm64 arm64 macho 0x0100000c 0)
    (macos-x64	 x64   macho 0x01000007 3)))
(define-function exe-targets () (map car *exe-targets*))
(define-function exe-known? (target) (and (assq target *exe-targets*) 1))
(define-function exe-target (target) (or (assq target *exe-targets*) (error "exe: no target " target)))
(define-function exe-isa (target) (cadr (exe-target target)))
(define-function exe-format (target) (caddr (exe-target target)))
(define-function exe-align (n to) (* to (/ (+ n (- to 1)) to)))

;;; ---- bytes

(define-function exe-le (out width value)
  (for (i 0 width) (array-append out (& (>> value (* 8 i)) 255))))
(define-function exe-be (out width value)
  (for (i 0 width) (array-append out (& (>> value (* 8 (- width (+ i 1)))) 255))))
;; fields is a list of (width value); a value that's a string is padded with zeros to the width
(define-function exe-fields (out endian fields)
  (list-do f fields
    (if (string? (cadr f))
	(for (i 0 (car f))
	  (array-append out (if (< i (string-length (cadr f))) (string-at (cadr f) i) 0)))
      (endian out (car f) (cadr f)))))
(define-function exe-pad (out length) (while (< (array-length out) length) (array-append out 0)))
(define-function exe-append-code (out buffer)
  (let ((bytes (asm-buffer-bytes buffer)))
    (for (i 0 (array-length bytes)) (array-append out (array-at bytes i)))))
(define-function exe-save (path out)
  (let ((f ((subr "fopen" "ss>p") path "wb")) (fputc (subr "fputc" "ip>i")))
    (or f (error "exe: can't write " path))
    (for (i 0 (array-length out)) (fputc (array-at out i) f))
    ((subr "fclose" "p>i") f)
    (or (= 0 ((subr "chmod" "si>i") path 493)) (error "exe: can't chmod " path))))	; 0755

;;; ---- ELF: a header, one PT_LOAD over the whole file, the code

(define-function exe-elf-base (format) (if (= format 'elf32) 0x08048000 0x400000))
(define-function exe-elf-headers (format) (if (= format 'elf32) (+ 52 32) (+ 64 56)))
(define-function exe-elf (target buffer entry)
  (let* ((format (exe-format target))
	 (wide (= format 'elf64))
	 (word (if wide 8 4))
	 (base (exe-elf-base format))
	 (start (exe-align (exe-elf-headers format) 16))
	 (size (+ start (array-length (asm-buffer-bytes buffer))))
	 (out (array)))
    (exe-fields out exe-le
      `((1 0x7f) (3 "ELF") (1 ,(if wide 2 1)) (1 1) (1 1) (9 "")	; 64-bit or 32, little-endian, version 1
	(2 2) (2 ,(cadddr (exe-target target))) (4 1)			; ET_EXEC, machine, version 1
	(,word ,entry) (,word ,(if wide 64 52)) (,word 0)		; entry, program headers, no sections
	(4 0) (2 ,(if wide 64 52)) (2 ,(if wide 56 32)) (2 1) (2 ,(if wide 64 40)) (2 0) (2 0)))
    ;; PT_LOAD, readable and executable; the two sizes of ELF order its fields differently
    (exe-fields out exe-le
      (if wide
	  `((4 1) (4 5) (8 0) (8 ,base) (8 ,base) (8 ,size) (8 ,size) (8 0x1000))
	`((4 1) (4 0) (4 ,base) (4 ,base) (4 ,size) (4 ,size) (4 5) (4 0x1000))))
    (exe-pad out start)
    (exe-append-code out buffer)
    out))

;;; ---- Mach-O: __PAGEZERO, __TEXT with __text, __LINKEDIT holding the signature, dyld, the entry

(define exe-macho-base 0x100000000)
(define exe-macho-page 0x4000)
(define exe-macho-headers (+ 32 (+ 72 (+ 152 (+ 72 (+ 32 (+ 24 16)))))))
(define exe-sign-page 4096)

;; an ad-hoc signature: a SuperBlob holding one CodeDirectory, hashing each page of bytes up to limit
(define-function exe-signature (bytes limit identifier)
  (let* ((pages (/ (exe-align limit exe-sign-page) exe-sign-page))
	 (ident-at 88)
	 (hash-at (+ ident-at (+ (string-length identifier) 1)))
	 (directory (+ hash-at (* pages 32)))
	 (out (array)))
    (exe-fields out exe-be
      `((4 0xfade0cc0) (4 ,(+ 20 directory)) (4 1) (4 0) (4 20)		; SuperBlob, one blob: CodeDirectory at 20
	(4 0xfade0c02) (4 ,directory) (4 0x20400) (4 2)			; CodeDirectory, CS_ADHOC
	(4 ,hash-at) (4 ,ident-at) (4 0) (4 ,pages) (4 ,limit)		; hashes, identifier, no special slots
	(1 32) (1 2) (1 0) (1 12) (4 0)					; SHA-256, 4 KB pages
	(4 0) (4 0) (4 0) (8 ,limit)					; no scatter or team; limit, 64-bit
	(8 0) (8 ,limit) (8 1)))					; executable segment, the main binary
    (exe-fields out exe-be `((,(+ (string-length identifier) 1) ,identifier)))
    (for (page 0 pages)
      (let ((at (* page exe-sign-page)))
	(list-do b (sha256 bytes at (min exe-sign-page (- limit at))) (array-append out b))))
    out))

(define-function exe-macho (target buffer entry identifier)
  (let* ((t (exe-target target))
	 (start (exe-align exe-macho-headers 16))
	 (code (array-length (asm-buffer-bytes buffer)))
	 (text (exe-align (+ start code) exe-macho-page))
	 (pages (/ (exe-align text exe-sign-page) exe-sign-page))
	 (signature-size (+ 20 (+ 88 (+ (+ (string-length identifier) 1) (* pages 32)))))
	 (out (array)))
    (exe-fields out exe-le
      `((4 0xfeedfacf) (4 ,(cadddr t)) (4 ,(car (cddddr t))) (4 2)		; MH_EXECUTE
	(4 6) (4 ,(- exe-macho-headers 32)) (4 0x200085) (4 0)			; MH_NOUNDEFS DYLDLINK TWOLEVEL PIE
	(4 0x19) (4 72) (16 "__PAGEZERO") (8 0) (8 ,exe-macho-base) (8 0) (8 0) (4 0) (4 0) (4 0) (4 0)
	(4 0x19) (4 152) (16 "__TEXT") (8 ,exe-macho-base) (8 ,text) (8 0) (8 ,text) (4 5) (4 5) (4 1) (4 0)
	(16 "__text") (16 "__TEXT") (8 ,(+ exe-macho-base start)) (8 ,code) (4 ,start) (4 4)
	(4 0) (4 0) (4 0x80000400) (4 0) (4 0) (4 0)
	(4 0x19) (4 72) (16 "__LINKEDIT") (8 ,(+ exe-macho-base text)) (8 ,(exe-align signature-size exe-macho-page))
	(8 ,text) (8 ,signature-size) (4 1) (4 1) (4 0) (4 0)
	(4 0xe) (4 32) (4 12) (20 "/usr/lib/dyld")				; LC_LOAD_DYLINKER
	(4 0x80000028) (4 24) (8 ,(- entry exe-macho-base)) (8 0)		; LC_MAIN
	(4 0x1d) (4 16) (4 ,text) (4 ,signature-size)))				; LC_CODE_SIGNATURE
    (exe-pad out start)
    (exe-append-code out buffer)
    (exe-pad out text)
    (let ((signature (exe-signature out text identifier)))
      (for (i 0 (array-length signature)) (array-append out (array-at signature i))))
    out))

;;; ---- what callers use

(define-function exe-origin (target)
  (let ((format (exe-format target)))
    (if (= format 'macho)
	(+ exe-macho-base (exe-align exe-macho-headers 16))
      (+ (exe-elf-base format) (exe-align (exe-elf-headers format) 16)))))
(define-function exe-write (path target buffer entry)
  (or (= (asm-buffer-origin buffer) (exe-origin target))
      (error "exe: the buffer's origin isn't " target "'s"))
  (exe-save path (if (= 'macho (exe-format target))
		     (exe-macho target buffer entry "maru")
		   (exe-elf target buffer entry))))
