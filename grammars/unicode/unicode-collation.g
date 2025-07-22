# Unicode Collation Algorithm (UCA) Grammar
# Parses Unicode collation data and generates optimized tables

# Unicode Collation Element
# Format: <codepoint> ; <weights> # <name>
# Example: 0041 ; [.1C47.0020.0008] # LATIN CAPITAL LETTER A

hex_digit = [0-9A-Fa-f]
codepoint = hex_digit+                -> (string->number $0 16) ;
weight    = hex_digit+                -> (string->number $0 16) ;

# Collation weights [primary.secondary.tertiary.quaternary]
weight_list = "[" "." weight:p "." weight:s "." weight:t ("." weight:q)? "]"
    -> (list p s t (or q 0)) ;

# Variable weight marker
variable = "*"                        -> 'variable ;

# Comment (ignored)
comment = "#" (![\n\r] .)*           -> () ;

# Whitespace
ws = [ \t]+

# Newline
nl = [\n\r]+

# Collation element entry
collation_entry = codepoint:cp ws? ";" ws? weight_list:w ws? comment? nl?
    -> (list 'collation cp w) ;

# Contraction (multi-character sequence)
contraction = codepoint:cp1 ws codepoint:cp2 (ws codepoint:more)* 
              ws? ";" ws? weight_list:w
    -> (list 'contraction (cons cp1 (cons cp2 more)) w) ;

# Special markers
special_marker = "@" ("version" | "variable" | "backwards" | "relation"):type ws? value:v
    -> (list 'special type v) ;

# Complete collation rule
collation_rule = special_marker | contraction | collation_entry | ws | nl | comment

# Full collation table
collation_table = collation_rule*
    -> (filter (lambda (x) (and x (pair? x))) $1) ;

# Locale-specific tailoring
tailoring_op = "<" "<" "<" "<"    -> 'quaternary ;
             | "<" "<" "<"         -> 'tertiary ;
             | "<" "<"             -> 'secondary ;
             | "<"                 -> 'primary ;
             | "="                 -> 'identical ;

# Tailoring rule (customize sort order)
tailoring = "&" ws? base:b ws? tailoring_op:op ws? target:t
    -> (list 'tailor b op t) ;

# Generate optimized lookup table
optimize_table = collation_table:entries
    -> `(generate-collation-table ,entries) ;