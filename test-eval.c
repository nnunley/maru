
error: undefined variable: EMIT_BACKEND
[32m[?7l...         [0m EMIT_BACKEND
[?7h[32m[?7lemit.l:4    [0m (and (defined? (quote EMIT_BACKEND)) EMIT_BACKEND)
[?7h[32m[?7lemit.l:4    [0m (or (and (defined? (quote EMIT_BACKEND)) EMIT_BACKEND) (quote x86))
[?7h[32m[?7lemit.l:4    [0m (define *emit-backend* (or (and (defined? (quote EMIT_BACKEND)) EMIT_BACKEND) (quote x86)))
[?7h[32m[?7lboot.l:996  [0m (eval expr)
[?7h[32m[?7lboot.l:996  [0m (Fixed<let> ((result (eval expr))) (Fixed<and> (> (verbose) 1) (println "=> " result)) result)
[?7h[32m[?7lboot.l:1007 [0m (pval expr)
[?7h[32m[?7lboot.l:1007 [0m (Fixed<let> ((expr (car _list_))) (pval expr))
[?7h[32m[?7lboot.l:1007 [0m (Fixed<while> _list_ (Fixed<let> ((expr (car _list_))) (pval expr)) (Fixed<set> _list_ (cdr _list_)))
[?7h[32m[?7lboot.l:1007 [0m (Fixed<let> ((_list_ exps)) (Fixed<while> _list_ (Fixed<let> ((expr (car _list_))) (pval expr)) (Fixed<set> _list_ (cdr _list_))))
[?7h[32m[?7lboot.l:1005 [0m (Fixed<let> ((exps (find-and-read name))) (Fixed<or> exps (error "file not found or empty: " name)) (Fixed<let> ((_list_ exps)) (Fixed<while> _list_ (Fixed<let> ((expr (car _list_))) (pval expr)) (Fixed<set> _list_ (cdr _list_)))))
[?7h[32m[?7lboot.l:1015 [0m (load name)
[?7h[32m[?7lboot.l:1013 [0m (Fixed<let> () (Fixed<set> *loaded* (cons name *loaded*)) (load name))
[?7h[32m[?7lboot.l:1012 [0m (Fixed<or> (member? name *loaded*) (Fixed<let> () (Fixed<set> *loaded* (cons name *loaded*)) (load name)))
[?7h[32m[?7ltest-c-eval.l:4[0m (require "emit.l")
[?7h