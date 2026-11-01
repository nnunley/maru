;;; john.g reads the three complete JOHN programs (check/john/*.john) statement by
;;; statement, and the forms that settle its precedence and relation rules are these.
(require "john.l")

(define ok 1)
(define-function expect (what c) (or c (let () (set ok ()) (println "FAIL " what))))
(define-function nth-form (forms n) (if (= n 0) (car forms) (nth-form (cdr forms) (- n 1))))

(let ((hanoi (john-read "check/john/hanoi4.john"))
      (puzzle (john-read "check/john/puzzle-allocator.john"))
      (x86 (john-read "check/john/x86-allocator.john")))
  (expect "statement counts 31, 47, 33" (equal (map list-length (list hanoi puzzle x86)) '(31 47 33)))
  ;; effects all read the old world: its supporter supporting is two sends, not a relation
  (expect "Hanoi's move" (equal (nth-form hanoi 24)
    '(action Disk move ((Surface Surface)) (set Surface supporting it) (set (send it supporter) supporting None) (set it supporter Surface))))
  (expect "a declared relation is infix" (equal (nth-form hanoi 27) '(rule Disk move (rel smaller it Surface))))
  ;; a keyword argument is one primary and + ends the send: three lists concatenated
  (expect "allocationWith:" (equal (nth-form x86 13)
    '(qualify Register allocationWith: (Variable)
       (value (+ (+ (send (send it allocations) to: (- (send (send Variable live-range) first) 1)) (send Variable repeatList))
		 (send (send it allocations) from: (send (send Variable live-range) last)))))))
  ;; sends chain on after a keyword argument, and = ranks below them
  (expect "at: then length" (equal (nth-form x86 21)
    '(rule Allocator split (= (send (send (send RegisterFrom allocations) at: (send it next-variable-start)) length) 2))))
  ;; an effect's if guards the effect before it only (G4)
  (expect "a guarded effect" (equal (nth-form x86 15)
    '(action Allocator assign ((Register Register) (Variable Variable))
       (set Register allocations (send Register allocationWith: Variable))
       (set (send Register next-right) allocations (send (send Register next-right) allocationWith: Variable) (= (send Variable length) 4))
       (set it unallocated-variables (send (send it unallocated-variables) rest)))))
  ;; the memo's goal reads live-vars size, a name, where each live-vars size is meant
  (expect "the puzzle goal as written" (equal (nth-form puzzle 45)
    '(goal Allocator done () (every (send it instructions) (= (send (send each allocated-vars) size) (send live-vars size))))))
  (expect "a multi-keyword send" (equal (nth-form puzzle 9)
    '(qualify Block span-for-var:at: (Var Inst)
       (value (send it area-span-x:area-span-y: (send (send Var inst-piece: Inst) x-length) (send (send Var inst-piece: Inst) y-length)))))))

;; a name no rel-qualify declares reads as a send; a declared one is infix even above its rel-qualify
(expect "an undeclared name is a send" (equal (john-read-text "it smaller Surface.") '((query (send (send it smaller) Surface)))))
(expect "a relation used before its rel-qualify" (equal (car (john-read-text "rule Disk move is it smaller Surface. rel-qualify Surface:S1 smaller Surface:S2 if S1 = S2."))
  '(rule Disk move (rel smaller it Surface))))
(expect "a computed object name" (equal (john-read-text "for [ [ \"Va\" name ] ] do make V (each first).")
					'((for (list (list (send "Va" name))) (make V (send each first))))))
;; ours, not JOHN's: for some is for any; over a class it means its instances, an evaluation rule,
;; so it reads alike whether or not the class is created yet
(expect "for some over a class" (equal (john-read-text "qualify Allocator canAllocate: Variable if for some Register do each canAllocate: Variable = yes.")
  '((qualify Allocator canAllocate: (Variable) (if (any Register (= (send each canAllocate: Variable) yes)))))))
(expect "for some over a collection" (equal (john-read-text "for some its items do each = 2.") '((query (any (send it items) (= each 2))))))
(and ok (println "john forms ok"))
