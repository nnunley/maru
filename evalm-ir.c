
[31;1merror: file not found or empty: ir2.k[m

error: aborting
[32m[?7lboot2.l:24  [0m (abort)
[?7h[32m[?7lboot2.l:1067[0m (error "file not found or empty: " name)
[?7h[32m[?7lboot2.l:1067[0m (or exps (error "file not found or empty: " name))
[?7h[32m[?7lboot2.l:1066[0m (let ((exps (find-and-read name))) (or exps (error "file not found or empty: " name)) (let ((_list_ exps)) (while _list_ (let ((expr (car _list_))) (pval expr)) (set _list_ (cdr _list_)))))
[?7h[32m[?7lboot2.l:1076[0m (load name)
[?7h[32m[?7lboot2.l:1074[0m (let () (set *loaded* (cons name *loaded*)) (load name))
[?7h[32m[?7lboot2.l:1073[0m (or (member? name *loaded*) (let () (set *loaded* (cons name *loaded*)) (load name)))
[?7h[32m[?7lcore/compiler/ir-gen-c.k:1[0m (require "ir2.k")
[?7h