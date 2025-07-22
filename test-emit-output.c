
error: eval: undefined variable: <variable>
[32m[?7lcore/compiler/emit.l:357[0m (add-method gen <variable> (quote (self comp)) (quote ((let ((value (<variable>-value self))) (if (extern? value) (gen comp LOAD (GI32 (LABEL (concat-symbol (<variable>-name self) (quote $stub))))) (if (temp? value) (gen comp LOAD value) (gen comp LOAD (GI32 (LABEL (<variable>-name self))))))))))
[?7h