;;; emit-dispatcher.l -- Backend dispatcher for Maru compiler
;;;
;;; This file provides the core emit infrastructure and dispatches to
;;; the appropriate backend based on environment variables or platform detection.

(require "osdefs.k")

;; Load core emit infrastructure first
(load "core/compiler/emit-core.l")

;; For eval2.c generation, always use C backend
;; (This is hardcoded for now since we can't pass variables on command line)
(define *force-c-backend* 1)

;; Select backend based on platform
(cond
  ;; For eval2.c generation, always use C backend
  ((defined? '*force-c-backend*)
   (println "; Maru emit dispatcher: C backend forced for eval2.c generation")
   (load "core/compiler/emit-gc-c.l"))
  
  ;; ARM64 platforms
  ((or (defined? '__arm64__) (defined? '__aarch64__))
   (println "; Maru emit dispatcher: ARM64 backend selected")
   (load "core/compiler/emit-arm64.l"))
  
  ;; x86/x86-64 platforms
  ((or (defined? '__x86_64__) (defined? '__i386__))
   (println "; Maru emit dispatcher: x86 backend selected")
   (load "core/compiler/emit-x86.l"))
  
  ;; Default to C backend for unknown platforms
  (else
   (println "; Maru emit dispatcher: C backend selected (default)")
   (load "core/compiler/emit-gc-c.l")))