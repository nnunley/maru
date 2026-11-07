"squeak-base.st -- the platform under KSWorld's Smalltalk methods, in test-pepsi.l's form (read by squeak.g's library rule):
 Squeak's classes as test-pepsi.l lays them out, on the values KScript computes with (numbers, strings,
 Maru's arrays (KScript's lists too), true, false and nil, blocks), with Squeak's meanings where pepsi's differ: an Array counts from 1.  Only
 what KSWorld's methods reach is here; a send nothing answers is an error naming it."

Object : ()
  UndefinedObject : Object ()
  Boolean : Object ()
    True : Boolean ()
    False : Boolean ()
  BlockClosure : Object ()
  Message : Object ()
  Character : Object ()
  Magnitude : Object ()
    Number : Magnitude ()
  Point : Object ()
  Rectangle : Object ()
  Color : Object ()
  Collection : Object ()
    HashedCollection : Collection ()
      Set : HashedCollection (items)
        IdentitySet : Set ()
      Dictionary : HashedCollection ()
        IdentityDictionary : Dictionary ()
          SystemDictionary : IdentityDictionary ()
    SequenceableCollection : Collection ()
      List : SequenceableCollection ()
      OrderedCollection : SequenceableCollection (items)
      ArrayedCollection : SequenceableCollection ()
        Array : ArrayedCollection ()
        String : ArrayedCollection ()

"Objects"
Object yourself                         [ self ]
Object class                            { (or (ks-class-named (ks-kind self)) (error "Smalltalk: no class for " (ks-kind self))) }
Object == other                         { (ks-bool (= self other)) }
Object ~~ other                         [ (self == other) not ]
Object = other                          [ self == other ]
Object ~= other                         [ (self = other) not ]
Object isNil                            [ false ]
Object notNil                           [ true ]
Object ifNil: aBlock                    [ self ]
Object ifNotNil: aBlock                 [ aBlock numArgs = 0 ifTrue: [aBlock value] ifFalse: [aBlock value: self] ]
Object ifNil: nilBlock ifNotNil: aBlock [ self ifNotNil: aBlock ]
Object error: message                   { (error "Smalltalk: " message) }
Object doesNotUnderstand: aMessage      { (ks-native-send self (ks-slot aMessage 'name) (array->list (ks-slot aMessage 'arguments)) () self) }
Message selector                        { (ks-slot self 'selector) }
Message arguments                       { (ks-slot self 'arguments) }
Message numArgs                         { (array-length (ks-slot self 'arguments)) }
Object isBlock                          [ false ]
Object isCollection                     [ false ]
Collection isCollection                 [ true ]
Object isString                         [ false ]
String isString                         [ true ]
Object isSymbol                         [ false ]
String isSymbol                         { (ks-bool (symbol? self)) }
BlockClosure isBlock                    [ true ]
BlockClosure ksValueWithEnoughArguments: args { (let ((n (list-length (<ks-closure>-params self))) (out ()) (a (ks-elements-of args))) (for (i 0 n) (push out (if a (car a) 'nil)) (set a (cdr a))) (ks-apply self (list-reverse! out) () ())) }
Object initialize                       [ self ]
Object perform: aSymbol                 { (ks-send self (ks-selector-of aSymbol) () () self) }
Object perform: aSymbol with: a         { (ks-send self (ks-selector-of aSymbol) (list a) () self) }
Object perform: aSymbol with: a with: b { (ks-send self (ks-selector-of aSymbol) (list a b) () self) }
Object respondsTo: aSymbol              { (ks-bool (ks-responds? self (ks-selector-of aSymbol))) }

"Dictionaries: a KSWorld object is an IdentityDictionary of its slots, so a symbol or string key is a slot's name; any other
 key (a number, an object) is kept as it is, compared by value in a Dictionary and by identity in an IdentityDictionary"
Dictionary at: key              { (let ((p (ks-assoc (ks-dict-key key) (<ks-object>-slots self)))) (if p (cdr p) (error "Smalltalk: key not found: " key))) }
Dictionary at: key ifAbsent: aBlock { (let ((p (ks-assoc (ks-dict-key key) (<ks-object>-slots self)))) (if p (cdr p) (ks-apply aBlock () () ()))) }
Dictionary at: key put: value   { (let ((p (ks-assoc (ks-dict-key key) (<ks-object>-slots self)))) (if p (set-cdr p value) (set (<ks-object>-slots self) (cons (cons (ks-dict-key key) value) (<ks-object>-slots self)))) value) }
Dictionary at: key ifPresent: aBlock { (let ((p (ks-assoc (ks-dict-key key) (<ks-object>-slots self)))) (if p (ks-apply aBlock (list (ks-stream-curr (cdr p))) () ()) 'nil)) }
Dictionary includesKey: key     { (ks-bool (ks-assoc (ks-dict-key key) (<ks-object>-slots self))) }
Dictionary removeKey: key ifAbsent: aBlock { (let ((p (ks-assoc (ks-dict-key key) (<ks-object>-slots self)))) (if p (let () (set (<ks-object>-slots self) (ks-without p (<ks-object>-slots self))) (cdr p)) (ks-apply aBlock () () ()))) }
IdentityDictionary at: key              { (let ((p (ks-assq (ks-dict-key key) (<ks-object>-slots self)))) (if p (cdr p) (error "Smalltalk: key not found: " key))) }
IdentityDictionary at: key ifAbsent: aBlock { (let ((p (ks-assq (ks-dict-key key) (<ks-object>-slots self)))) (if p (cdr p) (ks-apply aBlock () () ()))) }
IdentityDictionary at: key put: value   { (let ((p (ks-assq (ks-dict-key key) (<ks-object>-slots self)))) (if p (set-cdr p value) (set (<ks-object>-slots self) (cons (cons (ks-dict-key key) value) (<ks-object>-slots self)))) value) }
IdentityDictionary at: key ifPresent: aBlock { (let ((p (ks-assq (ks-dict-key key) (<ks-object>-slots self)))) (if p (ks-apply aBlock (list (ks-stream-curr (cdr p))) () ()) 'nil)) }
IdentityDictionary includesKey: key     { (ks-bool (ks-assq (ks-dict-key key) (<ks-object>-slots self))) }
IdentityDictionary removeKey: key ifAbsent: aBlock { (let ((p (ks-assq (ks-dict-key key) (<ks-object>-slots self)))) (if p (let () (set (<ks-object>-slots self) (ks-without p (<ks-object>-slots self))) (cdr p)) (ks-apply aBlock () () ()))) }
Object class basicNew                   { (ks-basic-new self) }
Object class new                        [ self basicNew initialize ]
Object class initialize                 [ self ]
"Behavior: a class knows its name, its superclass and the classes under it (those loaded)"
Object class name                       { (<ks-class>-name self) }
Object class superclass                 { (or (ks-class-named (<ks-class>-super self)) 'nil) }
Object class allSubclasses              { (ks-subclasses-of (<ks-class>-name self)) }
Object class withAllSubclasses          { (cons self (ks-subclasses-of (<ks-class>-name self))) }
Object class compileAll                 [ "a class here is compiled from its source as it loads" self ]
UndefinedObject isNil                   [ true ]
UndefinedObject notNil                  [ false ]
UndefinedObject ifNil: aBlock           [ aBlock value ]
UndefinedObject ifNotNil: aBlock        [ nil ]
UndefinedObject ifNil: nilBlock ifNotNil: aBlock [ nilBlock value ]
"nil answers a test as false does, as test-pepsi.l's nil, which is its false"
UndefinedObject ifTrue: aBlock          [ nil ]
UndefinedObject ifFalse: aBlock         [ aBlock value ]
UndefinedObject ifTrue: aBlock ifFalse: bBlock [ bBlock value ]
UndefinedObject ifFalse: bBlock ifTrue: aBlock [ bBlock value ]
UndefinedObject and: aBlock             [ nil ]
UndefinedObject or: aBlock              [ aBlock value ]
UndefinedObject not                     [ true ]

"Booleans"
True ifTrue: aBlock                     [ aBlock value ]
True ifFalse: aBlock                    [ nil ]
True ifTrue: aBlock ifFalse: bBlock     [ aBlock value ]
True ifFalse: bBlock ifTrue: aBlock     [ aBlock value ]
True and: aBlock                        [ aBlock value ]
True or: aBlock                         [ true ]
True & aBoolean                         [ aBoolean ]
True | aBoolean                         [ true ]
True not                                [ false ]
False ifTrue: aBlock                    [ nil ]
False ifFalse: aBlock                   [ aBlock value ]
False ifTrue: aBlock ifFalse: bBlock    [ bBlock value ]
False ifFalse: bBlock ifTrue: aBlock    [ bBlock value ]
False and: aBlock                       [ false ]
False or: aBlock                        [ aBlock value ]
False & aBoolean                        [ false ]
False | aBoolean                        [ aBoolean ]
False not                               [ true ]

"Blocks"
BlockClosure numArgs                    { (list-length (<ks-closure>-params self)) }
BlockClosure value                      { (ks-apply self () () ()) }
BlockClosure value: a                   { (ks-apply self (list a) () ()) }
BlockClosure value: a value: b          { (ks-apply self (list a b) () ()) }
BlockClosure whileTrue: aBlock          { (let () (while (ks-truthy? (ks-apply self () () ())) (ks-apply aBlock () () ())) 'nil) }
BlockClosure whileFalse: aBlock         { (let () (while (not (ks-truthy? (ks-apply self () () ()))) (ks-apply aBlock () () ())) 'nil) }
BlockClosure whileTrue                  [ self whileTrue: [] ]

"Numbers"
Number + n                              { (+ self n) }
Number - n                              { (- self n) }
Number * n                              { (* self n) }
Number / n                              { (/ self n) }
Number // n                             { (let ((q (/ self n))) (if (and (!= (* q n) self) (!= (< self 0) (< n 0))) (- q 1) q)) }	"floored, as Squeak's"
Number \\ n                             [ self - (self // n * n) ]
Number < n                              { (ks-bool (< self n)) }
Number > n                              { (ks-bool (> self n)) }
Number <= n                             { (ks-bool (<= self n)) }
Number >= n                             { (ks-bool (>= self n)) }
Number = n                              { (ks-bool (= self n)) }
Number max: n                           [ self > n ifTrue: [self] ifFalse: [n] ]
Number min: n                           [ self < n ifTrue: [self] ifFalse: [n] ]
Number between: low and: high           [ (low <= self) and: [self <= high] ]
Number negated                          [ 0 - self ]
Number abs                              [ self < 0 ifTrue: [self negated] ifFalse: [self] ]
Number isZero                           [ self = 0 ]
Number @ y                              { (ks-point self y) }
Number to: stop do: aBlock              [ | i | i := self.  [i <= stop] whileTrue: [aBlock value: i.  i := i + 1] ]
Number to: stop by: step do: aBlock     [ | i | i := self.  step > 0
                                            ifTrue: [[i <= stop] whileTrue: [aBlock value: i.  i := i + step]]
                                            ifFalse: [[i >= stop] whileTrue: [aBlock value: i.  i := i + step]] ]

"Points and rectangles (kscript.l answers x, y, extent, width, height, the corners and center natively)"
Point + p                               { (if (ks-point? p) (ks-point (+ (<ks-point>-x self) (<ks-point>-x p)) (+ (<ks-point>-y self) (<ks-point>-y p))) (ks-point (+ (<ks-point>-x self) p) (+ (<ks-point>-y self) p))) }
Point - p                               { (if (ks-point? p) (ks-point (- (<ks-point>-x self) (<ks-point>-x p)) (- (<ks-point>-y self) (<ks-point>-y p))) (ks-point (- (<ks-point>-x self) p) (- (<ks-point>-y self) p))) }
Point * p                               { (if (ks-point? p) (ks-point (* (<ks-point>-x self) (<ks-point>-x p)) (* (<ks-point>-y self) (<ks-point>-y p))) (ks-point (* (<ks-point>-x self) p) (* (<ks-point>-y self) p))) }
Point / p                               { (if (ks-point? p) (ks-point (/ (<ks-point>-x self) (<ks-point>-x p)) (/ (<ks-point>-y self) (<ks-point>-y p))) (ks-point (/ (<ks-point>-x self) p) (/ (<ks-point>-y self) p))) }
Point negated                           { (ks-point (- 0 (<ks-point>-x self)) (- 0 (<ks-point>-y self))) }
Point = p                               { (ks-bool (and (ks-point? p) (= (<ks-point>-x self) (<ks-point>-x p)) (= (<ks-point>-y self) (<ks-point>-y p)))) }
Point corner: p                         { (ks-rect (<ks-point>-x self) (<ks-point>-y self) (<ks-point>-x p) (<ks-point>-y p)) }
Rectangle left                          { (<ks-rect>-left self) }
Rectangle top                           { (<ks-rect>-top self) }
Rectangle right                         { (<ks-rect>-right self) }
Rectangle bottom                        { (<ks-rect>-bottom self) }
Rectangle origin                        [ self topLeft ]
Rectangle corner                        [ self bottomRight ]
Color asColor                           [ self ]
Color isColor                           [ true ]
Object isColor                          [ false ]

"Characters are their codes, as KScript's key values are: Character's class side answers codes, its protocol is Number's"
Character class value: n                [ n ]
Character class space                   [ 32 ]
Character class cr                      [ 13 ]
Character class lf                      [ 10 ]
Character class tab                     [ 9 ]
Number asCharacter                      [ self ]
Number asInteger                        [ self ]
Number asciiValue                       [ self ]
Number isSeparator                      { (ks-bool (member? self '(32 9 10 13 12))) }
Number isDigit                          { (ks-bool (and (<= 48 self) (<= self 57))) }
Number isLetter                         { (ks-bool (or (and (<= 65 self) (<= self 90)) (and (<= 97 self) (<= self 122)))) }
Number isAlphaNumeric                   [ self isLetter or: [self isDigit] ]

"Strings and symbols (KScript's text is Maru's strings and symbols alike)"
String size                             { (if (symbol? self) (string-length (symbol->string self)) (string-length self)) }
String at: i                            { (let ((s (if (symbol? self) (symbol->string self) self))) (if (and (long? i) (< 0 i) (<= i (string-length s))) (string-at s (- i 1)) (error "Smalltalk: index " i " out of bounds for a string of " (string-length s)))) }
String indexOf: c                       { (let ((s (if (symbol? self) (symbol->string self) self)) (at 0)) (for (i 0 (string-length s)) (and (= 0 at) (= c (string-at s i)) (set at (+ i 1)))) at) }
String copyFrom: start to: stop         { (let ((s (if (symbol? self) (symbol->string self) self))) (string-copy s (- start 1) (+ 1 (- stop start)))) }
String asSymbol                         { (if (symbol? self) self (string->symbol self)) }
String asString                         { (if (symbol? self) (symbol->string self) self) }
String copyWithout: c                   { (let ((s (if (symbol? self) (symbol->string self) self)) (out ())) (for (i 0 (string-length s)) (or (= c (string-at s i)) (push out (string-at s i)))) (list->string (list-reverse! out))) }

"Arrays, counting from 1"
Array class new: n                      { (let ((a (array n))) (for (i 0 n) (set-array-at a i 'nil)) a) }
Array size                              { (array-length self) }
Array at: i                             { (if (and (long? i) (< 0 i) (<= i (array-length self))) (array-at self (- i 1)) (error "Smalltalk: index " i " out of bounds for an Array of " (array-length self))) }
Array = other                           { (ks-bool (ks-equal? self other)) }
Array , other                           { (list->array (concat-list (array->list self) (ks-elements-of other))) }
Array at: i put: v                      { (if (and (long? i) (< 0 i) (<= i (array-length self))) (set-array-at self (- i 1) v) (error "Smalltalk: index " i " out of bounds for an Array of " (array-length self))) }
ArrayedCollection replaceFrom: start to: stop with: source startingAt: from
                                        [ "as Squeak's primitive does, so a copy within one array moves as memmove would"
                                          (self == source and: [from < start])
                                            ifTrue: [stop to: start by: -1 do: [:i | self at: i put: (source at: from + i - start)]]
                                            ifFalse: [start to: stop do: [:i | self at: i put: (source at: from + i - start)]] ]
List size                               { (list-length self) }
List do: aBlock                         { (let () (list-do x self (ks-apply aBlock (list x) () ())) self) }
List collect: aBlock                    { (map (lambda (x) (ks-apply aBlock (list x) () ())) self) }
List do: aBlock displayingProgress: b  [ self do: aBlock ]
List asSet                              { (let ((out ())) (list-do x self (or (member? x out) (push out x))) (list-reverse! out)) }
List isEmpty                            { (ks-bool (not self)) }
List , other                            { (concat-list self (ks-elements-of other)) }
List reduce: aBlock                     { (let ((acc (car self))) (list-do x (cdr self) (set acc (ks-apply aBlock (list acc x) () ()))) acc) }

"Squeak's fonts: TTFontDescription allInstances are the fonts installed; KSFamily names families on demand, so none here"
TTFontDescription : Object ()
TTFontDescription class allInstances    [ #() ]
List at: i                              { (let ((c self) (k 1)) (while (and (pair? c) (< k i)) (set c (cdr c)) (set k (+ k 1))) (if (and (long? i) (< 0 i) (pair? c)) (car c) (error "Smalltalk: index " i " out of bounds for a list of " (list-length self)))) }

"Smalltalk, the system's dictionary: its classes and globals by name"
SystemDictionary at: key                { (or (ks-class-named (ks-dict-key key)) (let ((g (assq (ks-dict-key key) *ks-globals*))) (and g (cdr g))) (error "Smalltalk: no global named " key)) }
SystemDictionary at: key ifAbsent: aBlock { (or (ks-class-named (ks-dict-key key)) (let ((g (assq (ks-dict-key key) *ks-globals*))) (and g (cdr g))) (ks-apply aBlock () () ())) }
SystemDictionary includesKey: key       { (ks-bool (or (ks-class-named (ks-dict-key key)) (assq (ks-dict-key key) *ks-globals*))) }
Smalltalk := SystemDictionary new.

"An OrderedCollection keeps its elements in order (in a Maru list, items), a Set each one once (equal), an IdentitySet each
 object once (itself); what they answer is what KSWorld's compiler passes send them"
OrderedCollection initialize            { (let () (ks-set-slot self 'items ()) self) }
OrderedCollection add: x                { (let () (ks-set-slot self 'items (concat-list (ks-slot self 'items) (list x))) x) }
OrderedCollection addAll: c             { (let () (list-do x (ks-elements-of c) (ks-set-slot self 'items (concat-list (ks-slot self 'items) (list x)))) c) }
OrderedCollection removeLast            { (let* ((l (ks-slot self 'items)) (x (ks-last l))) (ks-set-slot self 'items (ks-but-last l)) x) }
OrderedCollection size                  { (list-length (ks-slot self 'items)) }
OrderedCollection asArray               { (list->array (ks-slot self 'items)) }
Set initialize                          { (let () (ks-set-slot self 'items ()) self) }
Set add: x                              { (let () (or (ks-set-has? self x) (ks-set-slot self 'items (concat-list (ks-slot self 'items) (list x)))) x) }
Set includes: x                         { (ks-bool (ks-set-has? self x)) }
Set do: aBlock                          { (let () (list-do x (ks-slot self 'items) (ks-apply aBlock (list x) () ())) self) }
Set collect: aBlock                     { (map (lambda (x) (ks-apply aBlock (list x) () ())) (ks-slot self 'items)) }
Set size                                { (list-length (ks-slot self 'items)) }
Set isEmpty                             { (ks-bool (not (ks-slot self 'items))) }
Set asArray                             { (list->array (ks-slot self 'items)) }
List asArray                            { (list->array self) }

"What every sequence answers, as Squeak's SequenceableCollection does, from at: and size (an Array, a String, a Maru list
 and an OrderedCollection answer those themselves); ArrayedCollection (fixed size) and OrderedCollection (grows) are siblings"
SequenceableCollection first            [ self at: 1 ]
SequenceableCollection second           [ self at: 2 ]
SequenceableCollection third            [ self at: 3 ]
SequenceableCollection fourth           [ self at: 4 ]
SequenceableCollection last             [ self at: self size ]
SequenceableCollection isEmpty          [ self size = 0 ]
SequenceableCollection notEmpty         [ self isEmpty not ]
SequenceableCollection do: aBlock       [ 1 to: self size do: [:i | aBlock value: (self at: i)] ]
SequenceableCollection collect: aBlock  [ | out | out := OrderedCollection new.  self do: [:x | out add: (aBlock value: x)].  out asArray ]
SequenceableCollection inject: acc into: aBlock [ | r | r := acc.  self do: [:x | r := aBlock value: r value: x].  r ]
SequenceableCollection includes: x      [ self do: [:e | e = x ifTrue: [^ true]].  false ]
OrderedCollection at: i                 { (let ((c (ks-slot self 'items)) (k 1)) (while (and (pair? c) (< k i)) (set c (cdr c)) (set k (+ k 1))) (if (and (long? i) (< 0 i) (pair? c)) (car c) (error "Smalltalk: index " i " out of bounds for an OrderedCollection of " (list-length (ks-slot self 'items))))) }
