; Title: PEG-based transformer provides front-, middle- and back-end stages in a simple compiler
; Authors: Ian Piumarta
; Source: VPRI Technical Report TR-2010-003 (2010), Section 3.2 ("Middle end: AST to abstract machine"), the
;   abstract machine program for the nfibs example, printed as a listing. Printed page 3, PDF page 4 (left column).
; Transcribed from the page images; text-layer differences noted below.

(label 3
 enter
 load-long 2 save load-arg 0 less branch-false 1
 load-long 1 branch 2
 label 1
 load-long 2 save load-arg 0 sub save
 load-var nfibs call 1 save
 load-long 1 save load-arg 0 sub save
 load-var nfibs call 1 add save
 load-long 1 add
 label 2
 leave
 main
 long nfibs load-label 3 store-var nfibs
 load-long 32 save load-var nfibs call 1 save
 load-var print call 1
 exit)

; Transcription notes
; - Read from the 150 dpi page image and cross-checked against the text layer (same tokens and line breaks).
; - Continuation lines are indented by one space, as printed.
; - Trailing spaces removed.
; - No glyph left uncertain.
