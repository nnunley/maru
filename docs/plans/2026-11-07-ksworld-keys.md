# KSWorld end to end: keyboard and mouse, as KSWorld did them

Goal: KSWorld.ks runs in an SDL3 window with real pixels (gezira-maru.l), and both the mouse and the keyboard edit its
text the way KSWorld edited it: KSWorld's own KScript methods (ksworld/KSTextLayout.st, KSBox.st), not stand-ins.

Facts found (2026-11-07):
- KSWorld.ks stores each text box's `editorDispatch` and `typeIn` streams (KSTextLayout>>behavior), so a key that
  reaches a box's `keyStroke` runs KSWorld's own dispatch: `doXX` key commands, `insertChar`, `textAction`.
- Those, and `handleButtonDown` (which sets `hand.keyboardFocus`), are KSTextLayout class methods. Documents don't keep
  class methods; ksworld-events.l's handlers are ours, written before the .st sources turned up.
- In KSWorld a text box's contents are letter boxes (`KSBox._withChar_inFont`, `addAfterIndex`, `removeAt`). The .pp
  file stores spans; our loader keeps spans (ksworld-text.l lays spans out).
- Keys go to the hand's keyboard focus (KSBox.st 1077, 3754); several keyStrokes batch into one event (`keyValues`,
  KSBox.st 1059); CMD is button bit 64; Squeak key values: backspace 8, return 13, arrows 28-31.

Steps, each a check first:
1. Merge the dbjr-fetch fix (KSWorld.ks's assertions really run in a full make check again).
2. (Done: ksworld-source.l, st-fileout.g, ksworld_sources.) Class methods from the sources: the KScript of a KS class's methods, read from ksworld/*.st chunks, answers sends the
   document doesn't define (KSTextLayout first). Check: handleButtonDown from the source sets the keyboard focus and the
   caret where ours did; our stand-ins go.
   KSWorld's handleButtonDown works on letter boxes (letterNearest, localPointFor, selectWord), so ours give way to
   KSWorld's together with step 3.
   The user's rule (2026-11-07): everything runs KSWorld's own code via KScript, nothing hand-rolled where KSWorld's
   exists. So layout too: KSTextLayout's place, rule1..5 and adjustJustification place the letters, not ksworld-text.l.
3. (Done: ksworld-pp.l's ks-letter-contents; positions still from ksworld-text.l, to be replaced in 3b.) Letter boxes: a text box's spans expand into letter boxes as KSWorld held them, and layout and rendering read them.
   Check: KSWorld.ks draws the same 937 paths, each text box's kept character where it was.
3b. KSWorld's layout: KSTextLayout's own layout methods, with the KSBox methods they send, place each letter. Check:
   the five kept letters where KSWorld put them (check/ksworld.l's letter-as-kept), 937 paths; ksworld-text.l's layout
   goes. Then KSWorld's handleButtonDown/handlePointerMotion/installSelection replace ksworld-events.l's.
3c. KSWorld's Smalltalk methods (KSContentsCollection's 103, KSBox's 54 ...), which KSWorld's KScript calls on every step
   (contents isEmpty, first, at:, add:afterIndex:, removeAt:):
   - squeak.g, a tpeg grammar for Squeak method source, from test-pepsi.l's Smalltalk grammar (message sends, blocks,
     assignment, temporaries, literals) plus what Squeak methods add (a pattern with no brackets, ^, cascades, literal
     and brace arrays);
   - each Smalltalk method compiled, as pepsi compiles one, to a Maru function, registered beside the KScript ones so the
     two call each other through ks-send; ^ inside a block a non-local return (catch.l);
   - the platform under them (Object, the booleans, blocks, numbers, Array, String) in Smalltalk on Maru's types, as
     test-pepsi.l's base library is, with { } primitives, not Squeak's whole library.
   Check: KSContentsCollection's methods run from its source (add:, at:, add:afterIndex:, removeFirst ...), and KSWorld's
   layOut places KSWorld.ks's letters where KSWorld put them.
3d. (The user's ruling, 2026-11-07: KSWorld's own streams.) KSNewEventStream (98 Smalltalk methods) and KSEventStream
   (71 KScript) run from their sources in place of kscript.l's native stream runtime; kscript.l keeps evaluating KScript.
   - evalToMethod: and eval: (where KSWorld called KSCompiler) compile with kscript.g into an object's methods;
   - stream expressions and the stream functions (timerE, mapE, collectE ...) become what KSCompiler compiled them to,
     calls on KSNewEventStream. Found: a stream expression's meaning is a compile-time rewrite, KScript2's pipeline
     (KSParser2, KSDeclVisitor, KSVariableAttributor2, KSQuoteAttributor2, KSQuoteTranslator2, KSReturnVisitor2,
     KSBlockSimplifier, KSCompiler), OMeta2 tree grammars in Smalltalk. KSQuoteTranslator2 turns each send, call, and, or,
     if, fby and field reference inside the quote into a sub-stream (this.eventStream(#sel, #src, extraDep, [args]),
     added with addSubExpression, dependencies collected), then finalizeTopLevelCreationWith2. It and KSQuoteAttributor2
     run from their sources (below);
     KSNewEventStream's runtime runs from its source;
   - the pipeline's passes (KSQuoteTranslator2 and KSQuoteAttributor2 first, then KSDeclVisitor, KSVariableAttributor2,
     KSReturnVisitor2, KSBlockSimplifier) run from their sources through an OMeta2 reader on Maru's PEG (the user's
     choice, 2026-11-07, over porting them by hand): ometa2.g reads a rule method (name :args = choice) to a tpeg rule
     over a source-parser (anything is ., { } a list pattern, #sym a literal, rule(args) {rule args}, x:name, & ~ * + ?),
     and each Smalltalk action, predicate and result ([ ], ?[ ], -> [ ]) is read by squeak.g and run with the rule's
     bindings and the grammar's own object as self, so self nextId and the like are the class's support methods from its
     source; the class's grammar is its rule methods, its other methods its support;
   - acceptance: KSEventStreamTest's 17 tests, run from KSWorld's source (TestCase's assert: on the platform);
   - then documents' streams are KSNewEventStream objects, and KSWorld's evaluation loop (KSDependencySorter,
     KSDependencyEvaluator, KSWorldState) drives time in ksworld-run and the window. KSWorld's behaviour is the referee,
     not our checks: ksworld_clock and ksworld_headless encode rules of ours (an event taking 1/1024 of a millisecond,
     timerE firing once however many intervals passed), so where KSWorld's own code disagrees, KSWorld wins and those
     checks are rewritten to what it does (KSEventStreamTest decides), never the runtime bent to fit them.
   Acceptance tests waiting on this step, out of the checks until it lands so the tree stays green: check/ksworld.l's
   letter-made-as-kept (a kept letter made again by KSWorld's withChar:inFont:, whose KSBox>>initialize needs
   streamOf), and check/ometa2.l's KSQuoteTranslator2 output for a timerE stream expression (a pvtStrm, the timerE
   stream added as a sub-expression, finalizeTopLevelCreationWith2; today it finishes a single stream instead).
   Done so far: KSFont, KSFace, KSFamily and KSShape run from their sources over squeak-ttf.st (Squeak's TrueType classes
   on truetype.l), with class variables and class initialization; a letter from KSWorld's withChar:inFont: waits on
   streamOf (KSBox>>initialize).
3e. One shared world (the user, 2026-11-07: "a common vm infrastructure/world; not using a common representation is a
   concern"), done before more is built on the old shape. Today there are three object models (Maru's structures,
   Smalltalk as kscript.l's <ks-object>, KScript's slot alists holding streams) and two truths (Maru's, KScript's 'true
   'false 'nil symbols). Instead, from the bottom:
   - Maru's booleans are the truth: () false, anything else true, t the canonical true; Smalltalk's nil and false are (),
     its true t, as test-pepsi.l has them (false := nil);
   - a Smalltalk class is a Maru type, its instance variables its fields, its methods dispatched on the type as pepsi's
     define-message does; the Smalltalk layer (squeak-base.st's primitives included) knows nothing of KScript's types;
   - KSWorld's classes are Smalltalk classes, a document's objects their instances, and their slots KSObject's own
     dictionary (it is an IdentityDictionary) on the platform's Dictionary, so KScript's this.x and Smalltalk's self at: #x
     reach one storage;
   - KScript (kscript.l) evaluates onto that layer: Maru's booleans, the shared objects and dispatch, no tables of its own;
   - an Array is a Maru array everywhere (the user, 2026-11-07): KScript's [a, b], Smalltalk's {a. b} and #(...) all make
     one, as Array new: already does, so KSWorld's compiler trees built with { } are arrays and tpeg's tree matching
     enters arrays as it enters lists.
   Order and tests (the user, 2026-11-07: "make sure there's solid testing that the change in semantics is accounted for,
   and fixed at the KScript level if it causes breakages"): in Maru false, nil and the empty list are one value, (), so
   arrays become Maru arrays first, and only then KScript's truth becomes Maru's; an empty collection is then an empty
   array, never (), and () answers as UndefinedObject, not List. Checks pinned before the switch: an empty array is
   neither false nor nil and answers isEmpty; nil and false are one value; a test of an empty collection against one
   of nil, in KScript and in Smalltalk; every KScript listing (kscript) and KSWorld document check (ksworld_*) before
   and after. A breakage is fixed in KScript, not by bending the shared representation.
   Every KScript and KSWorld check moves with it. The same rule covers JOHN (its objects, classes, yes/no truth and
   valued sets) and the laws runtime (law-record, law-truth): each moves onto the shared objects and Maru's booleans, as
   its own step after KSWorld's, with its checks.
3f. Native as we go (the user, 2026-11-07: "use our ir lower to jit compile everything to native as we go"), after 3e fixes
   what compiled code manipulates. Reading KSWorld's sources through the interpreted grammars costs 50 to 90 ms a method
   (KSBox's 370 about 20 s, a window's classes minutes): the grammars (st-fileout.g, kscript.g, squeak.g, ometa2.g and
   tpeg's generated parsers), then the evaluator, then KSWorld's methods compile through ir2 (native-ir2's intents and
   lowering) as they load, and what's compiled is kept as a native image (native-save, native-image.l), so a start loads
   code instead of re-reading. The missing piece is untyped Maru through ir2, the evaluator compiling itself. Measured
   before and after: KSBox's methods read, and a KSWorld.ks window's time to its first frame.
4. Keys: (ksworld-key session value modifiers) makes a KSWorld keyStroke event and announces it to the focus. Check: a
   typed letter inserts a letter box after the caret; backspace removes it; arrows move the caret (KSWorld's textAction).
5. Window: SDL3 key and text events become keys (Squeak values, CMD from the command modifier). Check on the dummy
   driver: a press on the title, typing, and the frame's pixels change where the new letter goes.
6. ksworld-show.l: a person can click and type in KSWorld.ks.

Future directions (not yet):
- A parse that can't go on (the user, 2026-11-07): not a doesNotParse: of its own but doesNotUnderstand:, so recovering
  a parse goes through the same mechanism as an unanswered send.
- Our font fallback (the user, 2026-11-07: kept, but hoisted into KScript): KSWorld fell back only to DejaVuSans for a family
  not installed and drew a missing character with the font's own missing glyph (KSShape>>withFont:index:fill:). Ours (a family's
  alternatives, its generic family, a last resort, a missing character from the next font with it) moves out of
  ksworld-text.l's Maru into KScript methods of ours on the font classes, loaded as KSWorld's are; the platform only reads
  TrueType.
