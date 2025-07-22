
error: undefined variable: c-gen-pair-expr
[32m[?7l...         [0m c-gen-pair-expr
[?7h[32m[?7lemit-c-high.l:62[0m (c-gen-pair-expr expr)
[?7h[32m[?7lemit-c-high.l:49[0m (if (pair? expr) (c-gen-pair-expr expr) "nil")
[?7h[32m[?7lemit-c-high.l:49[0m (if (variable? expr) (let ((value (oop-at (%typecheck <variable> expr) 1))) (if (extern? value) (concat-string "((oop)" (oop-at (%typecheck <variable> expr) 0) ")") (c-var-name expr))) (if (pair? expr) (c-gen-pair-expr expr) "nil"))
[?7h[32m[?7lemit-c-high.l:49[0m (if (string? expr) (concat-string "(oop)\"" expr "\"") (if (variable? expr) (let ((value (oop-at (%typecheck <variable> expr) 1))) (if (extern? value) (concat-string "((oop)" (oop-at (%typecheck <variable> expr) 0) ")") (c-var-name expr))) (if (pair? expr) (c-gen-pair-expr expr) "nil")))
[?7h[32m[?7lemit-c-high.l:49[0m (if (long? expr) (concat-string "LONG(" (long->string expr) ")") (if (string? expr) (concat-string "(oop)\"" expr "\"") (if (variable? expr) (let ((value (oop-at (%typecheck <variable> expr) 1))) (if (extern? value) (concat-string "((oop)" (oop-at (%typecheck <variable> expr) 0) ")") (c-var-name expr))) (if (pair? expr) (c-gen-pair-expr expr) "nil"))))
[?7h[32m[?7lemit-c-high.l:47[0m (lambda (expr) "Generate C expression and return the expression string" (if (long? expr) (concat-string "LONG(" (long->string expr) ")") (if (string? expr) (concat-string "(oop)\"" expr "\"") (if (variable? expr) (let ((value (oop-at (%typecheck <variable> expr) 1))) (if (extern? value) (concat-string "((oop)" (oop-at (%typecheck <variable> expr) 0) ")") (c-var-name expr))) (if (pair? expr) (c-gen-pair-expr expr) "nil")))))
[?7h[32m[?7lemit-c-high.l:47[0m (define c-gen-expr (lambda (expr) "Generate C expression and return the expression string" (if (long? expr) (concat-string "LONG(" (long->string expr) ")") (if (string? expr) (concat-string "(oop)\"" expr "\"") (if (variable? expr) (let ((value (oop-at (%typecheck <variable> expr) 1))) (if (extern? value) (concat-string "((oop)" (oop-at (%typecheck <variable> expr) 0) ")") (c-var-name expr))) (if (pair? expr) (c-gen-pair-expr expr) "nil"))))))
[?7h[32m[?7lboot.l:996      [0m (eval expr)
[?7h[32m[?7lboot.l:996      [0m (Fixed<let> ((result (eval expr))) (Fixed<and> (> (verbose) 1) (println "=> " result)) result)
[?7h[32m[?7lboot.l:1007     [0m (pval expr)
[?7h[32m[?7lboot.l:1007     [0m (Fixed<let> ((expr (car _list_))) (pval expr))
[?7h[32m[?7lboot.l:1007     [0m (Fixed<while> _list_ (Fixed<let> ((expr (car _list_))) (pval expr)) (Fixed<set> _list_ (cdr _list_)))
[?7h[32m[?7lboot.l:1007     [0m (Fixed<let> ((_list_ exps)) (Fixed<while> _list_ (Fixed<let> ((expr (car _list_))) (pval expr)) (Fixed<set> _list_ (cdr _list_))))
[?7h[32m[?7lboot.l:1005     [0m (Fixed<let> ((exps (find-and-read name))) (Fixed<or> exps (error "file not found or empty: " name)) (Fixed<let> ((_list_ exps)) (Fixed<while> _list_ (Fixed<let> ((expr (car _list_))) (pval expr)) (Fixed<set> _list_ (cdr _list_)))))
[?7h[32m[?7lboot.l:1015     [0m (load name)
[?7h[32m[?7lboot.l:1013     [0m (Fixed<let> () (Fixed<set> *loaded* (cons name *loaded*)) (load name))
[?7h[32m[?7lboot.l:1012     [0m (Fixed<or> (member? name *loaded*) (Fixed<let> () (Fixed<set> *loaded* (cons name *loaded*)) (load name)))
[?7h[32m[?7ltest-c-high-simple.l:5[0m (require "emit-c-high.l")
[?7h