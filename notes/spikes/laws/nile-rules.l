;;; SPIKE: well-typed Nile expressions as rules.  (expr ENV T E): E is an
;;; expression of type T in ENV, an alist of (name . type).

;; facts, from Nile's prelude
(rule infix-add  (infix "+" Number Number Number))
(rule infix-sub  (infix "-" Number Number Number))
(rule infix-div  (infix "/" Number Number Number))
(rule infix-eq   (infix "=" Number Number Boolean))
(rule infix-ne   (infix "≠" Number Number Boolean))
(rule infix-lt   (infix "<" Number Number Boolean))
(rule infix-le   (infix "≤" Number Number Boolean))
(rule infix-gt   (infix ">" Number Number Boolean))
(rule infix-ge   (infix "≥" Number Number Boolean))
(rule infix-and  (infix "∧" Boolean Boolean Boolean))
(rule infix-or   (infix "∨" Boolean Boolean Boolean))
(rule prefix-neg (prefix "-" Number Number))
(rule prefix-not (prefix "¬" Boolean Boolean))
(rule prefix-sqrt (prefix "√" Number Number))

;; the expression rules
(rule e-var    (expr $env $t (var $v))		(member ($v . $t) $env))
(rule e-num    (expr $env Number (num $n))	(numeral $n))
(rule e-prefix (expr $env $t (prefix $op $a))	(prefix $op $at $t) (expr $env $at $a))
(rule e-infix  (expr $env $t (infix $op $a $b))	(infix $op $at $bt $t) (expr $env $at $a) (expr $env $bt $b))

;; terms to Nile text: infix fully parenthesised, prefix operand in parens
(define-function nile-text (e)
  (let ((k (car e)))
    (cond
      ((= k 'var)	(symbol->string (cadr e)))
      ((= k 'num)	(cadr e))
      ((= k 'prefix)	(concat-strings (cadr e) "(" (nile-text (caddr e)) ")"))
      ((= k 'infix)	(concat-strings "(" (nile-text (caddr e)) " " (cadr e) " " (nile-text (cadddr e)) ")"))
      (else		(error "nile-text: "e)))))

(define nile-env '((a . Number) (b . Number) (p . Boolean) (q . Boolean)))
