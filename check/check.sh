#!/bin/sh
# Behavior tests for the demos: each case runs a program, then asserts what
# it should compute.  Expected values are derived here where possible.
#
#   sh check/check.sh            run every case
#   sh check/check.sh pepsi ...  run the named cases only
#   CHECK_TIMEOUT=N              seconds per command (default 120, minimum 1)

cd "$(dirname "$0")/.." || exit 2

CHECK_TIMEOUT=${CHECK_TIMEOUT:-120}
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
	     [ -z "$err" ] || reason="$reason: $err" ;;
    esac
    return $rc
}

pass() { echo "PASS $1"; passed=$((passed + 1)); }
xfail() { echo "XFAIL $1: $2"; xfailed=$((xfailed + 1)); }
fail() { echo "FAIL $1: $2"; failed=$((failed + 1)); }

# Report an awk assertion script's verdict: it prints nothing on success,
# or one line describing the first failed assertion.
verdict() {
    if [ -z "$2" ]; then pass "$1"; else fail "$1" "$2"; fi
}

# FFT: testFFT's signal is a cosine at bin 2 (amplitude 1.0) plus a sine at
# bin 6 (amplitude 0.75), so the power spectrum peaks at 1.0 and 0.5625.
case_pepsi() {
    run pepsi ./eval repl.l test-pepsi.l || { fail pepsi "$reason"; return; }
    verdict pepsi "$(awk '
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
		w = (c in want) ? want[c] : 0
		if (h[c] < w - tol || h[c] > w + tol) {
		    printf "bin %d height %g, expected %g+-%g\n", c, h[c], w, tol
		    exit
		}
	    }
	}' "$T/pepsi.out")"
}

# Ruby, not the @( ... ) Lisp escape: 1 + 2 * 3 + 5 uses the + and * methods
# the program defines on <long>; foo(1, 2) defines and calls a method.
case_maruby() {
    run maruby ./eval maruby.l || { fail maruby "$reason"; return; }
    verdict maruby "$(awk '
	$0 == " => 12" && !twelve { twelve = NR }
	$0 == " => 3" { three = NR }
	END {
	    if (!twelve)	    print "no \" => 12\" for 1 + 2 * 3 + 5"
	    else if (three < twelve) print "no \" => 3\" for foo(1, 2) after \" => 12\""
	}' "$T/maruby.out")"
}

# Left recursion in PEG: Bryan Ford's grammars match or reject as listed (the
# file's own OUTPUT comment predates the T case and is stale), and the
# expression grammar builds a left-associative tree over 0..9.
case_recursion() {
    run recursion ./eval repl.l test-recursion.l || { fail recursion "$reason"; return; }
    verdict recursion "$(awk '
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
	}' "$T/recursion.out")"
}

# A language built at the REPL: its for loops print the 10x10 multiplication
# table, and nfibs(n) = nfibs(n-1) + nfibs(n-2) + 1 equals 2*fib(n+1) - 1.
case_repl() {
    run repl ./eval repl.l test-repl.l || { fail repl "$reason"; return; }
    verdict repl "$(awk -F '\t' '
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
	}' "$T/repl.out")"
}

# Generated PEG matcher: the grammar accepts letters, ",", " ", "(" and ")",
# so matching stops at the ".", and the match is the text before it.
case_pegen() {
    run pegen ./eval test-pegen.k || { fail pegen "$reason"; return; }
    verdict pegen "$(awk -v input='hello, (parsing) world.' '
	BEGIN { p = index(input, ".") - 1 }
	$0 == "matched " p { matched = 1 }
	NF { last = $0 }
	END {
	    if (!matched) printf "no \"matched %d\" line\n", p
	    else if (last != substr(input, 1, p)) printf "result [%s], expected [%s]\n", last, substr(input, 1, p)
	}' "$T/pegen.out")"
}

# Earley parsing of 1+2*3 with both grammars: "+" at the top, "*" nested
# under its right operand, and the leaves 1, 2, 3 in order.
case_earley() {
    run earley ./eval test-earley.k || { fail earley "$reason"; return; }
    verdict earley "$(awk '
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
	}' "$T/earley.out")"
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
    verdict maru_test "$(awk -v n=32 -v x=42 -v y=666 '
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
	}' "$T/maru_test.out")"
}

# The GC written in Maru must compile through the ir2 C backend.  Running it
# is an expected failure on 64-bit hosts: ir2.k assumes 4-byte pointers
# (pointer-size 4), so the generated GC under-allocates and segfaults.  Once
# that is fixed, the run exits 0 and this case reports an unexpected pass.
case_maru_gc() {
    ir2_build maru_gc maru-gc.k || { fail maru_gc "$reason"; return; }
    if run maru_gc "$T/maru_gc"; then
	fail maru_gc "unexpectedly passed: maru-gc now runs; make it a normal case"
    else
	xfail maru_gc "runs and $reason (ir2.k pointer-size 4 on a 64-bit host)"
    fi
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

[ $# -gt 0 ] || set -- pepsi recursion repl pegen earley maruby maru_test maru_gc
for c in "$@"; do
    "case_$c"
done
echo "$passed passed, $failed failed, $xfailed expected failures"
[ "$failed" -eq 0 ]
