# Garbled PDF text layer: verify load-bearing figures from the page image

**Situation.** Reading the STEPS final report (VPRI TR-2012-001) for the Maru rebuild, 2026-10-14. `pdftotext` extracted pages 1–19 with a substituted font encoding: the body glyphs came out as punctuation soup. The subagent reading it built a glyph map from words it could identify and decoded the numbers, marking several as tentative. Among them was the single most important figure for the rebuild, Maru's 4,400-line basis and the 500 lines for full x86 coverage.

**What happened.** I was about to carry the tentative digits into a zettel. Instead I rendered PDF pages 12–13 with the Read tool's `pages` option. The image showed the prose numbers were right, and it also contained a diagram the text extraction had dropped entirely: Maru parser 248, codegen 1,357, assembler 621, runtime 1,320, library 771, total 4,317. That breakdown became the basis of two zettels.

**What I noticed.** When a text layer is unreliable, decoding it recovers words but not figures, and figures are often in diagrams that extraction silently loses. Checking the page image is cheap with the Read tool and yields more than the decode. A subagent's "tentative" flag is the trigger to look at the image before using the number.
