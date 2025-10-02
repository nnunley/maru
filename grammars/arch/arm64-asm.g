;; arm64-asm.g -- ARM64 Assembly Grammar
;; Grammar for ARM64 assembly language constructs

{
  comment       = "//" (!newline .)*
                | "/*" (!"*/" .)* "*/" ;
  blank         = " " | "\t" | "\\"newline ;
  newline       = ("\r""\n"*) | ("\n""\r"*) ;
  _             = blank* ;
  __            = (blank | comment | newline)* ;
  
  ;; ARM64 specific tokens
  identifier    = ([a-zA-Z_][a-zA-Z_0-9]*)@$$ ;
  name          = identifier:id _ -> id ;
  register      = ([xXwW][0-9]+ | "sp" | "wsp" | "lr" | "xzr" | "wzr")@$$:r _ -> r ;
  unumber       = ( "0x"[0-9A-Fa-f]+ @$#16 | [0-9]+ @$#10 ) :s _ -> s ;
  number        = "-" unumber:n -> `(- ,n)
                |     unumber ;
  immediate     = "#" number:n -> `(imm ,n) ;
  
  ;; Memory addressing modes
  mem_base      = "[" _ register:r _ "]" _ -> `(mem ,r) ;
  mem_offset    = "[" _ register:r _ "," _ immediate:i _ "]" _ -> `(mem ,r ,i) ;
  mem_postidx   = "[" _ register:r _ "]" _ "," _ immediate:i _ -> `(mem-post ,r ,i) ;
  mem_preidx    = "[" _ register:r _ "," _ immediate:i _ "]" _ "!" _ -> `(mem-pre ,r ,i) ;
  memory        = mem_preidx | mem_postidx | mem_offset | mem_base ;
  
  ;; Operands
  operand       = register | immediate | memory | name ;
  operand_list  = operand:o _ ("," _ operand)*:os -> `(,o ,@os) ;
  
  ;; Instructions
  mov_insn      = "mov" _ register:rd _ "," _ operand:src _ -> `(mov ,rd ,src) ;
  add_insn      = "add" _ register:rd _ "," _ register:rn _ "," _ operand:op2 _ -> `(add ,rd ,rn ,op2) ;
  sub_insn      = "sub" _ register:rd _ "," _ register:rn _ "," _ operand:op2 _ -> `(sub ,rd ,rn ,op2) ;
  ldr_insn      = "ldr" _ register:rt _ "," _ memory:mem _ -> `(ldr ,rt ,mem) ;
  str_insn      = "str" _ register:rt _ "," _ memory:mem _ -> `(str ,rt ,mem) ;
  ldp_insn      = "ldp" _ register:rt1 _ "," _ register:rt2 _ "," _ memory:mem _ -> `(ldp ,rt1 ,rt2 ,mem) ;
  stp_insn      = "stp" _ register:rt1 _ "," _ register:rt2 _ "," _ memory:mem _ -> `(stp ,rt1 ,rt2 ,mem) ;
  cmp_insn      = "cmp" _ register:rn _ "," _ operand:op2 _ -> `(cmp ,rn ,op2) ;
  b_insn        = "b" _ name:label _ -> `(b ,label) ;
  bl_insn       = "bl" _ name:label _ -> `(bl ,label) ;
  blr_insn      = "blr" _ register:rn _ -> `(blr ,rn) ;
  ret_insn      = "ret" _ -> `(ret) ;
  beq_insn      = "beq" _ name:label _ -> `(beq ,label) ;
  bne_insn      = "bne" _ name:label _ -> `(bne ,label) ;
  
  ;; Instruction patterns
  instruction   = mov_insn | add_insn | sub_insn | ldr_insn | str_insn 
                | ldp_insn | stp_insn | cmp_insn | b_insn | bl_insn 
                | blr_insn | ret_insn | beq_insn | bne_insn ;
  
  ;; Labels and definitions
  label         = identifier:id ":" _ -> `(label ,id) ;
  directive     = "." identifier:d _ operand_list?:args _ -> `(directive ,d ,@args) ;
  
  ;; Top level constructs
  statement     = instruction | label | directive ;
  program       = __ statement*:stmts __ -> `(program ,@stmts) ;
}