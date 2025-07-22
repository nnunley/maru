
error: eval: undefined variable: data
[32m[?7ldata-stream.k:5[0m (data size)
[?7h[32m[?7ldata-stream.k:5[0m (or (cadr rest) (data size))
[?7h[32m[?7ldata-stream.k:4[0m (let ((coln (or (cadr rest) (data size)))) (let () (let ((_type_ <data-stream>)) (let ((_self_ (allocate _type_ (array-at %structure-sizes _type_)))) (let () (set-oop-at _self_ 0 coln) (set-oop-at _self_ 1 0) (set-oop-at _self_ 2 size) _self_)))))
[?7h[32m[?7ldata-stream.k:4[0m (let ((size (or (car rest) 32))) (let ((coln (or (cadr rest) (data size)))) (let () (let ((_type_ <data-stream>)) (let ((_self_ (allocate _type_ (array-at %structure-sizes _type_)))) (let () (set-oop-at _self_ 0 coln) (set-oop-at _self_ 1 0) (set-oop-at _self_ 2 size) _self_))))))
[?7h[32m[?7ltest-call.k:115[0m (data-stream 8)
[?7h[32m[?7ltest-call.k:115[0m (assembler (data-stream 8))
[?7h[32m[?7ltest-call.k:115[0m (let ((x (assembler (data-stream 8)))) (let ((putchar (new-external-label x "putchar"))) (let ((loop1 (new-local-label x "loop1"))) (let () (let ((pass 0) (_limit_ 2)) (while (< pass _limit_) (set-assembler-pass x pass) (PUSHLr x %EBP) (MOVLrr x %ESP %EBP) (SUBLir x 8 %ESP) (MOVLim x 65 0 %ESP 0 0) (LABEL x loop1) (CALLl x putchar) (ADDLim x 1 0 %ESP 0 0) (CMPLim x (+ 90 1) 0 %ESP 0 0) (JNESl x loop1) (MOVLim x 10 0 %ESP 0 0) (CALLl x putchar) (LEAVE x) (RET x) (set pass (+ pass 1)))) (println (data-stream-position (oop-at (%typecheck <assembler> x) 0)) " bytes generated") (data-stream-truncate (oop-at (%typecheck <assembler> x) 0)) (data-stream-rewind (oop-at (%typecheck <assembler> x) 0)) (let ((p (console-port))) (while (not (data-stream-at-end? (oop-at (%typecheck <assembler> x) 0))) (port-write p (format "%08x" (data-stream-address (oop-at (%typecheck <assembler> x) 0))) "\011") (disassemble-on x p) (port-put p 10))) (println (native-call (data-stream-data (oop-at (%typecheck <assembler> x) 0)) 3 4))))))
[?7h[32m[?7lboot2.l:1052   [0m (eval expr)
[?7h[32m[?7lboot2.l:1052   [0m (let ((result (eval expr))) (and (> (verbose) 1) (println "=> " result)) result)
[?7h[32m[?7lboot2.l:1068   [0m (pval expr)
[?7h[32m[?7lboot2.l:1068   [0m (let ((expr (car _list_))) (pval expr))
[?7h[32m[?7lboot2.l:1068   [0m (while _list_ (let ((expr (car _list_))) (pval expr)) (set _list_ (cdr _list_)))
[?7h[32m[?7lboot2.l:1068   [0m (let ((_list_ exps)) (while _list_ (let ((expr (car _list_))) (pval expr)) (set _list_ (cdr _list_))))
[?7h[32m[?7lboot2.l:1066   [0m (let ((exps (find-and-read name))) (or exps (error "file not found or empty: " name)) (let ((_list_ exps)) (while _list_ (let ((expr (car _list_))) (pval expr)) (set _list_ (cdr _list_)))))
[?7h[32m[?7lmaru.k:299     [0m (load (let ((_list_ *arguments*)) (let ((_head_ (car _list_))) (let () (set *arguments* (cdr _list_)) _head_))))
[?7h[32m[?7lmaru.k:298     [0m (while *arguments* (load (let ((_list_ *arguments*)) (let ((_head_ (car _list_))) (let () (set *arguments* (cdr _list_)) _head_)))))
[?7h