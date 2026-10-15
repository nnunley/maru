; Title: PEG-based transformer provides front-, middle- and back-end stages in a simple compiler
; Authors: Ian Piumarta
; Source: VPRI Technical Report TR-2010-003 (2010), Section 3 ("The compilation chain by example"), the
;   nfibs benchmark source. Printed page 2, PDF page 3 (left column). Example program source.
; Transcribed from the page images; text-layer differences noted below.

(define nfibs
  (lambda (n)
    (if (< n 2)
      1
      (+ 1 (+ (nfibs (- n 1)) (nfibs (- n 2))))))))

(print (nfibs 32))

; Transcription notes
; - Checked at 300 dpi. The closing run after "(- n 2" is printed with eight ')' characters; the
;   structure needs seven to close (- , nfibs, inner +, outer +, if, lambda, define). Kept as printed. [?]
;   The text layer also shows eight. The count was read from the 300 dpi image, not verified by a second source.
; - Space before "1" and "(+ 1" indentation follows the page image (lines indented two spaces, four, six, eight).
