
[31;1merror: file not found or empty: ir2.k[m
[32m[?7lboot.l:24   [0m (abort)
[?7h[32m[?7lboot.l:1006 [0m (error "file not found or empty: " name)
[?7h[32m[?7lboot.l:1006 [0m (Fixed<or> exps (error "file not found or empty: " name))
[?7h[32m[?7lboot.l:1005 [0m (Fixed<let> ((exps (find-and-read name))) (Fixed<or> exps (error "file not found or empty: " name)) (Fixed<let> ((_list_ exps)) (Fixed<while> _list_ (Fixed<let> ((expr (car _list_))) (pval expr)) (Fixed<set> _list_ (cdr _list_)))))
[?7h[32m[?7lboot.l:1015 [0m (load name)
[?7h[32m[?7lboot.l:1013 [0m (Fixed<let> () (Fixed<set> *loaded* (cons name *loaded*)) (load name))
[?7h[32m[?7lboot.l:1012 [0m (Fixed<or> (member? name *loaded*) (Fixed<let> () (Fixed<set> *loaded* (cons name *loaded*)) (load name)))
[?7h[32m[?7lcore/compiler/ir-gen-c.k:1[0m (require "ir2.k")
[?7h