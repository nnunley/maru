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
	*)   reason="exit $rc: $(tail -n 1 "$T/$name.err")" ;;
    esac
    return $rc
}

pass() { echo "PASS $1"; passed=$((passed + 1)); }
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

[ $# -gt 0 ] || set -- pepsi maruby
for c in "$@"; do
    "case_$c"
done
echo "$passed passed, $failed failed"
[ "$failed" -eq 0 ]
