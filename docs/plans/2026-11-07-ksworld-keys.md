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
     calls on KSNewEventStream;
   - acceptance: KSEventStreamTest's 17 tests, run from KSWorld's source (TestCase's assert: on the platform);
   - then documents' streams are KSNewEventStream objects, and KSWorld's evaluation loop (KSDependencySorter,
     KSDependencyEvaluator, KSWorldState) drives time in ksworld-run and the window, held to ksworld_clock and
     ksworld_headless as they are.
   Done so far: KSFont, KSFace, KSFamily and KSShape run from their sources over squeak-ttf.st (Squeak's TrueType classes
   on truetype.l), with class variables and class initialization; a letter from KSWorld's withChar:inFont: waits on
   streamOf (KSBox>>initialize).
4. Keys: (ksworld-key session value modifiers) makes a KSWorld keyStroke event and announces it to the focus. Check: a
   typed letter inserts a letter box after the caret; backspace removes it; arrows move the caret (KSWorld's textAction).
5. Window: SDL3 key and text events become keys (Squeak values, CMD from the command modifier). Check on the dummy
   driver: a press on the title, typing, and the frame's pixels change where the new letter goes.
6. ksworld-show.l: a person can click and type in KSWorld.ks.
