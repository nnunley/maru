# Grammars and language listings from the STEPS reports and papers

Verbatim transcriptions, each checked against the page images. Every file starts with its source (report, appendix or figure, page) and ends with transcription notes; `[?]` marks a glyph that could not be read with certainty.

These are staging copies to work from. Promoting one into the source tree means making it run on Maru's PEG machinery, giving it a check, and adding its lines to `check/lines`.

## Warth & Piumarta 2007, OMeta paper (TR-2007-003)

- `ometa-paper-fig1-arithmetic.ometa`: OMeta: an object-oriented language for pattern matching
- `ometa-paper-fig2-flatten.ometa`: OMeta: an object-oriented language for pattern matching
- `ometa-paper-fig3-foreveryother.ometa`: OMeta: an object-oriented language for pattern matching
- `ometa-paper-fig4-optimization.ometa`: OMeta: an object-oriented language for pattern matching
- `ometa-paper-fig5-calc.ometa`: OMeta: an object-oriented language for pattern matching
- `ometa-paper-fig7-printf.ometa`: OMeta: an object-oriented language for pattern matching

## STEPS 2007 report (TR-2007-008)

- `addexpr-rule-example-body-p18.ometa`: OMeta (body figure: the general form of an OMeta rule)
- `casejs-parser-body-p19.ometa`: JavaScript (body figure: expressive case statement, CaseJSParser)
- `logo-to-js.ometa`: Appendix A: An OMeta Translator from Logo to JavaScript (Extended Example)
- `ometa-to-js.ometa`: Appendix D: An OMeta Translator from OMeta to JavaScript (Extended Example)
- `prolog-to-js.ometa`: Appendix B: An OMeta Translator from Prolog to JavaScript (Extended Example)
- `prolog-translator-body-p20.ometa`: Prolog and Toylog in OMeta (body figure: Prolog translator and Prolog example)
- `tiny-tcp-svc-grammar-body-p17.is`: A Tiny TCP/IP Using Non-deterministic Parsing (body figure: the service-port grammar)
- `toylog.ometa`: Appendix C: Toylog, An English Language Prolog (Extended Example)

## STEPS 2008 report (TR-2008-004)

- `2008-tcp-grammar-programming-with-grammar.ometa`: "programming with grammar" glimpse: TCP packet rejection and acknowledgement rules

## STEPS 2009 report (TR-2009-016)

- `2009-nile-ast-binop-translation-ometa-excerpt.ometa`: Excerpt of translating Nile ASTs to a lower level language, expressed in OMeta
- `2009-nile-parser-ometa-excerpt.ometa`: Example of part of the Nile language, expressed in the prototype OMeta meta translator
- `2009-nile-text-to-sexpr-peg-excerpt.peg`: Excerpt from text to s-expressions
- `2009-postfix-to-x86-machine-code.ometa`: Transforming postfix expressions into machine code
- `2009-sexpr-to-postfix-ometa-excerpt.ometa`: Excerpt from s-expressions to postfix expressions

## Piumarta 2010, PEG-based transformer (TR-2010-003)

- `peg-example-abstract-code-nfibs.lisp`: PEG-based transformer provides front-, middle- and back-end stages in a simple compiler
- `peg-example-c-version-figure5.c`: PEG-based transformer provides front-, middle- and back-end stages in a simple compiler
- `peg-example-nfibs-source.lisp`: PEG-based transformer provides front-, middle- and back-end stages in a simple compiler
- `peg-transformer-back-end-i386.peg`: PEG-based transformer provides front-, middle- and back-end stages in a simple compiler
- `peg-transformer-front-end.peg`: PEG-based transformer provides front-, middle- and back-end stages in a simple compiler
- `peg-transformer-middle-end.peg`: PEG-based transformer provides front-, middle- and back-end stages in a simple compiler
- `peg-transformer-syntax-tables.txt`: PEG-based transformer provides front-, middle- and back-end stages in a simple compiler

## STEPS 2010 report (TR-2010-004)

- `nothing-copying-gc.nothing`: Appendix 2: A Copying Garbage Collector written in Nothing
- `nothing-syntax.ometa`: Appendix 1: Nothing Syntax in OMeta

## STEPS 2011 report (TR-2011-004)

- `2011-maru-smalltalk-like-language.l`: Appendix II: the Maru code to make a Smalltalk-like language, write an FFT in it, and test it
- `2011-nile-absolute-value-operator.nile`: Nile absolute value operator definition (piecewise)
- `2011-nile-affine-matrix-point-multiplication.nile`: Nile affine transformation matrix, point type and multiplication operator
- `2011-nile-complex-type-multiplication.nile`: Nile complex number type and multiplication operator
- `2011-nile-formula-program.nile`: Gezira rendering formula written in Nile (the 'The Formula' program, about 45 lines)
- `2011-nile-linear-interpolation.nile`: Nile linear interpolation expression (Unicode operator and variable)
- `2011-nile-mycomp-live-editing-figures.nile`: Nile MyComp compositor, two live-editing examples
- `2011-nile-transform-beziers-process.nile`: Nile process transforming a stream of Beziers by a matrix
- `2011-nile-vector-type-dot-product.nile`: Nile 3D vector type and dot product operator

## STEPS 2012 final report (TR-2012-001)

- `2012-kscript-app1-apoint-fby.kscript`: Behavior defined with fby (section 2.3)
- `2012-kscript-app1-beeper-delaye.kscript`: buttonDown with and without delayE (section 2.4.5)
- `2012-kscript-app1-beeper-when-doe.kscript`: when and doE equivalence (section 2.4.1)
- `2012-kscript-app1-bubblewatcher-halotarget.kscript`: bubbleWatcher on haloTarget (section 7.2)
- `2012-kscript-app1-bubblewatcher-selecteddocbox.kscript`: bubbleWatcher on selectedDocBox (section 7.2)
- `2012-kscript-app1-button-clicked.kscript`: Button clicked stream (section 5.1)
- `2012-kscript-app1-button-events.kscript`: Button event streams (section 5.1)
- `2012-kscript-app1-button-fire.kscript`: Button fire stream with actsWhen (section 5.1)
- `2012-kscript-app1-button-looks-changefill.kscript`: Button looks and changeFill streams (section 5.1)
- `2012-kscript-app1-button-state.kscript`: Button state streams pressed, entered, actsWhen, selected (section 5.1)
- `2012-kscript-app1-buttondown-eventstream.kscript`: buttonDown declared with eventStream (section 4.3)
- `2012-kscript-app1-field-dataflow-form.kscript`: Dataflow field form (section 2.2)
- `2012-kscript-app1-fig2-evaluator-pseudocode.txt`: Evaluator pseudo-code, Figure 2 (KSObject evaluation)
- `2012-kscript-app1-fig3-toplevel-loop-pseudocode.txt`: Top-level loop pseudo-code, Figure 3 (KSWorld)
- `2012-kscript-app1-filelist-behavior.kscript`: File List behavior method (Appendix B)
- `2012-kscript-app1-filelist-fire.kscript`: File List fire stream (section 6.1)
- `2012-kscript-app1-filelist-layout.txt`: File List layout, KSSimpleLayout (Appendix A)
- `2012-kscript-app1-filelist-setup.kscript`: File List setup method (section 6.1)
- `2012-kscript-app1-fillupdater-simple.kscript`: Dependency on a source stream (section 2.4.1)
- `2012-kscript-app1-fillupdater-when.kscript`: when-then form (section 2.4.1)
- `2012-kscript-app1-fractionalpart-sound.kscript`: Streams using % and FMSound (section 2.2)
- `2012-kscript-app1-function-definition.kscript`: Function definition with := and -> (section 2.1)
- `2012-kscript-app1-heading-increment.kscript`: Naive heading update (section 3)
- `2012-kscript-app1-items-anye.kscript`: anyE over a collection of buttons (section 2.4.3)
- `2012-kscript-app1-menu-items-fire.kscript`: Menu items and fire streams (section 5.2)
- `2012-kscript-app1-mutual-a-b.kscript`: Mutually dependent streams via previous value (section 3.2)
- `2012-kscript-app1-myaligner.kscript`: otherBox and myAligner streams (section 4.4)
- `2012-kscript-app1-mymover.kscript`: myMover stream with translateBy (section 4.4)
- `2012-kscript-app1-mytimer-timere.kscript`: Dataflow definition using timerE (section 2.2)
- `2012-kscript-app1-nat-no-trigger.kscript`: Previous-value access without trigger (section 3.2)
- `2012-kscript-app1-nat-when-timer.kscript`: Previous-value access with when trigger (section 3.2)
- `2012-kscript-app1-selecteddocbox.kscript`: selectedDocBox filter stream (section 7.2)
- `2012-kscript-app1-selectionwatcher.kscript`: Text field selectionWatcher stream (section 7)
- `2012-kscript-app1-stopper-timerviewer.kscript`: Stopper stream with undefined as filter (section 2.2)
- `2012-kscript-app1-toolbar-fire.kscript`: Panel fire stream consolidating buttons (section 7)
- `2012-kscript-app1-updateline-mergee.kscript`: mergeE with side-effecting method (section 2.4.2)
- `2012-kscript-app2-bubblewatcher-halotarget.kscript`: bubbleWatcher on haloTarget (section 7.2)
- `2012-kscript-app2-fig3-evaluator-pseudocode.txt`: Evaluator pseudo-code, Figure 3 (KSObject evaluation)
- `2012-kscript-app2-selecteddocbox.kscript`: selectedDocBox filter stream (section 7.2)
- `2012-kscript-app2-selectionwatcher.kscript`: Text field selectionWatcher stream (section 5)
- `2012-kscript-app2-smalltalk-titlerow.txt`: Smalltalk title-bar example (LWorld, Smalltalk)
- `2012-kscript-app2-titlerow-layout.txt`: titleRow layout in KSSimpleLayout-style Smalltalk (section 1)
- `2012-kscript-fire-stream-anye.kscript`: fire stream definition (KScript), consolidating the fire streams of a bubble's buttons
- `2012-kscript-inspector-workspace-snippets.kscript`: KScript statements shown in workspace/inspector screenshots (bubble construction)
- `2012-kscript-selectionwatcher-stream.kscript`: selectionWatcher stream definition (KScript), text box follows the selected Box's name
- `2012-nile-visualizer-code-figure.nile`: Code blocks in the automatically produced visualizer for Nile programs (right column)
