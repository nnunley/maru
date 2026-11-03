# Hexadecimal literals in actions, as peg.g reads them.
<lit> : <text-parser> ()
hexv = -> 0x10 ;
hexn = -> -0x10 ;
upper = -> 0xFF ;
plain = -> 16 ;
