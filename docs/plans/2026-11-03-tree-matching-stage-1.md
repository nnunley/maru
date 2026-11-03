# Tree Matching, Stage 1: tpeg Over Any Data, on the Evaluators

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `compile-tpeg.l` grammars match any iterable data on `eval`, `eval2` and `eval3`, with list patterns, object literals, arguments on the input, `{apply}` and `{super}`, and memoization and left recursion on every source.

**Architecture:** A new `input.l` defines the input selectors, with methods for text, binary (`<data-stream>`) and list sources. `<text-parser>` keeps its fields: `string` holds any source and `position` any position. Its runtime functions keep their direct path when the source is a `<string>` at an integer position, and go through the selectors otherwise. `compile-tpeg.l` gains the new forms.

**Tech Stack:** untyped Maru (`boot.l`, `boot2.l`), `tpeg.g`, `compile-tpeg.l`, `text-parser.l`, `check/check.l`.

**Spec:** `docs/rfc/draft-ndn-maru-typed-tree-matching-00.md`, stage 1 of its order of work.

## Global Constraints

- Nothing typed: `text-parser.k`, `irl-grammar.l`, `maru.k`, `ir2.k`, `eval.c`, `eval2.c` don't change. `irl-grammar.l`'s refusals stay, so typed grammars behave as today.
- `peg.g`, `peg-compile.l`, `parser.l` and `compile-peg.l` don't change.
- `make tpeg.l` keeps passing: it builds `tpeg.l` with `compile-peg.l`, and diffs the sorted output of `compile-tpeg.l`. So code `compile-tpeg.l` emits for constructs `tpeg.g` uses stays byte-identical, including the names `text-parser-match-any` and friends. New forms get new names.
- Input selectors are named `in-*`, never `$*`: a rule `r` becomes the selectors `$r` and `$$r`.
- Parse data is separate from parse state: no runtime function or generated form decides success from a value. Runtime functions answer `1` or `()`, or a position only on the existing text path, where it is at least 1.
- Every case runs under all three evaluators: `./eval FILE`, `./eval2 -b boot2.l FILE`, `./eval3 -b boot2.l FILE`. `eval3` is `eval2`'s successor. Run through make, from the worktree root: `make check CHECKS="NAME"`.
- Every change in source line count gets a `check/lines` entry that says why, and tests count. Format for reading; don't pack lines.
- Commit messages: a plain prose subject in this repository's style, with no attribution lines.
- Develop on a short-lived branch `tpeg-trees` in `.worktrees/tpeg-trees`, from `main` once the RFC is committed. `git worktree remove --force` it after merging; never `git submodule deinit`.

## Review Focus

1. A source element that is nil or 0, or a literal `'0`: the match succeeds and `self.result` holds it. (Task 2, Task 3)
2. A rule called with an argument of nil or 0, and a failed call: position is back where it was, with no cell left behind. (Task 4)
3. Backtracking out of a list pattern: both `self.string` and `self.position` are restored, also when the nested match fails midway. (Task 3)
4. A list pattern entering a string inside a list, then matching text with a class, on a parser whose top source is a list: the direct path uses the entered string's limit. (Task 3)
5. `peg-enable-recursion` on, with a grammar over a list: no `array-at` on a pair. (Task 6)

---

### Task 1: The input selectors

**Files:**
- Create: `input.l`, `check/tpeg-input.l`
- Modify: `check/check.l`, `check/lines`

**Interfaces:**
- Produces, in `input.l`:
  - `(in-enter value)`: true if a list pattern can go inside `value`. True for `<pair>`, nil and `<string>`, `<data-stream>`; default `()`.
  - `(in-start source)`: first position. A list's is itself, a string's and a data stream's `0`.
  - `(in-limit source)`: a string's length, otherwise `()`.
  - `(in-at-end source pos)`, `(in-head source pos)`, `(in-tail source pos)`: dispatch on `source`. A list ignores `source`'s value, and its position is its current pair; nil, which has type `<undefined>`, is an empty list.
  - `(in-span source from to)`: list of elements from `from` up to `to`. The default walks with `in-head` and `in-tail`, so a user's type needn't define it.
  - `(in-after source a b)`: is `b` later than `a`. The default is `<`; a list walks along the tails from `a`.
  - On a `<data-stream>`, these read `data` and `limit` directly and ignore its own `position`.
  - `(in-same a b)`: `=` by default; `<string>` compares contents.
  - `(in-class element class)`: `element` is a long and in the sorted class string, by `string-search`.
  - `<arg-cell>` with fields `value`, `next`; `(arg-cell? x)`.

- [ ] **Step 1: Write the failing test** `check/tpeg-input.l`, ending in `(println "tpeg input ok")` when nothing failed, with an `expect` helper as in `check/john-forms.l`. Over each of `"ab"`, `'(?a ?b)`, a `<data-stream>` holding bytes 97 and 98 (`data-stream-put-byte` twice, then `data-stream-truncate`), and a user structure `<countdown>` with its own methods for `in-enter`, `in-start`, `in-at-end`, `in-head`, `in-tail`: walking from `in-start` to `in-at-end` gives `(97 98)`. Also assert: `(in-enter 3)` is false; `(in-enter ())` is true and `(in-at-end () (in-start ()))` is true; `(in-after "ab" 0 1)` and not `(in-after "ab" 1 1)`; on `(define l '(1 2 3))`, `(in-after l l (cdr l))` and not `(in-after l (cdr l) l)`; `(in-same "x" "x")` and not `(in-same 'x 'y)`; `(in-class ?5 "0123456789")` and not `(in-class 'a "0123456789")`; `(in-span "abc" 0 2)` is `(?a ?b)`.

- [ ] **Step 2: Add the case to `check/check.l`, beside `john_forms`**

```
;; input.l: one interface over text, binary, lists and a user's type (check/tpeg-input.l).
(check "tree_input"
  (unit-assert (equal (last (run "tree_input" "./eval check/tpeg-input.l")) "tpeg input ok"))
    (unit-assert (equal (last (run "tree_input2" "./eval2 -b boot2.l check/tpeg-input.l")) "tpeg input ok"))
  (unit-assert (equal (last (run "tree_input3" "./eval3 -b boot2.l check/tpeg-input.l")) "tpeg input ok")))
```

- [ ] **Step 3: Run it.** `make check CHECKS=tree_input`. Expected: FAIL, because `input.l` doesn't exist.

- [ ] **Step 4: Implement `input.l`** with a method per type, not a `cond`. `(require "data-stream.k")`.

- [ ] **Step 5: Run it.** Expected: `PASS tree_input`.

- [ ] **Step 6: Commit,** with a `check/lines` entry.

### Task 2: The runtime over any source

**Files:**
- Modify: `text-parser.l`, `check/tpeg-input.l`, `check/lines`
- Create: `check/tpeg-mini.g`
- Modify: `Makefile` (`CHECK_LIBS` gains `build/tpeg-mini.g.l`)

**Interfaces:**
- Consumes: Task 1's selectors.
- Produces:
  - `<text-parser>` keeps `string limit position memos refill result foreign`, and adds `streams`, used by Task 6. `string` holds any source; `limit` is `(in-limit source)`.
  - `(text-parser-at-end self)`, `(text-parser-head self)`, `(text-parser-tail self)`: handle an `<arg-cell>` position, then call the selectors. Tasks 3 and 4 use them.
  - `(text-parser-for-source class source)`: a parser on any source, positioned at `in-start`.
  - `(parse-source grammar rule source)`: as `parse-string`, for any source.

- [ ] **Step 1: Write the failing tests.** `check/tpeg-mini.g` is a grammar with no new features, `<mini> : <text-parser> ()`, with `num = [0-9]+ @$#:n -> n ;` and `sum = num:a "+" num:b -> (+ a b) ;`. Add to `check/tpeg-input.l`: `(parse-source <mini> $sum S)` is `5` for `S` being `"2+3"`, `'(?2 ?+ ?3)`, a `<data-stream>` of those bytes, and a `<countdown>` generating them. A rule `any = . ;` over `'(())` and `'(0)` succeeds, with `<text-parser>-result` nil and `0`. `(parse-string <mini> $sum "2+3")` is still `5`.

- [ ] **Step 2: Run it.** Expected: FAIL, `parse-source` undefined.

- [ ] **Step 3: Change `text-parser-match-any`, `-match-class`, `-match-object`, `-match-char`, `-match-string`, `-list-from-to`, `-string-from-to`.** Each begins with the test that the source is a `<string>` and the position a long, and then does exactly what it does today. Otherwise it uses `text-parser-head` and friends, and answers `1`. `-match-string` on another source matches consecutive elements, with the string as its result. `text-parser-invoke-rule-in` also copies `string` and `limit` to the sub-parser on each call, since the source can change. `text-parser-for-on` passes the new field.

- [ ] **Step 4: Run it.** Expected: `PASS tree_input`.

- [ ] **Step 5: Measure the text path.** From the worktree and from `main`'s checkout: `hyperfine --runs 5 './eval compile-tpeg.l tpeg.g'`. `main` was 269 ms when last measured. Record both numbers in the commit message. If the text path is more than 15% slower, stop and report it, because the spec's specialization that would recover it is stage 5.

- [ ] **Step 6: Regression.** `make check CHECKS="peg_compose john_forms law_cexpr irl"`, and `make -B tpeg.l`. Expected: all pass, with no diff from `make tpeg.l`.

- [ ] **Step 7: Commit,** with a `check/lines` entry.

### Task 3: List patterns and object literals

**Files:**
- Modify: `compile-tpeg.l` (`value-pe`, `effect-pe`, `find-vars-in`), `text-parser.l`, `check/lines`, `check/check.l`
- Create: `check/tpeg-trees.g`, `check/tpeg-trees.l`
- Modify: `Makefile` (`CHECK_LIBS` gains `build/tpeg-trees.g.l`)

**Interfaces:**
- Consumes: Task 2's `text-parser-head` and friends.
- Produces:
  - `(text-parser-match-literal self obj)`: `in-same` on the head, result the head, answers `1` or `()`.
  - `(text-parser-can-enter self)`: not at the end, and `in-enter` holds for the head.
  - `(text-parser-enter-value self v)`: sets source to `v`, limit to `(in-limit v)` and position to `(in-start v)`.
  - `(text-parser-tail! self)`: moves position to the next element.
  - Generated `match-list`, value and effect alike, where `<exp>` is its nested pattern:

```
(and (text-parser-can-enter self)
     (let ((_v_ (text-parser-head self)) (_src_ self.string) (_lim_ self.limit) (_pos_ self.position))
       (let ((_ok_ (let () (text-parser-enter-value self _v_) (and <exp> (text-parser-at-end self)))))
         (set self.string _src_) (set self.limit _lim_) (set self.position _pos_)
         (and _ok_ (let () (text-parser-tail! self) (set self.result _v_) 1)))))
```

  This is the thesis's `List-Success`: the nested match must reach the end, and the value is the element.
- `match-object` compiles to `(text-parser-match-literal self ',obj)`.

- [ ] **Step 1: Write the failing test.** `check/tpeg-trees.g`, `<trees> : <text-parser> ()`, with: `node = `( 'add .:x .:y ) -> (list x y) ;`, `deep = `( 'add .:x `( 'mul .:y ) ) -> (list x y) ;`, `empty = `( ) -> 'none ;`, `word = `( [a-z]+ @$:s ) -> s ;`, `zero = '0 -> 'got-zero ;`, `two = node node ;`. `check/tpeg-trees.l` loads `build/tpeg-trees.g.l` and asserts, through `parse-source` and a variant that answers nil on failure:
  - `node` on `'((add 1 2))` is `(1 2)`; `deep` on `'((add 3 (mul 4)))` is `(3 4)`.
  - `node` on `'((add 1 2 3))` fails, since the whole list must match, and leaves position at the start.
  - `empty` on `'(())` is `none`. `node` on `'(5)` fails.
  - `word` on `'("abc")` is `"abc"`.
  - `zero` on `'(0)` is `got-zero`.
  - `two` on `'((add 1 2) (add 3 4))` ends with position nil, and after a failure in the second `node`, position is back at the start with the source the top list.

- [ ] **Step 2: Add the case** `tree_grammar`, under all three evaluators, ending in `"tpeg trees ok"`. Run: `make check CHECKS=tree_grammar`. Expected: FAIL at `cannot find vars in: (match-list …)`.

- [ ] **Step 3: Implement** the forms and helpers, and add `match-list` and `match-object` to `find-vars-in`, recursing into `match-list`'s body.

- [ ] **Step 4: Run it.** Expected: `PASS tree_grammar`. `irl_grammar` still refuses `match-list`.

- [ ] **Step 5: Regression and commit.** `make check CHECKS="tree_input irl_grammar peg_compose"` and `make -B tpeg.l`, then commit with a `check/lines` entry.

### Task 4: Arguments on the input

**Files:**
- Modify: `compile-tpeg.l` (`value-pe`, `effect-pe`, `compile-value`, `compile-effect`), `text-parser.l`, `check/tpeg-trees.g`, `check/tpeg-trees.l`, `check/lines`

**Interfaces:**
- Consumes: `<arg-cell>`, `text-parser-head`.
- Produces:
  - `(text-parser-invoke-args name rule self . args)`: saves position, prepends cells so the first argument is read first, calls the rule through `text-parser-invoke-rule-simply`, restores the position on failure. Rules with arguments are never memoized.
  - Rule `r :a :b = E` compiles as a method with no extra parameters, whose body is `(match-all (assign-result a (match-any)) (assign-result b (match-any)) E)`, with `a` and `b` among its variables.

- [ ] **Step 1: Write the failing test.** Add rules: `pair :a :b = "y" -> (list a b) ;`, `callp = "x" {pair 1 2}:r -> r ;`, `picky = 'yes "y" -> 'matched ;`, `askp = {picky 'yes}:r -> r ;`, `askn = {picky 'no}:r -> r ;`, `nilarg = .:a -> (list 'got a) ;`, `calln = {nilarg ()}:r -> r ;`. Assert on `"xy"`: `callp` is `(1 2)`. On `"y"`: `askp` is `matched`, `askn` fails with position 0. On `""`: `calln` is `(got ())`.

- [ ] **Step 2: Run it.** Expected: FAIL at `picky`, since an argument can't be matched today.

- [ ] **Step 3: Implement.** No other grammar in `main` uses parameters; the `kscript` branch's `{suite c}` keeps working by the same rule.

- [ ] **Step 4: Run it.** Expected: `PASS tree_grammar`. Also, in `.worktrees/kscript`, `make check CHECKS=kscript` with this `compile-tpeg.l` and `text-parser.l` copied in temporarily; don't commit there. Report the result.

- [ ] **Step 5: Regression and commit.** `make -B tpeg.l`, then commit with a `check/lines` entry.

### Task 5: `{apply}` and `{super}`

**Files:**
- Modify: `compile-tpeg.l`, `text-parser.l`, `check/tpeg-trees.g`, `check/tpeg-trees.l`, `check/lines`

**Interfaces:**
- Produces:
  - `(text-parser-apply self name prefix . args)`: finds variable `prefix`+`name`; if it holds a selector with a method for `self`'s type, directly or by `<selector>-inherit`, calls it through `text-parser-invoke-args`; otherwise answers `()`. So an unknown name fails the match, and the selector's default error never runs.
  - `(text-parser-super self class selector . args)`: calls `(<selector>-inherit (<selector>-methods selector) class)`, the method above `class`, whichever type `self` is.
  - `compile-tpeg.l` sets `*tpeg-class*` to the class while compiling a grammar's rules. `{apply x}` and `{super r x}` are `match-rule` with the names `apply` and `super`. A rule defined with either name stops compilation with `error "reserved rule name"`.

- [ ] **Step 1: Write the failing test,** following Warth's `trans`. `<nullp> : <trees> ()` has `trans = `( .:t {apply t}:a ) -> a ;`, `add = trans:x trans:y -> `(add ,x ,y) ;`, `one = -> '(one) ;`, `tail2 = "z" -> 'parent ;`. `<childp> : <nullp> ()` has `one = -> '(ONE) ;` and `tail2 = {super tail2}:p -> (list 'child p) ;`. Assert: `<nullp>`'s `trans` on `'((add (one) (one)))` is `(add (one) (one))`; `<childp>`'s is `(add (ONE) (ONE))`, an inherited rule reaching an override; `trans` on `'((nosuchrule))` fails with no error; `<childp>`'s `tail2` on `"z"` is `(child parent)`.

- [ ] **Step 2: Run it.** Expected: FAIL.

- [ ] **Step 3: Implement.** `text-parser-apply` handles `$` from `value-pe`, and `$$` from `effect-pe`.

- [ ] **Step 4: Run it, regress and commit.** `make check CHECKS=tree_grammar`, `make -B tpeg.l`, then commit with a `check/lines` entry.

### Task 6: Memos on every source

**Files:**
- Modify: `text-parser.l`, `check/check.l`, `check/lines`
- Create: `check/tpeg-memo.g`, `check/tpeg-memo.l`
- Modify: `Makefile` (`CHECK_LIBS` gains `build/tpeg-memo.g.l`)

**Interfaces:**
- Consumes: `in-after`, `streams`.
- Produces:
  - `(text-parser-memo-get self pos rule)`, `(text-parser-memo-put self pos rule memo)`: `self.memos` is an array indexed by position while the position is a long, as today; other positions, cells included, use an association list kept by identity in slot 0 of a second array held with it.
  - `text-parser-enter-value` takes the memo table for an entered value from `self.streams`, an association by identity from value to table, and adds one if absent; the generated `match-list` restores `self.memos` too. So re-entering a value within one parser reuses its memos, as OMeta/Squeak 2's `om2streams` does.
  - `text-parser-invoke-rule-with-memo` and `-with-recursion` use these, and growth tests `in-after` where it tests `<` today. Its text behaviour is unchanged.

- [ ] **Step 1: Write the failing test.** `check/tpeg-memo.g`, `<mt> : <text-parser> (count)`, with a tree left-recursive rule, `sum = sum:a 'plus .:b -> (+ a b) | .:n -> n ;`, and `counted = -> (set self.count (+ 1 (or self.count 0))) `( 'x ) ;`, `twice = &counted counted ;`. `check/tpeg-memo.l` calls `(peg-enable-recursion)` and asserts: `sum` on `'(1 plus 2 plus 3)` is `6`; `twice` on `'((x))` matches with `count` 1, since the second call reuses the memo for that position; text left recursion from `check/peg-lr.g` is still `(+ (+ 1 2) 3)`. Case `tree_memo`, all three evaluators, ending in `"tpeg memo ok"`.

- [ ] **Step 2: Run it.** Expected: FAIL at `array-at` on a pair.

- [ ] **Step 3: Implement.**

- [ ] **Step 4: Run it and regress.** `make check CHECKS="tree_memo peg_compose john_run john_forms law_cexpr"`. Expected: all pass.

- [ ] **Step 5: Commit,** with a `check/lines` entry.

### Task 7: Hex literals and `set-list-source`

**Files:**
- Modify: `tpeg.g`, `text-parser.l`, `check/tpeg-trees.g`, `check/tpeg-trees.l`, `check/lines`

**Interfaces:**
- Produces: `set-list-source` in `text-parser.l`, as `parser.l`'s: copies `<pair>-source` from the second list to the first, element by element.

- [ ] **Step 1: Write the failing test.** `hexv = -> 0x10 ;` is `16`, and `hexn = -> -0x10 ;` is `-16`. `(set-list-source '(a b) L)` on a list `L` whose pairs have sources copies them.

- [ ] **Step 2: Run it.** Expected: FAIL, undefined `$x10`.

- [ ] **Step 3: Implement.** `sexpr` in `tpeg.g` follows `peg.g`'s `sinteger`. Rebuild with `make -B tpeg.l`, which must pass its diff.

- [ ] **Step 4: Run it and commit.** `make check CHECKS="tree_grammar peg_compose"`, then commit with a `check/lines` entry.

Setting a source position on text, and carrying it through a rewrite, belong with the passes in stage 2.

### Task 8: The DBjr calculator, docs, and the whole suite

**Files:**
- Create: `check/tpeg-calc.g`, `check/tpeg-calc.l`
- Modify: `check/check.l`, `CLAUDE.md`, `Makefile` (`CHECK_LIBS`), `check/lines`

- [ ] **Step 1: Write the failing test.** Transliterate `notes/sources/grammars/dbjr-ometacalc-parse.ometa` and `-eval.ometa` as two grammars in `check/tpeg-calc.g`. `<calc>`'s `addExpr` and `mulExpr` are left-recursive and build `(op x y)` with `op` a string from `$`. `<calceval> : <text-parser> (env)` has `start :e = -> (set self.env e) calc ;`, and `calc` opens with `` `( ('"+" | '"-" | '"*" | '"/"):op calc:l calc:r ) `` and handles strings starting with a digit or a letter. In the assertions, with recursion enabled: `"a+b*2"` parses to `("+" "a" ("*" "b" "2"))`, and evaluates to `25`, with `a` 5 and `b` 10 in an association list keyed by symbol and passed by `(text-parser-invoke-args 'start $start p env)` on a parser from `text-parser-for-source`. `"(a+b)*2"` is `30`. `"z"`, an unknown name, evaluates to `()`.

- [ ] **Step 2: Add the case** `tree_calc`, all three evaluators. Run it. Expected: FAIL, no grammar.

- [ ] **Step 3: Write the grammars.** Run it. Expected: `PASS tree_calc`.

- [ ] **Step 4: Document.** In `CLAUDE.md`'s Verify section, add bullets for `tree_input`, `tree_grammar`, `tree_memo` and `tree_calc`, in its style: what each asserts, plainly.

- [ ] **Step 5: Run the whole suite.** `nice make check`. Expected: `all checks passed`, including `lines`, and `hyperfine --runs 5 './eval compile-tpeg.l tpeg.g'` recorded against Task 2's numbers.

- [ ] **Step 6: Commit,** with a `check/lines` entry, then merge to `main` with `git merge --ff-only` from the root and remove the worktree.

## What This Stage Doesn't Finish

Requirements with evidence from later stages stay red in the RFC: `R-any-source` needs `<cnf>` natively (stage 4); `R-source-positions` needs passes (stage 2); `R-typed-left-recursion`, `R-memo-selective` and `R-memo-specialized` are typed requirements (stages 4 and 5). This stage's code covers their evaluator half.

| Marker | Task |
|---|---|
| `R-input-selectors` | 1, 2 |
| `R-list-pattern` | 3 |
| `R-grammar-features` | 3, 4, 5, 7 |
| `R-args-on-input` | 4 |
| `R-stream-per-value` | 6 |
| `R-success-not-value` | 2, 3 |
| `R-dbjr-calc` | 8, evaluator half |
