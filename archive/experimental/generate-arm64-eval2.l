;; Generate eval2 as ARM64 assembly
;; This script uses the ARM64 backend to compile eval.l into ARM64 assembly

(load "boot.l")
(load "core/compiler/emit.l")

;; Activate the ARM64 backend before loading eval.l
(use-arm64-backend)
(println ";; ARM64 backend activated")

;; Now load and compile eval.l
;; The compilation will use ARM64 instructions instead of x86
(load "eval.l")

;; The output should be ARM64 assembly code