;;; assembler.l -- Generic Assembler Grammar Infrastructure
;;; Extracted from gen-asm-x86.k - provides C-like expression parsing for assembler generation

;; Load common assembler infrastructure
(println "(load \"asm-common.k\")")

;; Generic C-like expression grammar for processing #define, function calls, etc.
;; This grammar can process any architecture's assembler definitions
{
  comment       = "//" (!newline .)*
                | "/*" (!"*/" .)* "*/" ;
  blank         = " " | "\t" | "\\"newline ;
  newline       = ("\r""\n"*) | ("\n""\r"*) ;
  _             = blank* ;
  __            = (blank | comment | newline)* ;
  identifier    = ([a-zA-Z_][a-zA-Z_0-9]*)@$$ ;
  name          = identifier:id _ -> id ;
  unumber       = ( "0x"[0-9A-Fa-f]+ @$#16 | [0-9]+ @$#10 ) :s _ -> s ;
  number        = "-" unumber:n -> `(- ,n)
                |     unumber ;
  string        = "\"" (!"\"".)*@$:s "\""_ ( "#"name )* -> s ;
  primary       = number | name | string | "("_ expressions:e ")"_ -> e ;
  arglist       = expression?:e _ (","_ expression)*:f -> `(,@e ,@f) ;
  suffix        = primary:a     ( "("                           _ arglist:b     ")"_            -> (cons a b):a )*              -> a ;
  prefix        = suffix ;
  mulop         = prefix:a      ( ("*"|"/"|"%")@$$:o            _ mulop:b                       -> (list o    a b):a    )*      -> a ;
  addop         = mulop:a       ( ("+"|"-")@$$:o                _ addop:b                       -> (list o    a b):a    )*      -> a ;
  shift         = addop:a       ( ("<<"|">>")@$$:o              _ shift:b                       -> (list o    a b):a    )*      -> a ;
  inequality    = shift:a       ( ("<="|"<"|">="|">")@$$:o      _ inequality:b                  -> (list o    a b):a    )*      -> a ;
  equality      = inequality:a  ( ("=="|"!=")@$$:o              _ equality:b                    -> (list o    a b):a    )*      -> a ;
  bitand        = equality:a    ( "&"!"&"                       _ bitand:b                      -> (list '&   a b):a    )*      -> a ;
  bitxor        = bitand:a      ( "^"                           _ bitxor:b                      -> (list '^   a b):a    )*      -> a ;
  bitor         = bitxor:a      ( "|"!"|"                       _ bitor:b                       -> (list '|   a b):a    )*      -> a ;
  logand        = bitor:a       ( "&&"                          _ logand:b                      -> (list 'and a b):a    )*      -> a ;
  logor         = logand:a      ( "||"                          _ logor:b                       -> (list 'or  a b):a    )*      -> a ;
  ternary       = logor:a       ( "?"                           _ ternary:b     ":"_ ternary:c  -> (list 'if a b c):a   )*      -> a ;
  expression    = ternary:a     ( "="!"="                       _ ternary:b                     -> (list 'set a b):a    )*      -> a ;
  expressions   = expression:a  ( (","_ expression )+:b -> `(let () ,a ,@b):a )? -> a ;
  paramlist     = name?:i (","_ name)*:j -> `(,@i ,@j) ;
  macrodef      = identifier:id "("_ paramlist:p ")"_  expressions:e -> (list 'define-function id p e) ;
  constdef      = identifier:id _ expressions:e -> (list 'define-constant id e) ;
  definition    = __ "#"_ "define"_ ( macrodef | constdef ):d -> (dumpln d) ;
  definition*
}

;;; This grammar infrastructure is now ready to process architecture-specific
;;; assembler definitions. Import this file, then provide #define constants,
;;; register definitions, and instruction generators specific to your architecture.
;;; 
;;; Usage:
;;;   (load "grammars/core/assembler.l")
;;;   ;; Now provide architecture-specific #define statements and code
;;;   ;; The grammar will process them to generate the final assembler