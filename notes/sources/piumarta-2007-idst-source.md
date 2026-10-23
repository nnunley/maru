# idst-20070918: the COLA runtime and compilers as shipped (Ian Piumarta et al., 2007-09-18)

Source: `idst-20070918.tar.gz` from https://piumarta.com/software/cola/ (850 files). Read statically, never
built. Paths below are relative to the archive root. Line numbers are approximate where marked `~`.

## A. Classification

Primary source code, not a paper: the reference implementation the 2005 COLA white paper and the 2006
object-model TR describe. `object/` holds Pepsi (the Smalltalk-like layer; the `idc` compiler emits C) and
the shared runtime `libid`. `function/` holds Jolt, the "dynamic function compiler", whose Lisp sources
are headed `-*- coke -*-`. Evidence is code, so claims here are about what the 2007 system does, not about
what its authors intended.

## B. Unity

Every object, whatever language made it, is a body preceded by one word pointing to its vtable, except
two kinds that have no body: nil (address 0) and tagged integers (low bit 1), whose vtables are two
globals. One runtime function, `_libid_bind`, maps any oop and selector to a closure through a global
cache, falling back to a real `lookup:` message. Pepsi and Jolt both send through it.

## C. Outline of major parts

- `function/objects/tag.h`: the integer tag, `_I(O) = (long)O >> 1`, `_O(I) = (oop)((long)I << 1 | 1)`.
- `object/id/libid.c` (1115 lines): allocation (`_vtable___alloc_`, 245-255), the vtable-of-an-oop test
  (304, 609, 652), the 1024-entry global method cache (170-178, index at ~617), `_libid_bind` (605-640)
  and the delegating `_libid_bind2` (643-680), `_vtable__lookup_` (329-342), `methodAt:put:with:` with
  its selector flush (~360-368, flush at 685-700), `_beTagType`/`_beNilType` (402-410), and
  `_libid_init`, the bootstrap (~880-1015). An i386-only assembly fast path for bind sits at 531-560.
- `object/boot/include/id/libid.h`: the `_send` macros; method type `oop (*)(oop closure, oop state,
  oop receiver, ...)` (49).
- `object/st80/Object.st`, `function/objects/Object.st`, `SmallInteger.st`, `_object.st`: nil, true,
  false, SmallInteger, and the user-level calls that install the nil and tag vtables.
- `object/idc/CCodeGenerator.st`, `CompilerOptions.st`: how Pepsi emits sends (global cache by default,
  per-site inline cache at `cacheLevel 1`) and inline tagged-arithmetic fast paths (~803-832).
- `function/jolt/object.k`, `boot.k`: Jolt's `send` macro over `_libid_bind` (dlsym'd), and
  `define-type` accessors at fixed 4-byte offsets.
- `doc/pepsi.html.in`: "Object layout and object pointers".

## D. Author's central problems

1. Give every language in the system one object representation, so objects pass between Pepsi, Jolt
   and C without conversion.
2. Make message semantics replaceable at run time (lookup is a message) while keeping sends fast.
3. Represent the two body-less values, nil and small integers, without a header, yet let them answer
   messages like any other object.
4. Boot the object system from a few C functions without a fixed class library in C.

## E. Key terms

- oop: the address of an object's body; its vtable is at `oop[-1]`.
- tag vtable / nil vtable: the vtables for any oop with bit 0 set, and for oop 0.
- `_beTagType` / `_beNilType`: methods that make a vtable family the tag or nil vtable.
- closure: `{method, data}`; methods receive the closure, the state and the receiver.
- global method cache: 1024 entries of `{vtable, selector, closure}`.
- cacheLevel: Pepsi compiler option; 0 probes only the global cache at each send, 1 adds a static
  per-site entry keyed on vtable.

## F. Main propositions (as the code shows them)

F1. Header: allocation reserves one pointer word, stores the vtable there, and returns the next word
(libid.c 245-255). No size or GC word is in the header; Boehm's conservative GC (GC_malloc, or
GC_malloc_atomic for byte data) owns sizing, and must accept interior pointers.

F2. Immediates: integers are `n << 1 | 1` (tag.h 1-2); nil is 0; false is nil and true is the root
`Object` (Object.st ~58-60); characters are tagged integers; floats are boxed.

F3. Vtable of an oop: `oop ? (oop & 1 ? tag_vtable : oop[-1]) : nil_vtable` (libid.c 609). A null
vtable is fatal ("cannot send ... no vtable", ~611).

F4. Nil and tag vtables are installed by user-level code: `[ UndefinedObject _beNilType ]` and
`[ SmallInteger _beTagType ]` run when Object.st's compiled code starts (function/objects/Object.st
27-28). Until then, sending to nil or an integer is fatal. The white paper says the same (§4.2).

F5. Bind: probe the global cache by `(vtable << 2 ^ selector >> 3) & 1023`, comparing vtable and
selector; on a miss, send `lookup:` to the vtable, guarded so the first nested lookup calls the C
`_vtable__lookup_` directly (libid.c 617-625). This guard, not a test for the vtable-of-vtables, breaks
the self-description cycle.

F6. Invalidation: changing a method mutates the existing closure in place and flushes every global
cache entry for that selector (libid.c 360-368, 685-700). A vtable's delegate is set only at creation,
so delegation never needs a flush.

F7. Pepsi emits tagged arithmetic inline: check `1 & rcv & arg`, add the untagged values, test
overflow with `(s ^ s << 1) >= 0`, retag; otherwise send `+` (CCodeGenerator.st ~803-832).

F8. Jolt shares the runtime: its `send` calls `_libid_bind` and then the closure's method with
`(closure, receiver, receiver, args...)` (object.k 14-18).

## G. Critique

G1. Word-size assumptions: Pepsi's arithmetic and the tag tests cast to `int`/`unsigned` (32 bits),
while `tag.h` uses `long`; Jolt's slot offsets step by 4. The tree is a 32-bit system; a 64-bit port must
fix each site. (Static reading; not compiled.)

G2. The per-site inline cache (cacheLevel 1) is keyed on vtable only and is not cleared by the selector
flush. It stays correct only because method changes mutate closures in place; adding a binding that
shadows an inherited one would leave a site calling the old closure. The default (cacheLevel 0) avoids
this.

G3. Stale copies: `_libid_init` copies the nil and tag vtables into the exported `_libid` struct before
Object.st sets them, and `_beNilType`/`_beTagType` update only the globals (~988-989 vs 402-410).
Generated code reading the struct fields would see stale values. Unconfirmed without a build.

G4. `assert(type##_vtable->_vtable[-1]= _vtable_vtable)` (~931) assigns inside an assert, so under
NDEBUG the header write disappears. Unconfirmed without a build.

G5. Foreign-object wrapping (a vtable word placed before a C struct) is documented in pepsi.html and the
papers but no example in the tree does it.

## H. What of it?

1. The design to match for Maru's native evaluator is small and concrete: one header word, low-bit
   integers, nil = 0, a three-way vtable test, a global cache with a selector flush. Each of those is a
   handful of intents, and the native back end must emit the three-way test inline wherever eval.l
   dispatches on type.
2. Maru's tagging should be checked against F2 and F3 before the back end fixes a representation:
   which bit tags integers, whether nil is 0, and what sits in the header (Maru's GC needs a size word
   that Boehm hid).
3. Word size must be a parameter from the start (G1). The 2007 code shows what goes wrong when 32-bit
   ints are baked into tag tests, arithmetic and slot offsets.
4. If Maru adds per-site caches, specify invalidation for them (G2); the global cache with a selector
   flush is the safe default the authors shipped.

## Permanent notes extracted from this source

- [[nil-and-small-integers-are-objects-without-bodies]]: bit 0 → tag vtable, 0 → nil vtable, else `oop[-1]`
- [[the-meaning-of-immediates-is-installed-by-user-code]]: the nil and tag vtables are set by Object.st at startup
- [[a-header-word-before-the-body-lets-foreign-structs-be-objects]]: the header placement exists for toll-free bridging
- [[a-selector-flush-keeps-a-global-method-cache-correct]]: method changes flush by selector; inline caches escape the flush
- [[maru-moved-dispatch-from-vtables-to-type-indexed-selectors]]: Pepsi vtables vs Maru type ids and per-selector arrays (synthesis)
- [[word-size-baked-into-tag-tests-blocks-ports]]: 32-bit casts and offsets in idst, and the same in eval.l/emit.l

Belief formed: `notes/beliefs/native-eval-should-tag-integers-as-eval-c-does.md`.
