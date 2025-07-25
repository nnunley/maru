;;; gen-c.l - Standalone C code generator
;;; 
;;; This generates C code from assembly output

(define-function asm->c (input-file output-file)
  (let ((in (open input-file))
        (out (open output-file "w")))
    
    ;; Write C headers
    (fprintf out "#include <stdio.h>\n")
    (fprintf out "#include <stdlib.h>\n")
    (fprintf out "#include <string.h>\n\n")
    
    ;; Process assembly to C
    (let ((line ()))
      (while (set line (read-line in))
        (cond
          ;; Function labels
          ((string-match "^_?([a-zA-Z_][a-zA-Z0-9_]*):" line)
           (fprintf out "\nlong %s() {\n" (match 1))
           (fprintf out "  long _eax = 0;\n"))
          
          ;; ret instruction - end of function
          ((string-match "^\\s*ret" line)
           (fprintf out "  return _eax;\n")
           (fprintf out "}\n"))
          
          ;; movl immediate to eax
          ((string-match "^\\s*movl\\s+\\$([0-9]+),%%eax" line)
           (fprintf out "  _eax = %s;\n" (match 1)))
          
          ;; Skip other instructions for now
          (else ()))))
    
    (close in)
    (close out)))

;; Test if run directly
(and (= *argv* '("gen-c.l"))
     (let ()
       (println "Usage: ./eval gen-c.l input.s output.c")
       (exit 1)))