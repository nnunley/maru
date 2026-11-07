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
3. Letter boxes: a text box's spans expand into letter boxes as KSWorld held them, and layout and rendering read them.
   Check: KSWorld.ks draws the same 937 paths, each text box's kept character where it was.
4. Keys: (ksworld-key session value modifiers) makes a KSWorld keyStroke event and announces it to the focus. Check: a
   typed letter inserts a letter box after the caret; backspace removes it; arrows move the caret (KSWorld's textAction).
5. Window: SDL3 key and text events become keys (Squeak values, CMD from the command modifier). Check on the dummy
   driver: a press on the title, typing, and the frame's pixels change where the new letter goes.
6. ksworld-show.l: a person can click and type in KSWorld.ks.
