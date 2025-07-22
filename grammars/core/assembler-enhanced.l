;;; assembler-enhanced.l -- Enhanced Assembler Grammar with Pattern Reduction
;;; Builds on the generic assembler.l with macro systems to reduce repetition

;; Load the base assembler grammar
(load "grammars/core/assembler.l")

;; Enhanced grammar extensions for pattern reduction
{
  ;; Instruction family definitions  
  insn_family   = identifier:base "_FAMILY" _ "(" _ insn_variant_list:variants ")" _ 
                  -> (list 'define-instruction-family base variants) ;
  
  insn_variant  = identifier:suffix ":" format_list:formats 
                  -> (list suffix formats) ;
                  
  insn_variant_list = insn_variant:v _ ("," _ insn_variant)*:vs -> `(,v ,@vs) ;
  
  format_list   = format:f _ ("|" _ format)*:fs -> `(,f ,@fs) ;
  
  format        = identifier:name -> name ;
  
  ;; Operand type patterns
  operand_type  = "reg" | "mem" | "imm" | "disp" ;
  
  ;; Size specifiers  
  size_spec     = "8" | "16" | "32" | "64" ;
  
  ;; Pattern templates
  pattern_def   = "PATTERN" _ identifier:name _ "(" _ param_list:params ")" _ 
                  "=" _ pattern_body:body -> (list 'define-pattern name params body) ;
                  
  pattern_body  = string | identifier | "(" _ pattern_elements ")" ;
  pattern_elements = pattern_element*:elems -> elems ;
  pattern_element = string | identifier | number ;
  
  ;; Extended definitions include pattern support
  enhanced_definition = pattern_def | insn_family | definition ;
  enhanced_definition*
}

;; Instruction family macro system
;; This allows defining groups of related instructions with automatic generation

;; Pattern: FAMILY_NAME(base_opcode, variants...)
;; Generates: NAMErr, NAMErm, NAMEmr, NAMEir variants automatically

#define DEFINE_ARITH_FAMILY(NAME, OPCODE_BASE) \
  NAME##Brr(RS, RD, X)     _O_Mrm(X, OPCODE_BASE+0x0, _b11, _r1(RS), _r1(RD)) \
  NAME##Wrr(RS, RD, X)     _wO_Mrm(X, OPCODE_BASE+0x1, _b11, _r2(RS), _r2(RD)) \
  NAME##Lrr(RS, RD, X)     _O_Mrm(X, OPCODE_BASE+0x1, _b11, _r4(RS), _r4(RD)) \
  NAME##Bmr(MD,MB,MI,MS,RD,X) _O_r_X(X, OPCODE_BASE+0x2, _r1(RD), MD,MB,MI,MS) \
  NAME##Wmr(MD,MB,MI,MS,RD,X) _wO_r_X(X, OPCODE_BASE+0x3, _r2(RD), MD,MB,MI,MS) \
  NAME##Lmr(MD,MB,MI,MS,RD,X) _O_r_X(X, OPCODE_BASE+0x3, _r4(RD), MD,MB,MI,MS) \
  NAME##Brm(RS,MD,MB,MI,MS,X) _O_r_X(X, OPCODE_BASE+0x0, _r1(RS), MD,MB,MI,MS) \
  NAME##Wrm(RS,MD,MB,MI,MS,X) _wO_r_X(X, OPCODE_BASE+0x1, _r2(RS), MD,MB,MI,MS) \
  NAME##Lrm(RS,MD,MB,MI,MS,X) _O_r_X(X, OPCODE_BASE+0x1, _r4(RS), MD,MB,MI,MS) \
  NAME##Bir(IM, RD, X)     _O_Mrm_B(X, 0x80, _b11, OPCODE_BASE##_IMM_CODE, _r1(RD), _s1(IM)) \
  NAME##Wir(IM, RD, X)     _wOs_Mrm_sW(X, 0x81, _b11, OPCODE_BASE##_IMM_CODE, _r2(RD), _s2(IM)) \
  NAME##Lir(IM, RD, X)     _Os_Mrm_sL(X, 0x81, _b11, OPCODE_BASE##_IMM_CODE, _r4(RD), IM) \
  NAME##Bim(IM,MD,MB,MI,MS,X) _O_r_X_B(X, 0x80, OPCODE_BASE##_IMM_CODE, MD,MB,MI,MS, _s1(IM)) \
  NAME##Wim(IM,MD,MB,MI,MS,X) _wOs_r_X_sW(X, 0x81, OPCODE_BASE##_IMM_CODE, MD,MB,MI,MS, _s2(IM)) \
  NAME##Lim(IM,MD,MB,MI,MS,X) _Os_r_X_sL(X, 0x81, OPCODE_BASE##_IMM_CODE, MD,MB,MI,MS, IM)

;; Single-operand instruction family
#define DEFINE_UNARY_FAMILY(NAME, OPCODE) \
  NAME##Br(RD, X)          _O_Mrm(X, OPCODE, _b11, _b000, _r1(RD)) \
  NAME##Wr(RD, X)          _wO_Mrm(X, OPCODE+1, _b11, _b000, _r2(RD)) \
  NAME##Lr(RD, X)          _O_Mrm(X, OPCODE+1, _b11, _b000, _r4(RD)) \
  NAME##Bm(MD,MB,MI,MS,X)  _O_r_X(X, OPCODE, _b000, MD,MB,MI,MS) \
  NAME##Wm(MD,MB,MI,MS,X)  _wO_r_X(X, OPCODE+1, _b000, MD,MB,MI,MS) \
  NAME##Lm(MD,MB,MI,MS,X)  _O_r_X(X, OPCODE+1, _b000, MD,MB,MI,MS)

;; Move instruction family (special case)
#define DEFINE_MOVE_FAMILY(NAME) \
  NAME##Brr(RS, RD, X)     _O_Mrm(X, 0x88, _b11, _r1(RS), _r1(RD)) \
  NAME##Wrr(RS, RD, X)     _wO_Mrm(X, 0x89, _b11, _r2(RS), _r2(RD)) \
  NAME##Lrr(RS, RD, X)     _O_Mrm(X, 0x89, _b11, _r4(RS), _r4(RD)) \
  NAME##Lir(IM, RD, X)     _O_L(X, 0xb8+_r4(RD), IM) \
  NAME##Wir(IM, RD, X)     _wO_W(X, 0xb8+_r2(RD), IM) \
  NAME##Bir(IM, RD, X)     _O_B(X, 0xb0+_r1(RD), IM)

;; Conditional instruction families
#define DEFINE_BRANCH_FAMILY(NAME, CONDITION_CODE) \
  NAME(LABEL, X)           _O_L(X, 0x0f80+CONDITION_CODE, LABEL)

;; Pattern for instruction groups with consistent encoding
#define PATTERN_GROUP(PREFIX, OPERATIONS) \
  PREFIX##_FAMILY(OPERATIONS)

;;; This enhanced grammar allows defining instruction families that automatically
;;; generate all size and addressing mode variants, reducing the repetitive 
;;; #define statements significantly while maintaining full functionality.
;;;
;;; Usage example:
;;;   DEFINE_ARITH_FAMILY(ADD, 0x00)  ; Generates ADDBrr, ADDWrr, ADDLrr, etc.
;;;   DEFINE_UNARY_FAMILY(INC, 0x40)  ; Generates INCBr, INCWr, INCLr, etc.