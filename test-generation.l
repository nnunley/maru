;; Simple test for generation tracking
;; Usage: ./eval boot.l test-generation.l

(println "🔍 Testing generation tracking...")

(if (defined? '*maru-generation*)
    (begin
      (println "✅ *maru-generation* is defined: " *maru-generation*)
      (println "✅ *maru-version* is defined: " *maru-version*)
      (println "📊 Generation system working!"))
    (println "❌ Generation tracking not available"))

(println "🏁 Test complete")