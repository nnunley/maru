# Smalltalk classes as Maru types (3e, next item): design for review

**Status:** for review, revised 2026-11-07. Nothing is built.

## Why

KScript was written beside Maru's framework, not on it. It has:
- `<ks-class>` records instead of types;
- a single `<ks-object>` structure carrying a class symbol;
- per-kind method lists (`*ks-methods*`);
- `ks-kind` names for Maru's own values.

test-pepsi.l already does all of this with Maru's own machinery (the user, 2026-11-07: "Pepsi uses the existing Maru
functionality. You wrote kscript for me without reconciling the existing framework"). This item reconciles KScript and
the Smalltalk platform with Maru's framework, which pepsi itself is built on.

## Maru's framework, which becomes the one framework

boot.l and boot2.l already have the whole mechanism. test-pepsi.l builds on it, and its `define-class` is boot.l's,
form for form (the user, 2026-11-07: "Why can't a ksobject be represented using define-class? There's already class
mechanisms in eval and boot, right?").

- **Classes.** `define-structure` and `define-class` make a class a Maru type: its instance variables are fields (a
  subclass's extend its base's), and its superclass is the type's base in `%structure-bases`.
- **Methods.** `define-selector` and `define-method` add a method to a selector for a type. Inside the body,
  `with-instance-accessors` names the fields. A call dispatches on the receiver's type and inherits through the bases
  (`<selector>-inherit`).
- **Instances.** `make` builds an instance with initial fields.
- **Maru's own types** (`<long>`, `<double>`, `<string>`, `<symbol>`, `<array>`, `<undefined>`, closures) are already
  structures. Placing one under a Smalltalk class is a `%structure-bases` entry, which is all pepsi's `define-sysclass`
  does.
- **Truth** is Maru's, as test-pepsi.l has it: true is a symbol (`t`), false is nil, and Object and UndefinedObject answer
  the tests, so there is no True class.

Two thin pieces are needed beyond that, and nothing else:
- **a class object per type**, for class-side methods (a metaclass type), `Smalltalk at: #Name` and `class`;
- **a Smalltalk keyword selector's name**, which `squeak-selector` already gives (`at:put:` is `_at_put`).

## The change

1. **The platform's classes.** squeak-base.st's hierarchy is `define-class`es under an Object type. Maru's types are
   placed in it by their bases (SmallInteger over `<long>`, String over `<string>`, UndefinedObject over `<undefined>`,
   and so on), and its methods are `define-method`s.
2. **KSWorld's classes.** `ksworld-source.l` makes each class from its file-out with `define-class` (superclass, instance
   variables as fields) and each method with `define-method`. A KScript method's body is run by `kscript.l`'s evaluator.
3. **A send is the selector call.** `ks-send` reduces to it, and a missing method reaches `doesNotUnderstand:`.
   `<ks-class>`, `*ks-methods*`, `ks-method-for`, `ks-kind` and `ks-methods` go. KScript's built-ins (Point, Rectangle,
   Color, the stream combinators) become `define-method`s on their types.
4. **KSObject** is `(define-class <KSObject> <IdentityDictionary> (...))`. Its declared instance variables are fields, and
   any other key is an entry in its dictionary (a field holding the hash.l table). `this.x` and `self at: #x` read the
   field for a declared instance variable, and the entry for anything else.
5. **Documents.** A document's object is an instance of its class's type. A saved slot becomes the field when the class
   declares it, and a dictionary entry otherwise.

## What Maru doesn't already settle (two questions)

1. **A document names classes no source defines yet** (most of KSWorld.ks's), and a source may come after a document.
   Pepsi defines every class before using it.
   - I propose a `define-class` under Object, with no fields of its own, the first time a class name is seen.
   - When the source arrives, its superclass is set as the type's base (`%structure-bases`, which a send reads every
     time). Instance variables that come only with the source stay dictionary entries in objects made before it.
   - The alternative is loading every source before any document. That refuses a document whose classes aren't all in
     `ksworld/`.
2. **The two kinds of storage.** A declared instance variable becomes a field, and anything else goes in the dictionary,
   as above. One question remains: once a class's source defines an instance variable, should objects made before it
   move their entry to a field? I propose they keep it as an entry, read through the dictionary, so no object changes
   shape after it's made.

## No root type (revised after the user's question, 2026-11-08)

"I'd argue that a base class isn't as required as you're making it out, since there technically already is one through
the oop for dispatching purposes." Both boots dispatch on the type every value carries:
- **Selectors** (`define-selector`, `define-method`) dispatch on the first argument's `type-of`. They inherit through
  `%structure-bases` where a type has a base, and fall back to the selector's default.
- **Multimethods** (`define-generic`, `define-multimethod`) dispatch on every argument's exact type, with no inheritance,
  and fall back to the generic's default.

So Object needs no type: Object's methods are each selector's default. A base link is needed only where Smalltalk
inheritance wants one: `<array>` and `<string>` under fieldless ArrayedCollection and SequenceableCollection types,
`<long>` and `<double>` under Number and Magnitude, OrderedCollection extending SequenceableCollection. Each class
declares its own fields, and a fieldless base takes `define-class`'s extension without trouble. The conflict met at step
3 came from the generic `<ks-object>` storage root, not from Maru.

## Phases

- **A (mergeable alone):** one class hierarchy over Maru's types, dispatched by Maru selectors.
  - A class is a Maru type, found by name (`ks-class-type`).
  - A Smalltalk class over a Maru type maps to that type: Number over `<long>` and `<double>`, String over `<string>`
    (Symbol, `<symbol>`, under it), Array over `<array>`, UndefinedObject over `<undefined>`, BlockClosure over
    `<ks-closure>`, Point, Rectangle and Color over `<ks-point>`, `<ks-rect>` and `<ks-color>`, List over `<pair>`.
  - An abstract class (Magnitude, Number, Collection, SequenceableCollection, ArrayedCollection) is a fieldless type.
  - A class whose instances are objects declares the loader's five fields (`ref attrs slots data count`) itself, at
    the same offsets in every such class, until phase B. There is no root type, and `<ks-object>`'s accessors become
    functions on those offsets.
  - A selector `#name` per Smalltalk selector, with a method per class's type, and Object's methods as its default.
  - A class object is an instance of its metaclass type (`<X class>`, under its superclass's metaclass), so a
    class-side method is a method of that type.
  - `ks-kind`, `*ks-methods*`, `ks-method-for`, `<ks-class>` and the class-name comparisons go, replaced by type
    tests.
- **B:** declared instance variables become fields (KSContentsCollection's, OrderedCollection's `items`, a FloatArray's
  data), the dictionary a field of Dictionary that KSObject inherits, and the loader's generic fields go: a stream's
  attributes become dictionary entries, a document's Array a Maru array, `ref` the loader's table.

Both phases are done, merged as one change (2026-11-08). What phase B decided on the way:

- A document's attributes, `:ref` among them, are entries in a dictionary's table under their keywords; an object with
  no table (a KSContentsCollection, a FloatArray, a KSShape) keeps none of the document's, and setting one on it is an
  error, never a silent loss. A global table of attributes would have kept every loaded object alive (Maru has no weak
  tables). The loader reads a raw array's value and an object's home from the document, not from the object.
- A slot named `slots` is an entry, never a dictionary's own table, and a stream an instance variable holds is evaluated
  as one an entry holds (`ks-slots-do`).
- KSShape is KSWorld's own, an Object subclass with its sixteen instance variables as fields and no dictionary: every slot
  the dbjr documents give a KSShape is one of them. It is declared with the loader's classes, before any source.
- The platform's classes declare the instance variables their primitives use (TTCFont, TTFontDescription, TTGlyph,
  GeziraPath, Message, Dictionary's `slots`), and a GeziraPath's fill is `myFill`, as documents keep it.
- A class defined after its type was made with other fields (its superclass's and its own, compared whole) is an
  error: an object can't gain fields, and two layouts for one class would be read differently. With the same fields it
  moves under its superclass. A class first met in a document has a class object, under KSObject, and asking whether a
  value is an instance of a class makes no class.
- `ksworld-run`'s object count is every object the document numbered, its Arrays among them.

## Order and tests

1. Pin the behaviour first, adding to `kscript`, `ksworld_sources`, `ksworld_headless` and `ometa2`:
   - sends to each kind of receiver (a number, string, symbol, `t`, `()`, array, point, block, a platform class, a
     KSWorld class, a class side);
   - an instance variable read as a field and an undeclared key as an entry;
   - a class whose superclass arrives later;
   - `doesNotUnderstand:`;
   - a document's objects as instances of their classes' types.
2. Bring the platform, then KSWorld's classes, then KScript's built-ins onto boot.l's mechanisms, removing each old table
   as nothing uses it. test-pepsi.l is untouched.

Every check runs at each step, on the dbjr documents too.

## Not in this item

JOHN's and the laws' objects (later 3e items), and native compilation (3f).
