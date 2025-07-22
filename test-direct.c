
error: undefined variable: compiler
[32m[?7l...         [0m compiler
[?7h[32m[?7ltest-c-direct.l:8[0m (compiler 0)
[?7h[32m[?7ltest-c-direct.l:7[0m (let ((env (environment *globals*)) (comp (compiler 0))) (let ((x (variable (quote x) 0 env 0))) (let ((y (variable (quote y) 0 env 1))) (let ((body (list (quote +) x y))) (let ((defn (list (quote lambda) (list x y) body))) (let ((expr (let ((_type_ <expr>)) (let ((_self_ (allocate _type_ (array-at %structure-sizes _type_)))) _self_)))) (set-oop-at (%typecheck <expr> expr) 1 defn) (gen-definition expr (quote add) comp)))))) (let ((body (list 42))) (let ((defn (list (quote lambda) () body))) (let ((expr (let ((_type_ <expr>)) (let ((_self_ (allocate _type_ (array-at %structure-sizes _type_)))) _self_)))) (set-oop-at (%typecheck <expr> expr) 1 defn) (gen-definition expr (quote main) comp)))))
[?7h