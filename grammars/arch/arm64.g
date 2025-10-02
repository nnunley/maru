# -*- coke -*-
# Comprehensive ARM64 assembly grammar
# Generated from complete architecture specification
# Instructions: 35 | Registers: 82

<arm64> : <text-parser> ()

blank     = [\t ] ;
eol       = "\n""\r"* | "\r""\n"* ;
_         = (blank | eol)* ;

digit     = [0-9] ;
letter    = [A-Z_a-z] ;
hexdigit  = [0-9A-Fa-f] ;
integer   = digit+ $#10:x _        -> x ;
hexint    = "0x" hexdigit+ $#16:x _ -> x ;
number    = hexint | integer ;
immediate = "#" number:x           -> `(ir-lit ,x) ;

;; Register definitions - 64-bit X registers
x0  = "x0"  -> 'x0 ;  x1  = "x1"  -> 'x1 ;  x2  = "x2"  -> 'x2 ;  x3  = "x3"  -> 'x3 ;
x4  = "x4"  -> 'x4 ;  x5  = "x5"  -> 'x5 ;  x6  = "x6"  -> 'x6 ;  x7  = "x7"  -> 'x7 ;
x8  = "x8"  -> 'x8 ;  x9  = "x9"  -> 'x9 ;  x10 = "x10" -> 'x10; x11 = "x11" -> 'x11;
x12 = "x12" -> 'x12; x13 = "x13" -> 'x13; x14 = "x14" -> 'x14; x15 = "x15" -> 'x15;
x16 = "x16" -> 'x16; x17 = "x17" -> 'x17; x18 = "x18" -> 'x18; x19 = "x19" -> 'x19;
x20 = "x20" -> 'x20; x21 = "x21" -> 'x21; x22 = "x22" -> 'x22; x23 = "x23" -> 'x23;
x24 = "x24" -> 'x24; x25 = "x25" -> 'x25; x26 = "x26" -> 'x26; x27 = "x27" -> 'x27;
x28 = "x28" -> 'x28; x29 = "x29" -> 'x29; x30 = "x30" -> 'x30;

;; 32-bit W registers
w0  = "w0"  -> 'w0 ;  w1  = "w1"  -> 'w1 ;  w2  = "w2"  -> 'w2 ;  w3  = "w3"  -> 'w3 ;
w4  = "w4"  -> 'w4 ;  w5  = "w5"  -> 'w5 ;  w6  = "w6"  -> 'w6 ;  w7  = "w7"  -> 'w7 ;
w8  = "w8"  -> 'w8 ;  w9  = "w9"  -> 'w9 ;  w10 = "w10" -> 'w10; w11 = "w11" -> 'w11;
w12 = "w12" -> 'w12; w13 = "w13" -> 'w13; w14 = "w14" -> 'w14; w15 = "w15" -> 'w15;
w16 = "w16" -> 'w16; w17 = "w17" -> 'w17; w18 = "w18" -> 'w18; w19 = "w19" -> 'w19;
w20 = "w20" -> 'w20; w21 = "w21" -> 'w21; w22 = "w22" -> 'w22; w23 = "w23" -> 'w23;
w24 = "w24" -> 'w24; w25 = "w25" -> 'w25; w26 = "w26" -> 'w26; w27 = "w27" -> 'w27;
w28 = "w28" -> 'w28; w29 = "w29" -> 'w29; w30 = "w30" -> 'w30;

;; Special registers
sp   = "sp"   -> 'sp ;   xzr  = "xzr"  -> 'xzr ;  wzr  = "wzr"  -> 'wzr ;
wsp  = "wsp"  -> 'wsp ;

;; Floating-point registers
d0 = "d0" -> 'd0; d1 = "d1" -> 'd1; d2 = "d2" -> 'd2; d3 = "d3" -> 'd3;
d4 = "d4" -> 'd4; d5 = "d5" -> 'd5; d6 = "d6" -> 'd6; d7 = "d7" -> 'd7;
s0 = "s0" -> 's0; s1 = "s1" -> 's1; s2 = "s2" -> 's2; s3 = "s3" -> 's3;
s4 = "s4" -> 's4; s5 = "s5" -> 's5; s6 = "s6" -> 's6; s7 = "s7" -> 's7;

;; Register categories
x_register = x0 | x1 | x2 | x3 | x4 | x5 | x6 | x7 | x8 | x9 | x10 | x11 | x12 | x13 | x14 | x15
           | x16 | x17 | x18 | x19 | x20 | x21 | x22 | x23 | x24 | x25 | x26 | x27 | x28 | x29 | x30 ;

w_register = w0 | w1 | w2 | w3 | w4 | w5 | w6 | w7 | w8 | w9 | w10 | w11 | w12 | w13 | w14 | w15
           | w16 | w17 | w18 | w19 | w20 | w21 | w22 | w23 | w24 | w25 | w26 | w27 | w28 | w29 | w30 ;

d_register = d0 | d1 | d2 | d3 | d4 | d5 | d6 | d7 ;
s_register = s0 | s1 | s2 | s3 | s4 | s5 | s6 | s7 ;

special_register = sp | xzr | wzr | wsp ;
register = x_register | w_register | d_register | s_register | special_register ;

;; Memory addressing modes
memory_ref = "[" _ register:base _ "]" _
           -> `(ir-mem-ref (ir-get ',base))
           | "[" _ register:base "," _ immediate:offset _ "]" _
           -> `(ir-mem-ref (ir-add (ir-get ',base) ,offset))
           | "[" _ register:base "," _ register:index _ "]" _
           -> `(ir-mem-ref (ir-add (ir-get ',base) (ir-get ',index)))
           | "[" _ register:base "," _ immediate:offset _ "]" _ "!" _
           -> `(ir-mem-ref (ir-pre-inc ',base ,offset))
           | "[" _ register:base _ "]" _ "," _ immediate:offset _
           -> `(ir-mem-ref (ir-post-inc ',base ,offset)) ;

;; Condition codes
condition = "eq" -> 'eq | "ne" -> 'ne | "cs" -> 'cs | "cc" -> 'cc
          | "mi" -> 'mi | "pl" -> 'pl | "vs" -> 'vs | "vc" -> 'vc
          | "hi" -> 'hi | "ls" -> 'ls | "ge" -> 'ge | "lt" -> 'lt
          | "gt" -> 'gt | "le" -> 'le | "al" -> 'al ;

;; Labels
label = letter (letter | digit | "_")*@$:name _ -> name ;

;; Data Movement Instructions
mov_imm_x = "mov" _ x_register:dst "," _ immediate:src
          -> `(ir-set ',dst ,src) ;

mov_imm_w = "mov" _ w_register:dst "," _ immediate:src
          -> `(ir-set ',dst ,src) ;

mov_x_x = "mov" _ x_register:dst "," _ x_register:src
        -> `(ir-set ',dst (ir-get ',src)) ;

mov_w_w = "mov" _ w_register:dst "," _ w_register:src
        -> `(ir-set ',dst (ir-get ',src)) ;

;; Arithmetic Instructions
add_x_x_x = "add" _ x_register:rd "," _ x_register:rn "," _ x_register:rm
          -> `(ir-set ',rd (ir-add (ir-get ',rn) (ir-get ',rm))) ;

add_w_w_w = "add" _ w_register:rd "," _ w_register:rn "," _ w_register:rm
          -> `(ir-set ',rd (ir-add (ir-get ',rn) (ir-get ',rm))) ;

add_x_x_imm = "add" _ x_register:rd "," _ x_register:rn "," _ immediate:imm
            -> `(ir-set ',rd (ir-add (ir-get ',rn) ,imm)) ;

add_w_w_imm = "add" _ w_register:rd "," _ w_register:rn "," _ immediate:imm
            -> `(ir-set ',rd (ir-add (ir-get ',rn) ,imm)) ;

sub_x_x_x = "sub" _ x_register:rd "," _ x_register:rn "," _ x_register:rm
          -> `(ir-set ',rd (ir-sub (ir-get ',rn) (ir-get ',rm))) ;

sub_w_w_w = "sub" _ w_register:rd "," _ w_register:rn "," _ w_register:rm
          -> `(ir-set ',rd (ir-sub (ir-get ',rn) (ir-get ',rm))) ;

sub_x_x_imm = "sub" _ x_register:rd "," _ x_register:rn "," _ immediate:imm
            -> `(ir-set ',rd (ir-sub (ir-get ',rn) ,imm)) ;

sub_w_w_imm = "sub" _ w_register:rd "," _ w_register:rn "," _ immediate:imm
            -> `(ir-set ',rd (ir-sub (ir-get ',rn) ,imm)) ;

;; Load/Store Instructions
ldr_x_mem = "ldr" _ x_register:rt "," _ memory_ref:mem
          -> `(ir-set ',rt (ir-load ,mem)) ;

ldr_w_mem = "ldr" _ w_register:rt "," _ memory_ref:mem
          -> `(ir-set ',rt (ir-load ,mem)) ;

str_x_mem = "str" _ x_register:rt "," _ memory_ref:mem
          -> `(ir-store ,mem (ir-get ',rt)) ;

str_w_mem = "str" _ w_register:rt "," _ memory_ref:mem
          -> `(ir-store ,mem (ir-get ',rt)) ;

;; Load/Store Byte
ldrb_w_mem = "ldrb" _ w_register:rt "," _ memory_ref:mem
           -> `(ir-set ',rt (ir-load-byte ,mem)) ;

strb_w_mem = "strb" _ w_register:rt "," _ memory_ref:mem
           -> `(ir-store-byte ,mem (ir-get ',rt)) ;

;; Load/Store Halfword
ldrh_w_mem = "ldrh" _ w_register:rt "," _ memory_ref:mem
           -> `(ir-set ',rt (ir-load-half ,mem)) ;

strh_w_mem = "strh" _ w_register:rt "," _ memory_ref:mem
           -> `(ir-store-half ,mem (ir-get ',rt)) ;

;; Load/Store Pair
ldp_x_x_mem = "ldp" _ x_register:rt1 "," _ x_register:rt2 "," _ memory_ref:mem
            -> `(ir-load-pair ,mem ',rt1 ',rt2) ;

stp_x_x_mem = "stp" _ x_register:rt1 "," _ x_register:rt2 "," _ memory_ref:mem
            -> `(ir-store-pair ,mem ',rt1 ',rt2) ;

;; Compare Instructions
cmp_x_x = "cmp" _ x_register:rn "," _ x_register:rm
        -> `(ir-cmp (ir-get ',rn) (ir-get ',rm)) ;

cmp_w_w = "cmp" _ w_register:rn "," _ w_register:rm
        -> `(ir-cmp (ir-get ',rn) (ir-get ',rm)) ;

cmp_x_imm = "cmp" _ x_register:rn "," _ immediate:imm
          -> `(ir-cmp (ir-get ',rn) ,imm) ;

cmp_w_imm = "cmp" _ w_register:rn "," _ immediate:imm
          -> `(ir-cmp (ir-get ',rn) ,imm) ;

;; Branch Instructions
b_label = "b" _ label:target
        -> `(ir-branch ',target) ;

beq_label = "beq" _ label:target
          -> `(ir-branch-eq ',target) ;

bne_label = "bne" _ label:target
          -> `(ir-branch-ne ',target) ;

blr_x = "blr" _ x_register:rn
      -> `(ir-call-reg ',rn) ;

ret = "ret" _
    -> `(ir-return) ;

;; Address Calculation
adrp_x_label = "adrp" _ x_register:rd "," _ label:target
             -> `(ir-set ',rd (ir-page-addr ',target)) ;

;; Conditional Set
cset_x_cond = "cset" _ x_register:rd "," _ condition:cond
            -> `(ir-set ',rd (ir-condition ',cond)) ;

cset_w_cond = "cset" _ w_register:rd "," _ condition:cond
            -> `(ir-set ',rd (ir-condition ',cond)) ;

;; Floating-point Instructions
ldr_d_mem = "ldr" _ d_register:rt "," _ memory_ref:mem
          -> `(ir-set ',rt (ir-load-fp64 ,mem)) ;

str_d_mem = "str" _ d_register:rt "," _ memory_ref:mem
          -> `(ir-store-fp64 ,mem (ir-get ',rt)) ;

ldr_s_mem = "ldr" _ s_register:rt "," _ memory_ref:mem
          -> `(ir-set ',rt (ir-load-fp32 ,mem)) ;

str_s_mem = "str" _ s_register:rt "," _ memory_ref:mem
          -> `(ir-store-fp32 ,mem (ir-get ',rt)) ;

;; Instruction selector
instruction = mov_imm_x | mov_imm_w | mov_x_x | mov_w_w
            | add_x_x_x | add_w_w_w | add_x_x_imm | add_w_w_imm
            | sub_x_x_x | sub_w_w_w | sub_x_x_imm | sub_w_w_imm
            | ldr_x_mem | ldr_w_mem | str_x_mem | str_w_mem
            | ldrb_w_mem | strb_w_mem | ldrh_w_mem | strh_w_mem
            | ldp_x_x_mem | stp_x_x_mem
            | cmp_x_x | cmp_w_w | cmp_x_imm | cmp_w_imm
            | b_label | beq_label | bne_label | blr_x | ret
            | adrp_x_label | cset_x_cond | cset_w_cond
            | ldr_d_mem | str_d_mem | ldr_s_mem | str_s_mem ;

program = _ instruction*:insns (!. ~"instruction") -> insns ;
