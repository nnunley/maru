;;; Test backend selection integration
;;; This shows how to integrate backend selection with emit.l

;; Load emit.l first
(load "core/compiler/emit.l")

;; Now load backend selection
(load "backend-selection.l")

;; The backend should now be selected based on:
;; 1. MARU_EMIT_BACKEND environment variable
;; 2. Platform detection from osdefs.k

(println)
(println "Backend selection test complete.")