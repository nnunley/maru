;;; test-minimal-pic.l - Minimal PIC test

(require "ir.k")

(println "=== Minimal PIC Test ===")

;; Simple function to test PIC concepts
(define-function test-pic-address-calculation ()
  "Test the core PIC address calculation"
  (let ((page-offset 4096))  ; One page offset
    (let ((immlo (& page-offset 3))
          (immhi (& (>> page-offset 12) 0x7FFFF)))
      (println "Page offset: " page-offset)
      (println "immlo (bits 1:0): " immlo)
      (println "immhi (bits 32:12): " immhi))))

(test-pic-address-calculation)

(println "\n=== Minimal Test Complete ===")