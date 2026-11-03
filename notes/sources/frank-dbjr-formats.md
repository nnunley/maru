# Frank's source and the tinlizzie.org document formats (surveyed 2026-11-03)

Local copies are in `~/pkm/raw/vpri/frank/`. **License:** the Viewpoints Intelligent Archive wiki at `tinlizzie.org/IA/` has a footer, "Content is available under Creative
Commons Attribution unless otherwise noted", linking CC BY 4.0. The pages for `/dbjr/`, `/ometa/`, `/updates/` and the Frank zip carry no
statement that I found, and it isn't clear the footer reaches beyond the wiki. So Frank's code stays out of this repository for now:
read it, describe it, and write our own. In February 2020 Yoshiki Ohshima wrote on squeak-dev, "As for
Frank, we don't necessarily hide it", linking the two sources below, and "It's just not a in a good shape". The Squeak
board had asked in 2017 about permission to republish; I found no answer. Licensing is an open question to settle.

## Where the code is

`tinlizzie.org/dbjr` holds documents. Its two Squeak images are Etoys, with no `KSBox`, `LBox` or `KScript` in their
`.changes`. The code is elsewhere:

- `https://tinlizzie.org/~ohshima/Frank-170908.zip` (51 MB): `frank.image` and `.changes`, last saved 2017-09-08, with
  `.changes` activity to 2013-09. Includes `Cog.app`, `GeziraBindings*.bundle` and `.dll`, `WorldsPlugin`, 31 `.ks`
  documents (the UI's "bubbles") and the release recipe.
- `https://tinlizzie.org/updates/exploratory/packages/`: about 2,300 Monticello versions of 67 packages, 2011 to 2014.

Latest versions, by `snapshot/source.st`:

| Package | Lines | Classes | What |
|---|---|---|---|
| `LObjects-bf.606` | 74,444 | 345 | LBox framework (the 2009-2012 generation) |
| `KSObjects-yo.684` | 30,629 | 73 | KSWorld: `KSBox`, `KSEventStream`, `KSDependencyEvaluator`, layouts, `KSMorph`, `PPParser` |
| `CooperatingLanguages-yo.134` | 15,914 | 59 | The report's cooperating languages and solvers |
| `JObjects-yo.47` | 12,477 | 60 | Not yet read |
| `Worlds-ael.67` | 12,133 | 30 | Warth's Worlds |
| `Gezira-Kernels-bf.17` | 8,548 | 86 | Gezira |
| `SISS-yo.34` | 6,290 | 19 | `.siss` reader and writer, `DBDataStore` ("DynaBook Data Store", content-based) |
| `Cassowary-yo.26` | 6,229 | 35 | Constraint solver |
| `KScript-yo.120` | 4,041 | 25 | `KSParser2`, `KSCompiler` and more, as `OMeta2` subclasses, with tests |
| `GeziraBindings-Base.MT-ael.70` | 3,439 | 20 | `GeziraCanvas`, fills, strokes, paths |

So the "KSWorld 10k lines" and "KScript 753 lines" of the reports are real but narrower than the whole package.
`KSParser2`'s rules date from March 2013, after the October 2012 report our `kscript.g` follows, and Ohshima said in 2013
that the syntax had changed since that report. `KSParser2Test`, `KSEvaluatorTest` and `KSCompiler2Test` are a behaviour
reference.

## The formats

There are no `.ss` files in `dbjr` to two directory levels. There are 94 `.siss` and 82 `.pp` documents (34 MB).

| | `.lbox/index.siss` | `.ks/index.pp` |
|---|---|---|
| Dates | 2010-10-13 to 2013, two in 2021 | 2013-01-29 to 2013-12-02 |
| Written by | `SISS` package | `KSObjects` (`PPParser`, `PPPusher`, `PPPuller`) |
| Shape | `(objects :root "1" (Class :idref …` | `(objects :root "1" (Class :ref …` |
| Slots | `:name` with `:valueId`, plus `:basicSize` | `:keyClass :keyValue :valueClass :valueValue`, `:name`, `:ref` |
| Strings | `(ByteString :idref … :value …)` objects | Inline attributes |
| Behaviour | `LScript` with Smalltalk source | `KSEventStream` `:__code__`, `KSClosure` `:source`, in KScript |

I found no expansion of "SISS" or "PP" in the code's comments. Reading the classes in use by date:

1. **2010, LBox.** `LBox`, `LDBJrPage`, `LGlyphShape`, Gezira. Behaviour is handler objects.
2. **2011, spreadsheet cells and scripts.** `LScript` and `LCell` from July (Smalltalk in a string). `SISSProxy`, with
   `:root "2"`, and `ODFAnimation` from August, which with `KSODFDocument` later suggests slides imported from the `.odp` files.
3. **December 2011, FRP in LBox documents.** `KObject` and `KEventStream` (`phaser2.lbox`). The `Kobjects` package
   starts in March 2011, and `KScript` and `KSObjects` in March 2012.
4. **January 2013, KSWorld.** `KSBox`, and `.pp` replaces `.siss`. `pagesBubble.ks` has both, `index.siss` of Jan 25 and
   `index.pp` of Jan 29, so the migration can be compared directly. `testIndex.ks` (Feb 18) is the first `KSEventStream` and
   `ShortPointArray`; `KSNewEventStream` remains alongside. Empty `*.sha` files appear in `.ks` directories from Feb 18.

Class vocabulary: 123 in `.siss`, 44 in `.pp`, 29 shared. The `.pp` set is small enough to implement completely.

## What running `.pp` documents needs

The 82 documents have 215 distinct scripts, 27,915 characters and 670 lines, so much of KSWorld's UI is data and KScript in
documents, and the framework under it is not. They use 166 distinct selectors: `mapE`, `doE`, `collectE`, `mergeE`, `extent`,
`defaultLooks`, `insertChar`, `installSelection`, `glyphAt` and so on. That list is the runtime's interface. Stream types by count:
`setter` 25,510, `doE` 2,142, `mapE` 1,369, `collectE` 1,344, `mergeE` 934, `exprE` 462, `getE` 49, `update` 30, `switchColE` 9,
`frpAnd` 9, `timerE` 2.

Fonts come as glyph outlines in the documents (`KSFilledFont`, `GeziraPath`), and in `lettersBubble.ks`. The recipe's
`tinlizzie.org/share` font directory now answers 401.

## Running the original

`frank.image`'s header is `0x1969` (6505), a 32-bit closure format, and `Cog.app` is 32-bit, so neither runs on current macOS.
The `GeziraBindings` plugin ships only for Mac and Windows; its source is the `GeziraBindingsMT-Plugin` package. So a reference run
needs a 32-bit VM and a plugin build, for example on `ndn.lan`. None of this has been tried.

## Papers in the documents

`Front page Onward` v1 to v8 (March-April 2013), `KSWorld applications v7.ks` and `KSWorld.ks` are paper text, with authors
and abstracts, as DBjr documents. The 2010 report says its previous page was written in Frank.
