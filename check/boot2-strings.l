;;; The string and number operations eval2 dropped, as boot2.l defines them
;;; in Maru, with eval.c's semantics.  Prints "boot2 strings ok" when all hold.

(define failures 0)
(define-form expect (form value)
  `(or (equal ,form ,value)
       (let () (println "FAIL " ',form " => " ,form ", expected " ,value) (set failures (+ failures 1)))))

(expect (string-copy "abcdef" 2 3) "cde")
(expect (string-copy "abc") "abc")
(expect (string-copy "abc" 1) "bc")
(expect (string-copy "abc" 5) "")
(expect (string-copy "abc" 1 9) "bc")
(expect (if (< (string-compare "abc" "abd") 0) (quote yes)) (quote yes))
(expect (string-compare "abc" "abc") 0)
(expect (if (> (string-compare "abd" "abc") 0) (quote yes)) (quote yes))
(expect (string-compare "xabc" "abc" 1 3) 0)
(expect (string-compare "abc" "abx" 0 2) 0)
(expect (long->string 255) "255")
(expect (long->string -7) "-7")
(expect (long->string 0) "0")
(expect (string->long "-42") -42)
(expect (string->long "0xff") 255)
(expect (string->long "017") 15)
(expect (string->long "12abc") 12)

(if (= 0 failures) (println "boot2 strings ok"))
