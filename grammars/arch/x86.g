# -*- coke -*-
# Generated x86-64 assembly grammar
# Auto-generated from architecture specification

<x86> : <text-parser> ()

blank     = [\t ] ;
eol       = "\n""\r"* | "\r""\n"* ;
_         = (blank | eol)* ;

digit     = [0-9] ;
letter    = [A-Z_a-z] ;
integer   = digit+ $#10:x _        -> x ;
immediate = "$" integer:x         -> `(ir-lit ,x) ;

rax       = "%rax"                 -> 'rax ;
rbx       = "%rbx"                 -> 'rbx ;
rcx       = "%rcx"                 -> 'rcx ;
rdx       = "%rdx"                 -> 'rdx ;
register  = rax | rbx | rcx | rdx ;

mov_reg_reg = "mov" _ register:src "," _ register:dst
              -> `(ir-set ',dst (ir-get ',src)) ;

mov_imm_reg = "mov" _ immediate:src "," _ register:dst
              -> `(ir-set ',dst ,src) ;

instruction = mov_reg_reg | mov_imm_reg ;

program     = _ instruction*:insns (!. ~"instruction") -> insns ;

