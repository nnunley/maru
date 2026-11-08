;;; maru-lines.l -- (maru-lines-read text path) reads Maru source through maru-lines.g to the forms eval.c's reader makes, each
;;; list's first pair holding a <source-span> in its source, where eval.c's reader holds (path . line): the file and the
;;; first and last lines it spans, counted from 1.  (maru-lines-span form) is a list's span, or () for one maru-lines
;;; didn't read.
(require "source-parser.l")
(define compile-tpeg-definitions-only 1)
(require "compile-tpeg.l")

(define-structure <source-span> (path first last))
(define-method do-print <source-span> () (print self.path ":" self.first "-" self.last))
(define-function maru-lines-string (cs) (list->string cs))
(define-function maru-line-of (starts pos)	; the line holding pos, from 1: the last start at or before it, by halving
  (let ((lo 0) (hi (- (array-length starts) 1)))
    (while (< lo hi)
      (let ((mid (/ (+ (+ lo hi) 1) 2)))
	(if (<= (array-at starts mid) pos) (set lo mid) (set hi (- mid 1)))))
    (+ lo 1)))
(define-function maru-lines-list (fs start end path starts)	; fs, dotted if a . comes before its last form (eval.c's
  (let ((p fs))							; reader's rule), its span in its first pair's source
    (while (and (pair? p) (pair? (cdr p)) (pair? (cddr p)) (not (= '. (cadr p)))) (set p (cdr p)))
    (and (pair? p) (pair? (cdr p)) (pair? (cddr p)) (= '. (cadr p)) (not (cdddr p)) (set-cdr p (caddr p))))
  (and (pair? fs)
       (set (<pair>-source fs) (make <source-span> path: path first: (maru-line-of starts start) last: (maru-line-of starts (- end 1)))))
  fs)
(tpeg-load "maru-lines.g")

(define-function maru-lines-starts (text)	; where each line starts
  (let ((starts (array 0)))
    (array-append starts 0)
    (for (i 0 (string-length text)) (and (= 10 (string-at text i)) (array-append starts (+ i 1))))
    starts))
(define-function maru-lines-span (form)	; a list's <source-span>, or ()
  (let ((s (and (pair? form) (<pair>-source form)))) (and (= <source-span> (type-of s)) s)))

(define-function maru-lines-read (text path)	; the forms text holds; an error names the file it can't read
  (let ((parser (text-parser-for-on <maru-lines> text)))
    (set (<maru-lines>-path parser) path)
    (set (<maru-lines>-starts parser) (maru-lines-starts text))
    (or ($file parser) (error "maru-lines: can't read " path))
    (<text-parser>-result parser)))
