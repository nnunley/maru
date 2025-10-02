;;; mach-o-writer.l - Direct Mach-O dylib generation for Maru JIT
;;;
;;; This generates minimal Mach-O dynamic libraries without external tools

;; Mach-O constants
(define MH_MAGIC_64 #xfeedfacf)
(define CPU_TYPE_X86_64 #x01000007)
(define CPU_TYPE_ARM64 #x0100000c)
(define CPU_SUBTYPE_ALL 0)
(define MH_DYLIB #x6)
(define MH_NOUNDEFS #x1)
(define MH_DYLDLINK #x4)
(define MH_PIE #x200000)

;; Load command constants
(define LC_SEGMENT_64 #x19)
(define LC_SYMTAB #x2)
(define LC_DYSYMTAB #xb)
(define LC_ID_DYLIB #xd)
(define LC_UUID #x1b)
(define LC_BUILD_VERSION #x32)
(define LC_DYLD_INFO_ONLY #x80000022)

;; Section flags
(define S_REGULAR 0)
(define S_ATTR_PURE_INSTRUCTIONS #x80000000)
(define S_ATTR_SOME_INSTRUCTIONS #x00000400)

;;; Binary output utilities

(define-class <binary-buffer> ()
  (bytes     ; byte array
   position  ; current write position
   capacity)) ; buffer capacity

(define-function make-binary-buffer (initial-capacity)
  (let ((buf (new <binary-buffer>)))
    (set (<binary-buffer>-bytes buf) (make-array initial-capacity))
    (set (<binary-buffer>-position buf) 0)
    (set (<binary-buffer>-capacity buf) initial-capacity)
    buf))

(define-function buffer-ensure-capacity (buf needed)
  (let ((new-size (+ (<binary-buffer>-position buf) needed)))
    (when (> new-size (<binary-buffer>-capacity buf))
      ;; Grow buffer
      (let* ((new-capacity (* 2 (max new-size (<binary-buffer>-capacity buf))))
             (new-bytes (make-array new-capacity)))
        ;; Copy existing data
        (for (i 0 (<binary-buffer>-position buf))
          (set (array-at new-bytes i) (array-at (<binary-buffer>-bytes buf) i)))
        (set (<binary-buffer>-bytes buf) new-bytes)
        (set (<binary-buffer>-capacity buf) new-capacity)))))

(define-function buffer-write-u8 (buf byte)
  (buffer-ensure-capacity buf 1)
  (set (array-at (<binary-buffer>-bytes buf) (<binary-buffer>-position buf)) byte)
  (set (<binary-buffer>-position buf) (+ 1 (<binary-buffer>-position buf))))

(define-function buffer-write-u32 (buf value)
  ;; Little-endian
  (buffer-write-u8 buf (& value #xff))
  (buffer-write-u8 buf (& (>> value 8) #xff))
  (buffer-write-u8 buf (& (>> value 16) #xff))
  (buffer-write-u8 buf (& (>> value 24) #xff)))

(define-function buffer-write-u64 (buf value)
  ;; Little-endian, split into two 32-bit writes
  (buffer-write-u32 buf (& value #xffffffff))
  (buffer-write-u32 buf (>> value 32)))

(define-function buffer-write-bytes (buf bytes count)
  (for (i 0 count)
    (buffer-write-u8 buf (array-at bytes i))))

(define-function buffer-write-string (buf str)
  (let ((len (string-length str)))
    (for (i 0 len)
      (buffer-write-u8 buf (char->integer (string-at str i))))
    ;; Null terminate
    (buffer-write-u8 buf 0)))

(define-function buffer-align (buf alignment)
  (while (!= 0 (% (<binary-buffer>-position buf) alignment))
    (buffer-write-u8 buf 0)))

;;; Mach-O generation

(define-function generate-minimal-macho-dylib (code-bytes code-size)
  "Generate a minimal Mach-O dylib with one function"
  (let ((buf (make-binary-buffer 4096))
        (arch (get-current-arch)))
    
    ;; We'll calculate offsets as we go
    (let ((header-size 32)  ; Mach-O header
          (load-commands-size (* 8 80))  ; Rough estimate
          (text-offset #x1000)  ; Standard TEXT segment offset
          (text-size (align-up code-size 16)))
      
      ;; Mach-O header
      (buffer-write-u32 buf MH_MAGIC_64)
      (buffer-write-u32 buf (if (= arch 'arm64) CPU_TYPE_ARM64 CPU_TYPE_X86_64))
      (buffer-write-u32 buf CPU_SUBTYPE_ALL)
      (buffer-write-u32 buf MH_DYLIB)  ; filetype
      (buffer-write-u32 buf 4)         ; ncmds (segment, id_dylib, symtab, dysymtab)
      (buffer-write-u32 buf load-commands-size) ; sizeofcmds
      (buffer-write-u32 buf (logior MH_NOUNDEFS MH_DYLDLINK)) ; flags
      (buffer-write-u32 buf 0)         ; reserved
      
      ;; LC_SEGMENT_64 for __TEXT
      (let ((segment-start (<binary-buffer>-position buf)))
        (buffer-write-u32 buf LC_SEGMENT_64)
        (buffer-write-u32 buf 152)  ; command size (72 + 80 for section)
        (buffer-write-string buf "__TEXT")
        (buffer-align buf 16)  ; Pad segment name to 16 bytes
        (buffer-write-u64 buf 0)  ; vmaddr
        (buffer-write-u64 buf #x2000)  ; vmsize
        (buffer-write-u64 buf 0)  ; fileoff
        (buffer-write-u64 buf #x2000)  ; filesize
        (buffer-write-u32 buf 7)  ; maxprot (rwx)
        (buffer-write-u32 buf 5)  ; initprot (r-x)
        (buffer-write-u32 buf 1)  ; nsects
        (buffer-write-u32 buf 0)  ; flags
        
        ;; Section: __text
        (buffer-write-string buf "__text")
        (buffer-align buf 16)  ; Pad section name
        (buffer-write-string buf "__TEXT")
        (buffer-align buf 16)  ; Pad segment name
        (buffer-write-u64 buf text-offset)  ; addr
        (buffer-write-u64 buf text-size)    ; size
        (buffer-write-u32 buf text-offset)  ; offset
        (buffer-write-u32 buf 4)  ; align (2^4 = 16)
        (buffer-write-u32 buf 0)  ; reloff
        (buffer-write-u32 buf 0)  ; nreloc
        (buffer-write-u32 buf (logior S_REGULAR S_ATTR_PURE_INSTRUCTIONS S_ATTR_SOME_INSTRUCTIONS))
        (buffer-write-u32 buf 0)  ; reserved1
        (buffer-write-u32 buf 0)  ; reserved2
        (buffer-write-u32 buf 0)) ; reserved3
      
      ;; LC_ID_DYLIB
      (buffer-write-u32 buf LC_ID_DYLIB)
      (buffer-write-u32 buf 48)  ; cmdsize
      (buffer-write-u32 buf 24)  ; name offset
      (buffer-write-u32 buf 0)   ; timestamp
      (buffer-write-u32 buf 0)   ; current version
      (buffer-write-u32 buf 0)   ; compatibility version
      (buffer-write-string buf "maru_jit.dylib")
      (buffer-align buf 8)
      
      ;; LC_SYMTAB (simplified - one symbol)
      (buffer-write-u32 buf LC_SYMTAB)
      (buffer-write-u32 buf 24)  ; cmdsize
      (buffer-write-u32 buf #x2000)  ; symoff (after text)
      (buffer-write-u32 buf 1)   ; nsyms
      (buffer-write-u32 buf #x2020)  ; stroff
      (buffer-write-u32 buf 32)  ; strsize
      
      ;; LC_DYSYMTAB (minimal)
      (buffer-write-u32 buf LC_DYSYMTAB)
      (buffer-write-u32 buf 80)  ; cmdsize
      (for (i 0 18)  ; All fields zero for minimal dylib
        (buffer-write-u32 buf 0))
      
      ;; Pad to page boundary
      (buffer-align buf 4096)
      
      ;; TEXT segment content
      (buffer-write-bytes buf code-bytes code-size)
      (buffer-align buf 16)
      
      ;; Symbol table (simplified)
      (buffer-align buf #x2000)
      ;; nlist_64 entry
      (buffer-write-u32 buf 1)   ; n_strx (string table index)
      (buffer-write-u8 buf #x0f) ; n_type (N_SECT | N_EXT)
      (buffer-write-u8 buf 1)    ; n_sect (first section)
      (buffer-write-u16 buf 0)   ; n_desc
      (buffer-write-u64 buf text-offset) ; n_value
      
      ;; String table
      (buffer-align buf #x2020)
      (buffer-write-u8 buf 0)  ; empty string at index 0
      (buffer-write-string buf "_maru_compiled_fn")
      
      buf)))

(define-function buffer-write-u16 (buf value)
  (buffer-write-u8 buf (& value #xff))
  (buffer-write-u8 buf (& (>> value 8) #xff)))

(define-function align-up (value alignment)
  (let ((mask (- alignment 1)))
    (& (+ value mask) (lognot mask))))

(define-function write-buffer-to-file (buf filename)
  "Write binary buffer to file"
  (let ((file (open-output-file filename)))
    (for (i 0 (<binary-buffer>-position buf))
      (write-byte (array-at (<binary-buffer>-bytes buf) i) file))
    (close-output-port file)))

;;; Test direct Mach-O generation

(define-function test-direct-macho ()
  (println "Testing direct Mach-O generation...")
  
  ;; Simple ARM64 code: return 42
  (let ((code (if (= (get-current-arch) 'arm64)
                  ;; mov x0, #42; ret
                  (array #x80 #x05 #x80 #xd2  ; mov x0, #42
                         #xc0 #x03 #x5f #xd6) ; ret
                  ;; mov rax, 42; ret (x64)
                  (array #x48 #xc7 #xc0 #x2a #x00 #x00 #x00  ; mov rax, 42
                         #xc3))))                              ; ret
    
    (let* ((buf (generate-minimal-macho-dylib code (array-length code)))
           (filename (concat-string *jit-temp-dir* "/direct_macho.dylib")))
      (write-buffer-to-file buf filename)
      (println (concat-string "Generated: " filename))
      
      ;; Try to load it
      (let ((handle (dlopen-prim filename)))
        (if handle
            (let ((fn (dlsym-prim handle "_maru_compiled_fn")))
              (if fn
                  (let ((result (call-compiled-function fn)))
                    (println (concat-string "Result: " (number->string result)))
                    (if (= result 42)
                        (println "SUCCESS: Direct Mach-O generation works!")
                        (error "Got wrong result")))
                  (error "Failed to find symbol")))
            (error "Failed to load direct Mach-O"))))))