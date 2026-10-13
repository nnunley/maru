#!/bin/sh
# Behavior tests for the demos: each case runs a program, then asserts what
# it should compute.  Expected values are derived here where possible.
#
#   sh check/check.sh            run every case
#   sh check/check.sh pepsi ...  run the named cases only
#   CHECK_TIMEOUT=N              seconds per command (default 120, minimum 1)

cd "$(dirname "$0")/.." || exit 2

CHECK_TIMEOUT=${CHECK_TIMEOUT:-120}
AWK=${CHECK_AWK:-awk}
T=$(mktemp -d "${TMPDIR:-/tmp}/maru-check.XXXXXX") || exit 2
trap 'rm -rf "$T"' EXIT

passed=0
failed=0
xfailed=0
reason=

# run NAME CMD...: stdout to $T/NAME.out, stderr to $T/NAME.err, stdin empty.
run() {
    name=$1; shift
    # macOS has no timeout(1).  perl kills the command and exits 142 itself,
    # so the shell never reports a signal death.
    perl -e '
	my $secs = shift;
	my $pid = fork // die "fork: $!\n";
	if (!$pid) { exec @ARGV or die "cannot exec $ARGV[0]: $!\n" }
	$SIG{ALRM} = sub { kill "KILL", $pid; waitpid $pid, 0; exit 142 };
	alarm $secs;
	waitpid $pid, 0;
	exit($? & 127 ? 128 + ($? & 127) : $? >> 8);
    ' "$CHECK_TIMEOUT" "$@" </dev/null >"$T/$name.out" 2>"$T/$name.err"
    rc=$?
    case $rc in
	0)   reason= ;;
	142) reason="timed out after ${CHECK_TIMEOUT}s" ;;
	*)   if [ $rc -gt 128 ]; then reason="killed by signal $((rc - 128))"; else reason="exit $rc"; fi
	     err=$(tail -n 1 "$T/$name.err")
	     [ -n "$err" ] || err=$(tail -n 1 "$T/$name.out")
	     [ -z "$err" ] || reason="$reason: $err" ;;
    esac
    return $rc
}

pass() { echo "PASS $1"; passed=$((passed + 1)); }
xfail() { echo "XFAIL $1: $2"; xfailed=$((xfailed + 1)); }
fail() { echo "FAIL $1: $2"; failed=$((failed + 1)); }

# assert NAME FILE [AWK-OPTIONS] PROGRAM: run an awk assertion script over
# FILE.  It prints nothing on success, or one line describing the first
# failed assertion.  An awk that fails to run is a FAIL, never a PASS.
assert() {
    name=$1; file=$2; shift 2
    out=$($AWK "$@" "$file" 2>&1); st=$?
    if [ $st -ne 0 ]; then fail "$name" "assertion script failed (awk exit $st): $out"
    elif [ -n "$out" ]; then fail "$name" "$out"
    else pass "$name"; fi
}

# FFT: testFFT's signal is a cosine at bin 2 (amplitude 1.0) plus a sine at
# bin 6 (amplitude 0.75), so the power spectrum peaks at 1.0 and 0.5625.
case_pepsi() {
    run pepsi ./eval repl.l test-pepsi.l || { fail pepsi "$reason"; return; }
    assert pepsi "$T/pepsi.out" '
	/^correlated power spectrum:/ { in_block = 1; next }
	in_block && /^ *[0-9.]+ \|/ {
	    value = $1 + 0
	    if (value == 0) { baseline = 1; exit }
	    cols = substr($0, index($0, "|") + 1, 33)
	    for (c = 0; c <= 32; c++)
		if (substr(cols, c + 1, 1) == "*" && value > h[c]) h[c] = value
	}
	END {
	    if (!baseline) { print "power spectrum graph not found"; exit }
	    want[2] = 1.0; want[6] = 0.5625; tol = 0.075
	    for (c = 0; c <= 32; c++) {
		if (c in want) {
		    if (h[c] < want[c] - tol || h[c] > want[c] + tol) {
			printf "bin %d height %g, expected %g+-%g\n", c, h[c], want[c], tol
			exit
		    }
		} else if (h[c] > 0) {
		    printf "bin %d height %g, expected the baseline\n", c, h[c]
		    exit
		}
	    }
	}'
}

# Ruby, not the @( ... ) Lisp escape: 1 + 2 * 3 + 5 uses the + and * methods
# the program defines on <long>; foo(1, 2) defines and calls a method.
case_maruby() {
    run maruby ./eval maruby.l || { fail maruby "$reason"; return; }
    assert maruby "$T/maruby.out" '
	$0 == " => 12" && !twelve { twelve = NR }
	$0 == " => 3" { three = NR }
	END {
	    if (!twelve)	    print "no \" => 12\" for 1 + 2 * 3 + 5"
	    else if (three < twelve) print "no \" => 3\" for foo(1, 2) after \" => 12\""
	}'
}

# Left recursion in PEG: Bryan Ford's grammars match or reject as listed (the
# file's own OUTPUT comment predates the T case and is stale), and the
# expression grammar builds a left-associative tree over 0..9.
case_recursion() {
    run recursion ./eval repl.l test-recursion.l || { fail recursion "$reason"; return; }
    assert recursion "$T/recursion.out" '
	BEGIN {
	    n = split("could not match input|input matched: \"a\"|input matched: \"\"|input matched: \"a\"|input matched: \"aaa\"|input matched: \"aaaaaaaaaaaaa\"", want, "|")
	    tree = 0; for (d = 1; d <= 9; d++) tree = "(add " tree " " d ")"
	}
	/^could not match input$/ || /^input matched: / { got[++m] = $0 }
	NF { last = $0 }
	END {
	    for (i = 1; i <= n; i++)
		if (got[i] != want[i]) { printf "match %d: got [%s], expected [%s]\n", i, got[i], want[i]; exit }
	    if (m != n) { printf "%d match results, expected %d\n", m, n; exit }
	    if (last != tree) printf "tree %s, expected %s\n", last, tree
	}'
}

# A language built at the REPL: its for loops print the 10x10 multiplication
# table, and nfibs(n) = nfibs(n-1) + nfibs(n-2) + 1 equals 2*fib(n+1) - 1.
case_repl() {
    run repl ./eval repl.l test-repl.l || { fail repl "$reason"; return; }
    assert repl "$T/repl.out" -F '\t' '
	{ line[NR] = $0 }
	/^nfibs\(15\) is / { at = NR }
	END {
	    if (!at) { print "no nfibs(15) line"; exit }
	    for (i = 1; i <= 10; i++) {
		n = split(line[at - 11 + i], f, "\t")
		for (j = 1; j <= 10; j++)
		    if (f[j] != i * j) { printf "table row %d col %d is [%s], expected %d\n", i, j, f[j], i * j; exit }
	    }
	    a = 1; b = 1; for (k = 3; k <= 16; k++) { t = a + b; a = b; b = t }
	    if (line[at] != "nfibs(15) is " (2 * b - 1)) printf "[%s], expected nfibs(15) is %d\n", line[at], 2 * b - 1
	}'
}

# Generated PEG matcher: the grammar accepts letters, ",", " ", "(" and ")",
# so matching stops at the ".", and the match is the text before it.
case_pegen() {
    run pegen ./eval test-pegen.k || { fail pegen "$reason"; return; }
    assert pegen "$T/pegen.out" -v input='hello, (parsing) world.' '
	BEGIN { p = index(input, ".") - 1 }
	$0 == "matched " p { matched = 1 }
	NF { last = $0 }
	END {
	    if (!matched) printf "no \"matched %d\" line\n", p
	    else if (last != substr(input, 1, p)) printf "result [%s], expected [%s]\n", last, substr(input, 1, p)
	}'
}

# Earley parsing of 1+2*3 with both grammars: "+" at the top, "*" nested
# under its right operand, and the leaves 1, 2, 3 in order.
case_earley() {
    run earley ./eval test-earley.k || { fail earley "$reason"; return; }
    assert earley "$T/earley.out" '
	function check(   leaves) {
	    if (!block || bad) return
	    bad = 1
	    leaves = leaf[1] leaf[2] leaf[3]
	    if (nleaf != 3 || leaves != "123") { printf "derivation %d leaves [%s], expected [123]\n", block, leaves; exit }
	    if (!plus || !star || plus_indent >= star_indent) { printf "derivation %d: \"*\" is not nested under \"+\"\n", block; exit }
	    if (star < one) { printf "derivation %d: \"*\" is not under the right operand of \"+\"\n", block; exit }
	    bad = 0
	}
	/^derivation:/ { check(); block++; nleaf = plus = star = one = 0; next }
	block && /^ *T -> "[0-9]"$/ {
	    d = $0; sub(/^ *T -> "/, "", d); sub(/"$/, "", d)
	    leaf[++nleaf] = d
	    if (d == "1") one = NR
	}
	block && /"\+"/ { plus = NR; plus_indent = match($0, /[^ ]/) }
	block && /"\*"/ { star = NR; star_indent = match($0, /[^ ]/) }
	END {
	    check()
	    if (!bad && block != 2) printf "%d derivations, expected 2\n", block
	}'
}

# ir2_build NAME FILE.k: compile a Maru program to C with the ir2 C backend,
# then to $T/NAME with cc.  On failure, $reason names the stage.
ir2_build() {
    run "$1_gen" ./eval2 ir-gen-c.k maru.k "$2" || { reason="generating C: $reason"; return 1; }
    cp "$T/$1_gen.out" "$T/$1.c"
    run "$1_cc" cc -fno-builtin -w -o "$T/$1" "$T/$1.c" -ldl || { reason="compiling C: $reason"; return 1; }
}

# The ir2 C backend: maru-test.k's sieve prints the primes below its argument,
# and its struct code sets x = 42 and y = 666, sums them, then doubles both.
# The two lines after the primes read uninitialized memory, so they are skipped.
case_maru_test() {
    ir2_build maru_test maru-test.k || { fail maru_test "$reason"; return; }
    run maru_test "$T/maru_test" 32 || { fail maru_test "running: $reason"; return; }
    assert maru_test "$T/maru_test.out" -v n=32 -v x=42 -v y=666 '
	BEGIN {
	    for (i = 2; i < n; i++) if (!composite[i]) { primes = primes " " i; for (k = i * i; k < n; k += i) composite[k] = 1 }
	    want[1] = "print-foo: " x " " y
	    want[2] = "sum is " (x + y)
	    want[3] = "print-foo: " (2 * x) " " (2 * y)
	}
	NR == 1 { got = ""; for (i = 1; i <= NF; i++) got = got " " $i
		  if (got != primes) { printf "primes [%s], expected [%s]\n", got, primes; bad = 1; exit } }
	$0 == want[m + 1] { m++ }
	END {
	    if (!bad && m < 3) printf "missing \"%s\" (in order)\n", want[m + 1]
	}'
}

# osdefs.k must describe this machine: every "integer X?" probe listed in
# system.osdefs is defined exactly when the C compiler predefines X, and the
# host's architecture macro is among them.
case_osdefs() {
    run osdefs_macros cc -dM -E -x c /dev/null || { fail osdefs "listing compiler macros: $reason"; return; }
    case $(uname -m) in
	arm64|aarch64) arch=__aarch64__ ;;
	x86_64)        arch=__x86_64__ ;;
	*)             arch= ;;
    esac
    assert osdefs osdefs.k -v specfile=system.osdefs -v macros="$T/osdefs_macros.out" -v arch="$arch" '
	BEGIN {
	    while ((getline line < macros) > 0) { split(line, w, " "); predefined[w[2]] = 1 }
	    while ((getline line < specfile) > 0)
		if (line ~ /^integer/) {
		    n = split(line, w, /[ \t]+/)
		    for (i = 2; i <= n; i++) if (w[i] ~ /\?$/) { sub(/\?$/, "", w[i]); probe[w[i]] = 1 }
		}
	}
	/^\(define(-constant)? __[A-Za-z0-9_]+__ / { name = $2; defined[name] = 1 }
	END {
	    if (arch != "" && !(arch in probe)) { printf "system.osdefs does not probe %s\n", arch; exit }
	    for (p in probe)
		if ((p in predefined) != (p in defined)) {
		    printf "%s: compiler %s it, osdefs.k %s it\n", p, (p in predefined) ? "defines" : "does not define", (p in defined) ? "defines" : "does not define"
		    exit
		}
	}'
}

# The bootstrap: system.osdefs.c is checked in so a fresh checkout can build
# osdefs.k with only a C compiler.  It must be current (regenerating it from
# system.osdefs with the current grammar reproduces it exactly), and compiling
# and running it alone must produce the osdefs.k everything else uses.
case_osdefs_bootstrap() {
    run osdefs_grammar make -s osdefs.g.l || { fail osdefs_bootstrap "building osdefs.g.l: $reason"; return; }
    run osdefs_regen ./eval compile-osdefs.l system.osdefs || { fail osdefs_bootstrap "regenerating: $reason"; return; }
    cmp -s "$T/osdefs_regen.out" system.osdefs.c ||
	{ fail osdefs_bootstrap "system.osdefs.c is stale; run make system.osdefs.c and commit it"; return; }
    run osdefs_cc cc -o "$T/osdefs-bootstrap" system.osdefs.c || { fail osdefs_bootstrap "compiling system.osdefs.c: $reason"; return; }
    run osdefs_run "$T/osdefs-bootstrap" || { fail osdefs_bootstrap "running system.osdefs.c: $reason"; return; }
    if cmp -s "$T/osdefs_run.out" osdefs.k; then pass osdefs_bootstrap
    else fail osdefs_bootstrap "system.osdefs.c produces a different osdefs.k; rebuild with make osdefs.k"; fi
}

# ir2 must lay out every C type exactly as osdefs.k measured it.  For each
# type osdefs.k describes, generate a Maru program printing sizeof T,
# sizeof struct { char c; T x; } (padding before x exposes T's alignment) and
# sizeof struct { T x; char c; } (tail padding keeps arrays aligned; read
# through the sizeof-<name> constant define-struct generates), and
# derive the expected values from sizeof-T and alignof-T.
case_ir2_sizes() {
    set -- char:char short:short int:int long:long int32:int32 int64:int64 \
	   float:float double:double 'void *:pointer'
    {
	echo '(define (printf (int char * ...) *) (extern printf))'
	i=0; for t in "$@"; do i=$((i + 1)); echo "(define-struct <padded-$i> ((c char) (x ${t%%:*})))"; done
	i=0; for t in "$@"; do i=$((i + 1)); echo "(define-struct <tailed-$i> ((x ${t%%:*}) (c char)))"; done
	echo '(define-function main int ((argc int) (argv char * *))'
	i=0; for t in "$@"; do i=$((i + 1)); echo "  (printf \"${t##*:} %d %d %d\\n\" (sizeof ${t%%:*}) (sizeof struct <padded-$i>) sizeof-<tailed-$i>)"; done
	echo '  (return 0))'
    } >"$T/ir2-sizes.k"
    for t in "$@"; do echo "${t##*:}"; done >"$T/ir2-sizes.types"
    ir2_build ir2_sizes "$T/ir2-sizes.k" || { fail ir2_sizes "$reason"; return; }
    run ir2_sizes "$T/ir2_sizes" || { fail ir2_sizes "running: $reason"; return; }
    assert ir2_sizes "$T/ir2_sizes.out" -v osdefs=osdefs.k -v types="$T/ir2-sizes.types" '
	BEGIN {
	    while ((getline line < osdefs) > 0)
		if (line ~ /^\(define-constant (sizeof|alignof)-/) {
		    split(line, w, /[ ()]+/); name = w[3]; sub(/^(sizeof|alignof)-/, "", name)
		    if (w[3] ~ /^sizeof/) size[name] = w[4] + 0; else align[name] = w[4] + 0
		}
	    while ((getline t < types) > 0) want[++n] = t
	}
	{ got[$1] = $2 " " $3 " " $4 }
	END {
	    for (i = 1; i <= n; i++) {
		t = want[i]
		if (!(t in size)) { printf "osdefs.k has no sizeof-%s\n", t; exit }
		a = align[t]; padded = int((a + size[t] + a - 1) / a) * a; tailed = int((size[t] + 1 + a - 1) / a) * a
		if (got[t] != size[t] " " padded " " tailed) {
		    printf "%s: ir2 says sizes [%s], osdefs.k implies [%d %d %d]\n", t, got[t], size[t], padded, tailed
		    exit
		}
	    }
	}'
}

# ir2 pointer arithmetic is unscaled (maru-check.k): adding an integer of any
# width to a pointer moves it by that many bytes.  A long * base would show
# C-style scaling as 8x; each offset is tried as +3 and -3.
case_ir2_offsets() {
    set -- char short int long int32 int64
    {
	echo '(define (printf (int char * ...) *) (extern printf))'
	echo '(define (malloc (void * long) *) (extern malloc))'
	echo '(define-function main int ((argc int) (argv char * *))'
	echo '  (let (((q long *) (cast (malloc 64) long *)))'
	for t in "$@"; do
	    for n in 3 -3; do
		echo "    (let (((n $t) $n)) (printf \"$t %ld\\n\" (- (cast (+ q n) long) (cast q long))))"
	    done
	done
	echo '  )'
	echo '  (return 0))'
    } >"$T/ir2-offsets.k"
    for t in "$@"; do echo "$t 3"; echo "$t -3"; done >"$T/ir2-offsets.expected"
    ir2_build ir2_offsets "$T/ir2-offsets.k" || { fail ir2_offsets "$reason"; return; }
    run ir2_offsets "$T/ir2_offsets" || { fail ir2_offsets "running: $reason"; return; }
    assert ir2_offsets "$T/ir2_offsets.out" -v expected="$T/ir2-offsets.expected" '
	{ got[NR] = $0 }
	END {
	    n = 0
	    while ((getline line < expected) > 0)
		if (got[++n] != line) { printf "[%s], expected [%s] bytes\n", got[n], line; exit }
	    if (NR != n) printf "%d lines, expected %d\n", NR, n
	}'
}

# Upstream's own test of the ir2 language: maru-check.k asserts as it goes
# (aborting on the first failure) and prints one "... ok" line per section.
case_maru_check() {
    ir2_build maru_check maru-check.k || { fail maru_check "$reason"; return; }
    run maru_check "$T/maru_check" || { fail maru_check "running: $reason"; return; }
    assert maru_check "$T/maru_check.out" '
	BEGIN { n = split("bytes words ints floats structs pointers", want, " ") }
	$0 == want[m + 1] " ok" { m++ }
	END { if (m < n) printf "missing \"%s ok\" (in order)\n", want[m + 1] }'
}

# The GC written in Maru, compiled through the ir2 C backend.  Its main builds
# a 256-cell list 10000 times, reporting every 1000 iterations and once more
# after a final collection with no roots.  Each cell is one allocation.
case_maru_gc() {
    ir2_build maru_gc maru-gc.k || { fail maru_gc "$reason"; return; }
    run maru_gc "$T/maru_gc" || { fail maru_gc "running: $reason"; return; }
    assert maru_gc "$T/maru_gc.out" -v iterations=10000 -v cells=256 -v every=1000 '
	# GC: <used> used, <free> free, <n> allocations, <n> collections, <n> live
	/^GC: / { k++; used[k] = $2; free[k] = $4; allocs[k] = $6; colls[k] = $8; live[k] = $10 }
	END {
	    reports = iterations / every + 1
	    if (k != reports) { printf "%d GC reports, expected %d\n", k, reports; exit }
	    for (i = 1; i < k; i++)
		if (allocs[i] != (i - 1) * every * cells) { printf "report %d: %d allocations, expected %d\n", i, allocs[i], (i - 1) * every * cells; exit }
	    if (allocs[k] != iterations * cells) { printf "final: %d allocations, expected %d\n", allocs[k], iterations * cells; exit }
	    for (i = 2; i <= k; i++) {
		if (colls[i] < colls[i - 1]) { printf "collections went down at report %d\n", i; exit }
		if (used[i] + free[i] != used[2] + free[2]) { printf "heap size changed at report %d: %d, was %d\n", i, used[i] + free[i], used[2] + free[2]; exit }
	    }
	    if (colls[k] < 1) { print "no collections happened"; exit }
	    if (used[k] != 0 || live[k] != 0) printf "final: %d bytes used, %d live, expected 0 and 0\n", used[k], live[k]
	}'
}

# Harness self-test, run only when named: a hung command must be cut off.
case_selftest_hang() {
    if run selftest_hang sleep 5; then
	fail selftest_hang "sleep 5 was not interrupted"
    elif [ "$rc" = 142 ]; then
	pass selftest_hang
    else
	fail selftest_hang "expected a timeout, got: $reason"
    fi
}

[ $# -gt 0 ] || set -- osdefs_bootstrap osdefs pepsi recursion repl pegen earley maruby maru_test ir2_sizes ir2_offsets maru_check maru_gc
for c in "$@"; do
    command -v "case_$c" >/dev/null 2>&1 || { fail "$c" "unknown case"; continue; }
    "case_$c"
done
echo "$passed passed, $failed failed, $xfailed expected failures"
[ "$failed" -eq 0 ]
