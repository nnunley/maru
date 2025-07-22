[32m[?7lboot.l:1002 [0m (read name)
[?7h[32m[?7lboot.l:1001 [0m (Fixed<or> (Fixed<and> *load-path* (read (concat-string *load-path* name))) (read name))
[?7h[32m[?7lboot.l:1005 [0m (find-and-read name)
[?7h[32m[?7lboot.l:1005 [0m (Fixed<let> ((exps (find-and-read name))) (Fixed<or> exps (error "file not found or empty: " name)) (Fixed<let> ((_list_ exps)) (Fixed<while> _list_ (Fixed<let> ((expr (car _list_))) (pval expr)) (Fixed<set> _list_ (cdr _list_)))))
[?7h[32m[?7lboot.l:1015 [0m (load name)
[?7h[32m[?7lboot.l:1013 [0m (Fixed<let> () (Fixed<set> *loaded* (cons name *loaded*)) (load name))
[?7h[32m[?7lboot.l:1012 [0m (Fixed<or> (member? name *loaded*) (Fixed<let> () (Fixed<set> *loaded* (cons name *loaded*)) (load name)))
[?7h[32m[?7lemit.l:7    [0m (require "emit-c.l")
[?7h