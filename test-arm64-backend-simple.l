;; Test ARM64 backend functionality
;; Load dependencies and emit.l
(load "boot.l")
(load "core/compiler/emit.l")

;; Activate ARM64 backend
(println ";; Activating ARM64 backend")
(use-arm64-backend)

;; Test basic emit instructions
(println ";; Testing ARM64 backend emit functions")
(emit TEXT)
(emit GLOBAL "main")
(emit DEFLABEL "main")
(emit ENTER 32)
(emit LOAD LI32 42)
(emit STORE TI32 -8)
(emit LOAD TI32 -8)
(emit ADD TI32 10)
(emit BF "end")
(emit CALL "printf")
(emit DEFLABEL "end")  
(emit LEAVE 32)

(println ";; ARM64 backend test completed")