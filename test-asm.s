
error: undefined variable: c-temp-name
[32m[?7l...         [0m c-temp-name
[?7h[32m[?7lcore/compiler/emit-unified.l:185[0m (c-temp-name self)
[?7h[32m[?7lcore/compiler/emit-unified.l:184[0m (if (= *emit-backend* (quote c)) (c-temp-name self) (oop-at (%typecheck <TI32> self) 0) "(%esp)")
[?7h[32m[?7lcore/compiler/emit-unified.l:183[0m (print (if (= *emit-backend* (quote c)) (c-temp-name self) (oop-at (%typecheck <TI32> self) 0) "(%esp)"))
[?7h[32m[?7l...                             [0m (let () (print (if (= *emit-backend* (quote c)) (c-temp-name self) (oop-at (%typecheck <TI32> self) 0) "(%esp)")))
[?7h[32m[?7l...                             [0m (let () (let () (print (if (= *emit-backend* (quote c)) (c-temp-name self) (oop-at (%typecheck <TI32> self) 0) "(%esp)"))))
[?7h[32m[?7l...                             [0m (lambda (self) (let () (let () (print (if (= *emit-backend* (quote c)) (c-temp-name self) (oop-at (%typecheck <TI32> self) 0) "(%esp)")))))
[?7h[32m[?7lcore/bootstrap/boot.l:552       [0m (eval (cons (Fixed<quote> lambda) (cons args (cons (cons (Fixed<quote> with-instance-accessors) (cons type body)) (Fixed<quote> ())))))
[?7h[32m[?7lcore/bootstrap/boot.l:552       [0m (<selector>-add-method self type (eval (cons (Fixed<quote> lambda) (cons args (cons (cons (Fixed<quote> with-instance-accessors) (cons type body)) (Fixed<quote> ()))))))
[?7h[32m[?7lcore/bootstrap/boot.l:517       [0m (apply (Fixed<or> (array-at (oop-at (%typecheck <selector> self) 1) (type-of (car arguments))) (<selector>-inherit (oop-at (%typecheck <selector> self) 1) (type-of (car arguments))) (oop-at (%typecheck <selector> self) 2)) arguments)
[?7h[32m[?7lcore/compiler/emit-unified.l:183[0m (add-method do-print <TI32> (Fixed<quote> (self)) (Fixed<quote> ((print (if (= *emit-backend* (quote c)) (c-temp-name self) (<TI32>-offset self) "(%esp)")))))
[?7h