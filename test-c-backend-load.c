
error: undefined variable: use-arm64-backend
[32m[?7l...         [0m use-arm64-backend
[?7h[32m[?7lcore/compiler/emit.l:497[0m (use-arm64-backend)
[?7h[32m[?7lcore/compiler/emit.l:495[0m (if (defined? (quote __arm64__)) (use-arm64-backend) (if (or (defined? (quote __x86_64__)) (defined? (quote __i386__))) (set *emit-backend* (quote asm)) (use-c-backend)))
[?7h[32m[?7lcore/compiler/emit.l:493[0m (let ((env *globals*)) (if (defined? (quote __arm64__)) (use-arm64-backend) (if (or (defined? (quote __x86_64__)) (defined? (quote __i386__))) (set *emit-backend* (quote asm)) (use-c-backend))) (set *globals* (oop-at (%typecheck <env> env) 0)) (gen-env env))
[?7h[32m[?7lcore/compiler/emit.l:492[0m (lambda (*env*) (let ((env *globals*)) (if (defined? (quote __arm64__)) (use-arm64-backend) (if (or (defined? (quote __x86_64__)) (defined? (quote __i386__))) (set *emit-backend* (quote asm)) (use-c-backend))) (set *globals* (oop-at (%typecheck <env> env) 0)) (gen-env env)))
[?7h[32m[?7lcore/compiler/emit.l:492[0m (form (lambda (*env*) (let ((env *globals*)) (if (defined? (quote __arm64__)) (use-arm64-backend) (if (or (defined? (quote __x86_64__)) (defined? (quote __i386__))) (set *emit-backend* (quote asm)) (use-c-backend))) (set *globals* (oop-at (%typecheck <env> env) 0)) (gen-env env))))
[?7h[32m[?7lcore/compiler/emit.l:492[0m (define compile-end (form (lambda (*env*) (let ((env *globals*)) (if (defined? (quote __arm64__)) (use-arm64-backend) (if (or (defined? (quote __x86_64__)) (defined? (quote __i386__))) (set *emit-backend* (quote asm)) (use-c-backend))) (set *globals* (oop-at (%typecheck <env> env) 0)) (gen-env env)))))
[?7h