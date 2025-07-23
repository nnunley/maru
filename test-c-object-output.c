
error: undefined variable: c-param-name
[32m[?7l...         [0m c-param-name
[?7h[32m[?7lcore/compiler/emit.l:156[0m (c-param-name param)
[?7h[32m[?7lcore/compiler/emit.l:156[0m (print "oop " (c-param-name param))
[?7h[32m[?7lcore/compiler/emit.l:153[0m (let ((param (car _list_))) (and (not first) (print ", ")) (set first ()) (print "oop " (c-param-name param)))
[?7h[32m[?7lcore/compiler/emit.l:153[0m (while _list_ (let ((param (car _list_))) (and (not first) (print ", ")) (set first ()) (print "oop " (c-param-name param))) (set _list_ (cdr _list_)))
[?7h[32m[?7lcore/compiler/emit.l:153[0m (let ((_list_ params)) (while _list_ (let ((param (car _list_))) (and (not first) (print ", ")) (set first ()) (print "oop " (c-param-name param))) (set _list_ (cdr _list_))))
[?7h[32m[?7lcore/compiler/emit.l:152[0m (let ((first 1)) (let ((_list_ params)) (while _list_ (let ((param (car _list_))) (and (not first) (print ", ")) (set first ()) (print "oop " (c-param-name param))) (set _list_ (cdr _list_)))))
[?7h[32m[?7lcore/compiler/emit.l:148[0m (lambda (gen name params) "Begin a C function definition" (set-oop-at (%typecheck <c-generator> gen) 6 name) (print "static oop " name "(") (let ((first 1)) (let ((_list_ params)) (while _list_ (let ((param (car _list_))) (and (not first) (print ", ")) (set first ()) (print "oop " (c-param-name param))) (set _list_ (cdr _list_))))) (println ")") (println "{") (set-oop-at (%typecheck <c-generator> gen) 0 (+ 1 (oop-at (%typecheck <c-generator> gen) 0))))
[?7h[32m[?7lcore/compiler/emit.l:148[0m (define c-begin-function (lambda (gen name params) "Begin a C function definition" (set-oop-at (%typecheck <c-generator> gen) 6 name) (print "static oop " name "(") (let ((first 1)) (let ((_list_ params)) (while _list_ (let ((param (car _list_))) (and (not first) (print ", ")) (set first ()) (print "oop " (c-param-name param))) (set _list_ (cdr _list_))))) (println ")") (println "{") (set-oop-at (%typecheck <c-generator> gen) 0 (+ 1 (oop-at (%typecheck <c-generator> gen) 0)))))
[?7h