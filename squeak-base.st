"squeak-base.st -- the platform under KSWorld's Smalltalk methods, in test-pepsi.l's form (read by squeak.g's library rule):
 Squeak's classes as test-pepsi.l lays them out, on the values KScript computes with (numbers, strings, KScript's lists,
 Maru's arrays, true, false and nil, blocks), with Squeak's meanings where pepsi's differ: an Array counts from 1.  Only
 what KSWorld's methods reach is here; a send nothing answers is an error naming it."

Object : ()
  UndefinedObject : Object ()
  Boolean : Object ()
    True : Boolean ()
    False : Boolean ()
  BlockClosure : Object ()
  Magnitude : Object ()
    Number : Magnitude ()
  Collection : Object ()
    SequenceableCollection : Collection ()
      List : SequenceableCollection ()
      ArrayedCollection : SequenceableCollection ()
        Array : ArrayedCollection ()
        String : ArrayedCollection ()

"Objects"
Object yourself                         [ self ]
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
Object initialize                       [ self ]
Object class basicNew                   { (ks-basic-new self) }
Object class new                        [ self basicNew initialize ]
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
Number to: stop do: aBlock              [ | i | i := self.  [i <= stop] whileTrue: [aBlock value: i.  i := i + 1] ]
Number to: stop by: step do: aBlock     [ | i | i := self.  step > 0
                                            ifTrue: [[i <= stop] whileTrue: [aBlock value: i.  i := i + step]]
                                            ifFalse: [[i >= stop] whileTrue: [aBlock value: i.  i := i + step]] ]

"Arrays, counting from 1"
Array class new: n                      { (let ((a (array n))) (for (i 0 n) (set-array-at a i 'nil)) a) }
Array size                              { (array-length self) }
Array at: i                             { (if (and (long? i) (< 0 i) (<= i (array-length self))) (array-at self (- i 1)) (error "Smalltalk: index " i " out of bounds for an Array of " (array-length self))) }
Array at: i put: v                      { (if (and (long? i) (< 0 i) (<= i (array-length self))) (set-array-at self (- i 1) v) (error "Smalltalk: index " i " out of bounds for an Array of " (array-length self))) }
ArrayedCollection replaceFrom: start to: stop with: source startingAt: from
                                        [ "as Squeak's primitive does, so a copy within one array moves as memmove would"
                                          (self == source and: [from < start])
                                            ifTrue: [stop to: start by: -1 do: [:i | self at: i put: (source at: from + i - start)]]
                                            ifFalse: [start to: stop do: [:i | self at: i put: (source at: from + i - start)]] ]
List size                               { (list-length self) }
List at: i                              { (let ((c self) (k 1)) (while (and (pair? c) (< k i)) (set c (cdr c)) (set k (+ k 1))) (if (and (long? i) (< 0 i) (pair? c)) (car c) (error "Smalltalk: index " i " out of bounds for a list of " (list-length self)))) }
