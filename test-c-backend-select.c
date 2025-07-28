
error: undefined variable: select-backend
[32m[?7l...         [0m select-backend
[?7h[32m[?7lcore/compiler/emit.l:495[0m (select-backend ())
[?7h[32m[?7lcore/compiler/emit.l:493[0m (let ((env *globals*)) (select-backend ()) (set *globals* (oop-at (%typecheck <env> env) 0)) (gen-env env))
[?7h[32m[?7lcore/compiler/emit.l:492[0m (lambda (*env*) (let ((env *globals*)) (select-backend ()) (set *globals* (oop-at (%typecheck <env> env) 0)) (gen-env env)))
[?7h[32m[?7lcore/compiler/emit.l:492[0m (form (lambda (*env*) (let ((env *globals*)) (select-backend ()) (set *globals* (oop-at (%typecheck <env> env) 0)) (gen-env env))))
[?7h[32m[?7lcore/compiler/emit.l:492[0m (define compile-end (form (lambda (*env*) (let ((env *globals*)) (select-backend ()) (set *globals* (oop-at (%typecheck <env> env) 0)) (gen-env env)))))
[?7h