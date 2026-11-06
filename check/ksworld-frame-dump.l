;;; check/ksworld-frame-dump.l -- KSWorld.ks's first frame as the fill calls ksworld-render makes, printed to stdout:
;;; one line per gezira-fill-path call, "F", the matrix (a b c d e f), the paint (alpha red green blue), the float
;;; count, then the floats. The Gezira records and paints nothing, so the runtime is not run. The frame check
;;; (gezira_rerender, check/check.l) renders these calls on the Maru runtime. Needs MARU_DBJR (the dbjr documents).
(require "ksworld-run.l")
(require "check/temp.l")
(define dir (env-var "MARU_DBJR"))
(set *ks-font-path* (cons (concat-string dir "/fonts") *ks-font-path*))
(define-structure <dumper> (count))
(define-method gezira-fill-path <dumper> (m width height paint floats count)
  (set self.count (+ 1 self.count))
  (print "F " (<ks-matrix>-a m) " " (<ks-matrix>-b m) " " (<ks-matrix>-c m) " " (<ks-matrix>-d m) " " (<ks-matrix>-e m) " " (<ks-matrix>-f m) " ")
  (print (cadr paint) " " (caddr paint) " " (cadddr paint) " " (car (cddddr paint)) " " count)
  (let ((i 0))
    (while (< i count)
      (print " " (float-at floats i))
      (set i (+ i 1))))
  (println ""))
(let* ((r (ksworld-run (concat-string dir "/KSWorld.ks/index.pp") 3))
       (s (ksworld-session r))
       (g (new <dumper> 0)))
  (ksworld-render (<ksworld-session>-root s) g 1024 768)
  (println "calls " (<dumper>-count g)))
