SYS = $(shell uname)

OFLAGS = -O3 -fomit-frame-pointer -DNDEBUG
CFLAGS = -Wall -g $(OFLAGS)
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

all : eval2 eval $(EVAL32) osdefs.k

run : all
	rlwrap ./eval

status : .force
	@echo "SYS is $(SYS)"

# On arm64 macOS with Rosetta, x86-64 builds of both evaluators run x86-64 code
# in-process (jit_run); bin/<arch>/ keeps their names unchanged.
CROSS = $(shell test "$$(uname -sm)" = "Darwin arm64" && arch -x86_64 /usr/bin/true 2>/dev/null && echo bin/x86_64/eval bin/x86_64/eval2)

bin/x86_64/eval : eval.c gc.c gc.h buffer.c chartab.h wcs.c
	@mkdir -p bin/x86_64
	$(CC) -arch x86_64 -g $(CFLAGS) -o $@ eval.c $(LIBS)

bin/x86_64/eval2 : eval2.c gc.c gc.h buffer.c chartab.h wcs.c osdefs.k
	@mkdir -p bin/x86_64
	$(CC) -arch x86_64 -g $(CFLAGS) -o $@ eval2.c $(LIBS)

eval : eval.c gc.c gc.h buffer.c chartab.h wcs.c
	$(CC) -g $(CFLAGS) -o eval eval.c $(LIBS)
	@-test ! -x /usr/sbin/execstack || /usr/sbin/execstack -s $@

eval2 : eval2.c gc.c gc.h buffer.c chartab.h wcs.c osdefs.k
	$(CC) -g $(CFLAGS) -o eval2 eval2.c $(LIBS)
	@-test ! -x /usr/sbin/execstack || /usr/sbin/execstack -s $@

check : eval eval2 osdefs.k asm-x86.k arm64.g.l x86.g.l $(CROSS) .force
	./eval check/check.l

maru-check : eval2 .force
	./eval2 -g ir-gen-x86.k maru.k maru-check.k > maru-check.s
	cc -m32 -o maru-check maru-check.s
	./maru-check

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

test-compile-irgol : eval eval32 irgol.g.l .force
	./eval compile-irgol.l test.irgol > test.c
	$(CC32) -fno-builtin -g -o test test.c
	@echo
	./test

irgol.g.l : tpeg.l irgol.g | eval
	./eval compile-tpeg.l irgol.g > irgol.g.l

test-compile-irl : eval eval32 irl.g.l .force
	./eval compile-irl.l test.irl > test.c
	$(CC32) -fno-builtin -g -o test test.c
	@echo
	./test

irl.g.l : tpeg.l irl.g | eval
	./eval compile-tpeg.l irl.g > irl.g.l

test-ir : eval .force
	./eval test-ir.k > test.c
	$(CC32) -fno-builtin -g -o test test.c
	@echo
	./test

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
	rm -f eval eval2 eval32 gceval osdefs.k *.osdefs.k asm-x86.k *.g.l tpeg.l tpeg.lls
	rm -f *.exe net/*.exe *.osdefs.c net/*.osdefs.c test test.c *.o *.s a.out peg.n peg.m
	rm -f maru-check test-main test-pegen *.$(SO) *~
	rm -rf bin *.dSYM *.mshark

#----------------------------------------------------------------

.force :
