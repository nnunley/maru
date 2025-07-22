
error: undefined variable: ir-zero?
[32m[?7l...         [0m ir-zero?
[?7h[32m[?7lir2.k:318   [0m (ir-zero? rhs)
[?7h[32m[?7lir2.k:318   [0m (and (ir-pointer-type? ltype) (ir-zero? rhs))
[?7h[32m[?7lir2.k:315   [0m (or (= ltype rtype) (and (= IR-VOID* ltype) (ir-pointer-type? rtype)) (and (ir-pointer-type? ltype) (= IR-VOID* rtype)) (and (ir-pointer-type? ltype) (ir-zero? rhs)) (ir-can-coerce ltype rhs))
[?7h[32m[?7lir2.k:314   [0m (lambda (ltype rtype rhs) (or (= ltype rtype) (and (= IR-VOID* ltype) (ir-pointer-type? rtype)) (and (ir-pointer-type? ltype) (= IR-VOID* rtype)) (and (ir-pointer-type? ltype) (ir-zero? rhs)) (ir-can-coerce ltype rhs)))
[?7h[32m[?7lir2.k:314   [0m (define ir-can-assign (lambda (ltype rtype rhs) (or (= ltype rtype) (and (= IR-VOID* ltype) (ir-pointer-type? rtype)) (and (ir-pointer-type? ltype) (= IR-VOID* rtype)) (and (ir-pointer-type? ltype) (ir-zero? rhs)) (ir-can-coerce ltype rhs))))
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
[?7h[32m[?7lir-gen-c.k:1[0m (require "ir2.k")
[?7h