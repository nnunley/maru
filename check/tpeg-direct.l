;;; Direct list patterns change no lowering: every intent of check/native-images.l's units, and given LOADER (as
;;; native_nile writes it) of the Nile runtime with Gezira too, lowers to the same forms through native-arm64.g and
;;; native-x64.g compiled with direct patterns (as built) and without (*tp-direct* off, recompiled here).  The check
;;; leaves Gezira out, which is most of the time; native_nile compiles it.  The last line is "tpeg direct ok".
;;;   ./eval2 check/tpeg-direct.l [LOADER]
(define loader (and *arguments* (pop *arguments*)))	; before native.l: maru.k loads any arguments left
(require "native.l")
(define compile-tpeg-definitions-only 1)
(require "compile-tpeg.l")
(load "check/native-image-units.l")

;; each unit's functions' intents, in order, compiled for an ISA with its own count of held registers (as a process on it compiles)
(define units ())
(define-function compile-units (isa)
  (set *native-held-count* (list-length (abi isa (quote held))))
  (set units ())
  (list-do path (concat-list (native-image-paths) (if loader (list loader) ()))
    (push units (car (native-symbols (<native-unit>-functions (native-compile-file path))))))
  (set units (list-reverse! units)))

(define-function lowered (grammar)	; every function's forms, as grammar lowers them
  (set native-skips 0) (set native-x64-skips 0)	; fresh branch labels numbered from here, alike in both passes
  (map (lambda (fs) (map (lambda (f) (cons (car f) (parse-source grammar $program (cadr f)))) fs)) units))
(define-function rules-of (path) (cdr (tpeg-parse-whole-file path)))

(define failures 0)
(define-function compare (name grammar path)
  (let ((direct (lowered grammar)))
    (set *tp-direct* ())
    (tpeg-define-rules grammar (rules-of path))
    (let ((streamed (lowered grammar)) (n 0))
      (set *tp-direct* 1)
      (tpeg-define-rules grammar (rules-of path))
      (map (lambda (du su)
	     (map (lambda (d s)
		    (set n (+ n 1))
		    (or (equal d s)
			(let () (set failures (+ failures 1)) (println name ": " (car d) " lowers differently:\n  " d "\n  " s))))
		  du su))
	   direct streamed)
      (println name ": " n " functions"))))
(compile-units (quote arm64))
(compare "native-arm64.g" <native-arm64> "native-arm64.g")
(compile-units (quote x64))
(compare "native-x64.g" <native-x64> "native-x64.g")
(or (= 0 failures) (error "tpeg-direct: " failures " functions lowered differently"))
(println "tpeg direct ok")
