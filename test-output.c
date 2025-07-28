
error: cannot apply: [34m<extern>[m
[32m[?7lcore/compiler/emit.l:1064[0m (getenv-fn "MARU_EMIT_BACKEND")
[?7h[32m[?7lcore/compiler/emit.l:1064[0m (Fixed<and> getenv-fn (getenv-fn "MARU_EMIT_BACKEND"))
[?7h[32m[?7lcore/compiler/emit.l:1064[0m (select-backend (Fixed<and> getenv-fn (getenv-fn "MARU_EMIT_BACKEND")))
[?7h[32m[?7lcore/compiler/emit.l:1063[0m (Fixed<let> ((getenv-fn (Fixed<and> (defined? (Fixed<quote> extern)) (extern (Fixed<quote> getenv))))) (select-backend (Fixed<and> getenv-fn (getenv-fn "MARU_EMIT_BACKEND"))))
[?7h[32m[?7lcore/compiler/emit.l:1067[0m (auto-select-backend)
[?7h