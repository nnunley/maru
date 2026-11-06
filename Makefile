SYS = $(shell uname)

OFLAGS = -O3 -fomit-frame-pointer -DNDEBUG
CFLAGS = -Wall -Wno-comment -g $(OFLAGS)
CC32 = $(CC) -m32

ifeq ($(findstring MINGW32,$(SYS)),MINGW32)
LIBS = -lm -lffi libw32dl.a
TIME =
else
LIBS = -lm -lffi -ldl
TIME = time
endif

ifeq ($(findstring Darwin,$(SYS)),Darwin)
SO = dylib
SOCFLAGS = -dynamiclib -Wl,-headerpad_max_install_names,-undefined,dynamic_lookup,-flat_namespace
else
SO = so
SOCFLAGS = -shared -msse -msse2
endif

.SUFFIXES :

# A recipe that fails leaves no half-written target behind.
.DELETE_ON_ERROR :

# eval32 only where the host can link 32-bit code (not macOS since 10.15).
EVAL32 = $(shell echo 'int main(){return 0;}' | $(CC32) -x c - -o /dev/null 2>/dev/null && echo eval32)

all : eval2 eval eval3 $(EVAL32) osdefs.k

run : all
	rlwrap ./eval

status : .force
	@echo "SYS is $(SYS)"

# On arm64 macOS with Rosetta, x86-64 builds of both evaluators run x86-64 code
# in-process (jit_run); bin/<arch>/ keeps their names unchanged.
CROSS = $(shell test "$$(uname -sm)" = "Darwin arm64" && arch -x86_64 /usr/bin/true 2>/dev/null && echo bin/x86_64/eval bin/x86_64/eval2)

bin/x86_64/eval : eval.c gc.c gc.h buffer.c chartab.h wcs.c undo.c undo-irl.c
	@mkdir -p bin/x86_64
	$(CC) -arch x86_64 -g $(CFLAGS) -o $@ eval.c $(LIBS)

bin/x86_64/eval2 : eval2.c gc.c gc.h buffer.c chartab.h wcs.c undo.c undo-irl.c osdefs.k
	@mkdir -p bin/x86_64
	$(CC) -arch x86_64 -g $(CFLAGS) -o $@ eval2.c $(LIBS)

eval : eval.c gc.c gc.h buffer.c chartab.h wcs.c undo.c undo-irl.c
	$(CC) -g $(CFLAGS) -o eval eval.c $(LIBS)
	@-test ! -x /usr/sbin/execstack || /usr/sbin/execstack -s $@

eval2 : eval2.c gc.c gc.h buffer.c chartab.h wcs.c undo.c undo-irl.c osdefs.k
	$(CC) -g $(CFLAGS) -o eval2 eval2.c $(LIBS)
	@-test ! -x /usr/sbin/execstack || /usr/sbin/execstack -s $@

# libraries the checks open; a library that fails to build fails only the checks that need it
CHECK_LIBS = build/gc-shapes.g.l build/gc-real.g.l build/gc-model.g.l build/sat.$(SO) build/irl-lib.$(SO) build/irl-grammar.$(SO) build/tpeg-foreign-a.g.l build/tpeg-foreign-b.g.l \
	     build/tpeg-mini.g.l build/tpeg-textargs.g.l build/tpeg-lists.g.l build/tpeg-args.g.l \
	     build/tpeg-memo.g.l build/tpeg-foreign-sa.g.l build/tpeg-foreign-sb.g.l build/tpeg-literals.g.l build/tpeg-calc.g.l build/tpeg-calceval.g.l \
	     sdl3.osdefs.k

# Runs $(1) with MARU_DBJR naming the dbjr documents the KSWorld check reads: the caller's, or else fetched into a fresh
# temporary directory (mktemp -d, under TMPDIR) and removed after.  Only when the KSWorld check is among those run.  If
# they can't be fetched it says so, and that check says it skipped them.
define with-dbjr
	@case " $(CHECKS) $(2) " in *ksworld*|"  ") fetch=yes ;; *) fetch= ;; esac; \
	if [ -n "$$MARU_DBJR" ] || [ -z "$$fetch" ]; then $(1); \
	else dbjr=$$(mktemp -d "$${TMPDIR:-/tmp}/maru-dbjr.XXXXXX") && \
	  if notes/plan/fetch-dbjr "$$dbjr"; then MARU_DBJR=$$dbjr $(1); else echo "dbjr documents not fetched: KSWorld.ks isn't checked"; $(1); fi; \
	  status=$$?; rm -rf "$$dbjr"; exit $$status; fi
endef

check : eval eval2 eval3 osdefs.k asm-x86.k arm64.g.l x86.g.l cexpr.g.l irl.g.l law.g.l john.g.l abi.g.l stub-arm64.g.l stub-x64.g.l kscript.g.l $(CROSS) .force
	-$(MAKE) -k -s $(CHECK_LIBS)
	$(call with-dbjr,./eval check/parallel.l $(CHECKS))

check-sweep : eval eval2 eval3 .force
	-$(MAKE) -k -s $(CHECK_LIBS)
	./eval check/sweep.l $(SEEDS)

check-quick : eval eval2 eval3 osdefs.k asm-x86.k arm64.g.l x86.g.l cexpr.g.l irl.g.l law.g.l john.g.l abi.g.l stub-arm64.g.l stub-x64.g.l kscript.g.l $(CROSS) .force
	-$(MAKE) -k -s $(CHECK_LIBS)
	$(call with-dbjr,./eval check/parallel.l --quick)

# a target whose recipe fails is removed, so no check reads a half-written file
.DELETE_ON_ERROR :

maru-check : eval2 .force
	./eval2 -g ir-gen-x86.k maru.k maru-check.k > maru-check.s
	cc -m32 -o maru-check maru-check.s
	./maru-check

eval3 : eval3.c gc.c gc.h buffer.c chartab.h wcs.c undo.c undo-irl.c osdefs.k
	$(CC) -g $(CFLAGS) -o eval3 eval3.c $(LIBS)
	@-test ! -x /usr/sbin/execstack || /usr/sbin/execstack -s $@

eval32 : eval.c gc.c gc.h buffer.c chartab.h wcs.c
	$(CC32) -g $(CFLAGS) -o eval32 eval.c $(LIBS)
	@-test ! -x /usr/sbin/execstack || /usr/sbin/execstack -s $@

gceval : eval.c libgc.c buffer.c chartab.h wcs.c
	$(CC) -g $(CFLAGS) -DLIB_GC=1 -o gceval eval.c $(LIBS) -lgc
	@-test ! -x /usr/sbin/execstack || /usr/sbin/execstack -s $@

debug : .force
	$(MAKE) OFLAGS="-O0"

debuggc : .force
	$(MAKE) CFLAGS="$(CFLAGS) -DDEBUGGC=1"

profile : .force
	$(MAKE) clean eval CFLAGS="$(CFLAGS) -O3 -fno-inline-functions -DNDEBUG"
#	shark -q -1 -i ./eval emit.l eval.l eval.l eval.l eval.l eval.l eval.l eval.l eval.l eval.l eval.l > test.s
	shark -q -1 -i ./eval repl.l test-pepsi.l

osdefs.k : system.osdefs.k
	cp $< $@

test : emit.l eval.l eval
	$(TIME) ./eval -O emit.l eval.l > test.s && $(CC32) -c -o test.o test.s && size test.o && $(CC32) -o test test.o

time : eval .force
	$(TIME) ./eval -O emit.l eval.l eval.l eval.l eval.l eval.l > /dev/null

test2 : test .force
	$(TIME) ./test -O boot.l emit.l eval.l > test2.s
	diff test.s test2.s

time2 : test .force
	$(TIME) ./test boot.l emit.l eval.l eval.l eval.l eval.l eval.l > /dev/null

test-emit : eval .force
	./emit.l test-emit.l | tee test.s && $(CC32) -c -o test.o test.s && size test.o && $(CC32) -o test test.o && ./test

peg.l : eval parser.l peg-compile.l peg-boot.l peg.g
	./eval parser.l peg-compile.l peg-boot.l > $@

test-repl : eval peg.l .force
	./eval repl.l test-repl.l

test-peg : eval peg.l .force
	$(TIME) ./eval parser.l peg.l test-peg.l > peg.n
	$(TIME) ./eval parser.l peg.n test-peg.l > peg.m
	diff peg.n peg.m

test-compile-grammar : eval .force
	./eval compile-grammar.l test-dc.g > test-dc.g.l
	./eval compile-dc.l test.dc

test-compile-irl : eval eval2 cexpr.g.l irl.g.l .force
	./eval compile-irl.l test.irl > test.k
	./eval2 ir-gen-c.k maru.k test.k > test.c
	$(CC) -fno-builtin -w -o test test.c -ldl
	@echo
	./test

# undo-irl.c is undo.irl compiled, kept in the tree because every evaluator includes it; the undo_irl check says when
# it's stale, and this rewrites it
undo-irl : eval2 cexpr.g.l irl.g.l .force
	./eval2 compile-irl-library.l undo.irl > undo-irl.c.new && mv undo-irl.c.new undo-irl.c

irl.g.l : tpeg.l irl.g | eval
	./eval compile-tpeg.l irl.g > irl.g.l

cexpr.g.l : tpeg.l cexpr.g | eval
	./eval compile-tpeg.l cexpr.g > cexpr.g.l

law.g.l : tpeg.l law.g | eval
	./eval compile-tpeg.l law.g > law.g.l

# typed programs built as shared libraries, under build/: compile-irl-library.l reads a
# library's irl files and compiles them to C in one process, the forms never written out;
# only the C compiler runs after it
IRL_LIBRARY = compile-irl-library.l compile-irl.l irl-grammar.l irl.g.l cexpr.g.l tpeg.l \
	      text-parser.k ir-gen-c.k maru.k
build/%.$(SO) : build/%.c
	$(CC) $(OFLAGS) -shared -fPIC -fno-builtin -w -o $@ $<

build/%.g.l : check/%.g tpeg.l compile-tpeg.l | eval
	@mkdir -p build
	./eval compile-tpeg.l $< > $@

# the SAT solver, its checker and the format grammars, one library (draft-ndn-maru-sat-00)
SAT_IRL = dimacs.irl $(wildcard sat.irl drat-check.irl)
build/sat.c : $(SAT_IRL) $(IRL_LIBRARY) | eval2
	@mkdir -p build
	./eval2 compile-irl-library.l $(SAT_IRL) > $@

build/irl-lib.c : check/irl-lib-a.irl check/irl-lib-b.irl $(IRL_LIBRARY) | eval2
	@mkdir -p build
	./eval2 compile-irl-library.l $(filter %.irl,$^) > $@

build/irl-grammar.c : check/irl-grammar.irl $(IRL_LIBRARY) | eval2
	@mkdir -p build
	./eval2 compile-irl-library.l $(filter %.irl,$^) > $@

john.g.l : tpeg.l john.g | eval
	./eval compile-tpeg.l john.g > john.g.l

abi.g.l : tpeg.l abi.g | eval
	./eval compile-tpeg.l abi.g > abi.g.l

stub-arm64.g.l : tpeg.l stub-arm64.g | eval
	./eval compile-tpeg.l stub-arm64.g > stub-arm64.g.l

stub-x64.g.l : tpeg.l stub-x64.g | eval
	./eval compile-tpeg.l stub-x64.g > stub-x64.g.l

kscript.g.l : tpeg.l kscript.g | eval
	./eval compile-tpeg.l kscript.g > kscript.g.l


tpeg.l : tpeg.g compile-peg.l compile-tpeg.l | eval
	$(TIME) ./eval compile-peg.l  tpeg.g > $@
	$(TIME) ./eval compile-tpeg.l tpeg.g | sort > tpeg.lls
	sort tpeg.l | diff - tpeg.lls
	rm tpeg.lls

test-mach-o : eval32 asm-x86.k .force
	./eval32 test-mach-o.l
	@echo
	size a.out
	chmod +x a.out
	@echo
	./a.out

test-elf : eval32 asm-x86.k .force
	./eval32 test-elf.l
	@echo
	size a.out
	chmod +x a.out
	@echo
	./a.out

test-assembler : eval32 asm-x86.k .force
	./eval32 assembler.k

test-recursion2 : eval .force
	./eval compile-grammar.l test-recursion2.g > test-recursion2.g.l
	./eval compile-recursion2.l test-recursion2.txt

test-main : eval32 .force
	$(TIME) ./eval32 test-main.k
	chmod +x test-main
	$(TIME) ./test-main hello world

test-main2 : eval32 .force
	$(TIME) ./eval32 test-pegen.k save.k test-pegen
	chmod +x test-pegen
	$(TIME) ./test-pegen

asm-x86.k : gen-asm-x86.k asm-common.k | eval
	./eval repl.l gen-asm-x86.k > $@

x86.g.l : x86.g tpeg.l | eval
	./eval compile-tpeg.l $< > $@

arm64.g.l : arm64.g tpeg.l | eval
	./eval compile-tpeg.l $< > $@

osdefs.g.l : osdefs.g tpeg.l | eval
	./eval compile-tpeg.l $< > $@

# Each X.osdefs lists what to measure about a platform, and X.osdefs.c is the
# C program, generated from it, that measures it.  Both it and X.osdefs.exe, the
# program compiled, are intermediates: make deletes them.
%.osdefs.c : %.osdefs osdefs.g compile-osdefs.l | eval osdefs.g.l
	./eval compile-osdefs.l $< > $@

%.osdefs.exe : %.osdefs.c
	$(CC) -o $@ $<

# SDL3's headers and library from pkg-config: sdl3.osdefs measures SDL3's macros and structs, so it needs them.
SDL3_FLAGS = $(shell pkg-config --cflags --libs sdl3 2>/dev/null)
sdl3.osdefs.exe : sdl3.osdefs.c
	$(CC) -o $@ $< $(SDL3_FLAGS)

%.osdefs.k : %.osdefs.exe
	./$< > $@

OSDEFS = $(wildcard *.osdefs) $(wildcard net/*.osdefs)
OSKEFS = $(OSDEFS:.osdefs=.osdefs.k)

osdefs : osdefs.g.l $(OSKEFS) .force

profile-peg : .force
	$(MAKE) clean eval CFLAGS="-O3 -fno-inline-functions -g -DNDEBUG"
	shark -q -1 -i ./eval parser.l peg.n test-peg.l > peg.m

NILE = ../nile
GEZIRA = ../gezira

libs : libnile.$(SO) libgezira.$(SO)

libnile.$(SO) : .force
	$(CC) -I$(NILE)/runtimes/c -O3 -ffast-math -fPIC -fno-common $(SOCFLAGS) -o $@ $(NILE)/runtimes/c/nile.c

libgezira.$(SO) : .force
	$(CC) -I$(NILE)/runtimes/c -O3 -ffast-math -fPIC -fno-common $(SOCFLAGS) -o $@ $(GEZIRA)/c/gezira.c $(GEZIRA)/c/gezira-image.c

stats : .force
	cat boot.l emit.l | sed 's/.*debug.*//;s/;.*//' | sort -u | wc -l
	cat eval.l | sed 's/.*debug.*//;s/;.*//' | sort -u | wc -l
	cat boot.l emit.l eval.l | sed 's/.*debug.*//;s/;.*//' | sort -u | wc -l

# Everything any rule here makes, except the checked-in peg.l and net/*.osdefs.k.
clean : .force
	rm -f eval eval2 eval3 eval32 gceval osdefs.k *.osdefs.k asm-x86.k *.g.l tpeg.l tpeg.lls
	rm -f *.exe net/*.exe *.osdefs.c net/*.osdefs.c test test.c test.k *.o *.s a.out peg.n peg.m
	rm -f maru-check test-main test-pegen *.$(SO) *~
	rm -rf bin build *.dSYM *.mshark
	rm -rf /tmp/maru-check /tmp/maru-sat	# what checks write as they run, and failed SAT checks' evidence

#----------------------------------------------------------------

.force :
