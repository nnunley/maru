
# Box lineage: Kobjects, reLObjects and JObjects

Between LObjects (Lesserphic's box model) and KSWorld (KScript's box model) there were three packages. Kobjects (2011-03 to 2012-04) rebuilt the box with K-prefixed classes and added object notation and FRP. reLObjects (one version, 2011-09) is the LObjects line under a new package name. JObjects (2012-05 to 2013-09) rebuilt the box with J-prefixed classes, moved its state into a dictionary, and installed a KSObject in each box. KScript (2012-03 to 2013-10) is the language that KSObjects was written in. The sources show what changed. The changelogs give some reasons, and the rest is not stated.

## Why

The three steps are the model moving from fields and announcements toward dictionary objects, streams and KScript:

| Generation | Dates, versions | Object storage | Events | Language and behaviour |
|---|---|---|---|---|
| LObjects (Lesserphic) | 2011-01-11 to 2013-10-22; 599 | `LBox` declares fields (`transformation`, `container`, `parts`, `contents`, `shape` ...); `LObject` has `properties` | `LObject>>announce:`, `on:send:to:`, `LEventHandler` | Smalltalk; FRP methods in `LObject` |
| Kobjects | 2011-03-30 to 2012-04-07; 45 | `KBaseObject` (`updateVector parent properties`); `KBox` declares fields | `KAnnouncement`, `KSubscriptionRegistry`, `KSubscription` | Smalltalk; K object notation, `@`-notation, `KObject-FRP` |
| reLObjects | 2011-09-16; 1 | The LObjects classes (265 class definitions) | As LObjects | As LObjects |
| JObjects | 2012-05-11 to 2013-09-05; 47 | `JObject` (`whole registry handler events`); state in a `handler` dictionary | As LObjects, with `KSObject` installed | Smalltalk, on KSObjects and KScript |
| KScript and KSObjects | 2012-03 to 2013-12; 119 and 682 | `KSProtoObject` is an `IdentityDictionary` (under `WIdentityDictionary` from 2012-03-30 to 2013-01); slots are streams | `eventStream()`, named streams | KScript: FRP and dataflow |

## How

These examples are from the sources. Each is cited by package and version.

**Kobjects: a box is a K object.** The root is `KProtoObject`, then `KBaseObject`, `KObject`, and `KBox`. Kobjects-yo.7 (2011-04-07) shows how the box was used:

```
b := KBox new.
b install: KPanHandler new.
KLesserphicMorph new openInWorld window add: b.
a := KBox shape: (KFamily defaultFont glyphAt: $g charCode).
b add: a.
b layout: KHorizontalLayout new.
```

**JObjects: the state is a dictionary.** `JObject` has the instance variables `whole registry handler events`. `JBox>>initialize` puts the box's state in the handler and installs a KSObject:

```
self install: (Smalltalk at: #KSObject).
handler at: #transformation put: MatrixTransform2x3 identity.
handler at: #pivotRatio put: 0.5@0.5.
```

(Frank's JBox.st, `initialize`.) The `components` and `properties` instance variables were removed on 2012-05-16 (JObjects-yo.9 and yo.10).

**KScript: a KS object is a dictionary.** `KSProtoObject` is `IdentityDictionary subclass` in the current source. KScript-yo.18 (2012-03-30) first reparented it to `WIdentityDictionary`, a class of the Worlds package, and the same version removed `continue` from the language. ael re-hung it under `IdentityDictionary` on 2013-01-10 (KScript-ael.92).

**Object notation.** Kobjects-yo.27 (2011-12-09) says "Object notation is introduced", and yo.28 (2011-12-10) "@-notation is introduced". KSWorld code still uses it, as in `@extent` (KSBox, `initialize`) and `@ticks.doE(...)` (`check/ksworld/tiny.pp`).

## When

- **Kobjects**: first commit `Kobjects-yo.1` (2011-03-30); latest `yo.45` (2012-04-06). INDEX.md's three main authors: yo 35, tak 7, bf 2. Yo.12 (2011-11-01) is "the initial version of ObjectSpace", yo.9 (2011-10-07) a tuple space, yo.13 (2011-12-02) "the initial version of KObject-FRP", and yo.43 (2012-01-25) "FRP stuff migrated to LObjects". Yo.44 (2012-03-23) deleted KLesserphicMorph with its examples. In Frank: `Kobjects-yo.45`.
- **reLObjects**: one version, `reLObjects-yo.267`, dated 2011-09-16 in the changelog (the server's listing says 2011-09-17). Its version record holds the LObjects history from `LObjects-bf.1` (2011-01-11) to `yo.266` (2011-09-16), and its classes are the LObjects classes. The changelog does not say why the package was named `re`. Not in Frank.
- **JObjects**: first commit `JObjects-yo.1` (2012-05-11); latest `yo.47` (2013-09-05, "revive KSBridge"). Yo.41 (2012-10-12) made JObjects depend on KSObjects and KScript. Yo.45 (2013-01-28) moved KSFrankScripting to KSObjects. In Frank: `JObjects-yo.47`.
- **KScript**: 2012-03-07 to 2013-10-24. In Frank: `KScript-yo.115`; the server has yo.120.

Status: Kobjects and JObjects are in Frank. reLObjects is not. None of the three is the current box model. KSWorld is (see [ksworld](ksworld.md)).

## Family of expression

- **Objects as dictionaries.** The move runs from `properties` (LObject), through `handler` (JObject), to `IdentityDictionary` (KSProtoObject). A KS object is a dictionary of slots (see the KSWorld page).
- **Announcements, then streams.** Kobjects has `KAnnouncement` and `KSubscriptionRegistry`, a `Dictionary` subclass, with `KSubscription` holding `subscriber`, `selector` and `isWeak`. KSObjects' `KSEventStream` was written in KScript; its class comment says it was dropped "for the performance reason" in favour of `KSNewEventStream`, "with real instance variables". So one step went back from dictionary slots to fields, for speed.
- **FRP.** Kobjects-yo.13 started `KObject-FRP`, yo.43 moved it into LObjects, and KScript took it over. The LObjects `frp scripting` methods (see [lobjects](lobjects.md)) are this step.
- **Gezira.** Kobjects has `KGezira`, `KGeziraCanvas`, `KGeziraFill` (and its subclasses), `KGeziraPath` and `KGeziraStroke`. The Gezira shapes in LObjects and KSObjects come from this line.
- **Tuples and object space.** Kobjects' `KObjectSpace`, `KObjectSubspace` and `KTuple` are the tuple space (yo.9) and ObjectSpace (yo.12). None of the JObjects, KSObjects or KScript sources mentions them.
- **Worlds.** KScript's base class was the Worlds package's `WIdentityDictionary` from 2012-03-30 to 2013-01 (see above), and `WWorld` was a dependency until ael removed it (KScript-ael.93). JObjects-yo.31 (2012-07-12) introduced "time bubbles", and KSObjects has trace worlds (see the KSWorld page). The Worlds package is [worlds](worlds.md).

## Links

- [lobjects](lobjects.md): the LObjects box model.
- [ksworld](ksworld.md): KSObjects and KSWorld, the successor.
- [worlds](worlds.md): Warth's Worlds.
- Maru, this repository: the KS classes are in `ksworld/*.st` (the KS classes as Frank's image ran them, 92 classes), with `ksworld/README.md` and `ksworld/INDEX.txt`. `ksworld-source.l` reads them, and `st-classes.l` maps Smalltalk classes to Maru types. No file in the tree reads the K or J packages.

## Sources

- package Kobjects, its latest version at https://tinlizzie.org/updates/exploratory/packages/
- package reLObjects, its latest version at https://tinlizzie.org/updates/exploratory/packages/
- package JObjects, its latest version at https://tinlizzie.org/updates/exploratory/packages/
- package KScript, its latest version at https://tinlizzie.org/updates/exploratory/packages/
- the Frank image (https://tinlizzie.org/~ohshima/Frank-170908.zip), class JObject.st, JBox
- https://tinlizzie.org/updates/exploratory/packages/
- TR-2009-016, section 5
- TR-2013-002, section 4
