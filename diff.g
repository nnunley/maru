# diff.g -- one grammar for a change and for jj's conflicts (doc/rfc/draft-ndn-erosion-attribution-00.md).  A unified
# diff (git's, and jj diff --git's) is the two-sided case, one side written as a diff; a jj conflict is the n-sided case,
# each side a diff or a snapshot, with the bases between snapshots.  A hunk's lines and a diff side's lines are one rule,
# body_line, and jj's six markers one parametric rule, marker :c, seven of the character it is given.  Entry rules: diff,
# for a change, and conflicted, for a file's text.  erosion-attribute.l makes the records the actions name.
<diff> : <text-parser> ()

eol		= "\n" | !. ;
rest		= (!"\n" .)* $:s					-> s ;
number		= [0-9]+ @$#:n						-> n ;

# a body line: a hunk's, or a diff side's
body_line	= " " rest:s eol					-> (list " " s)
		| "-" rest:s eol					-> (list '- s)
		| "+" rest:s eol					-> (list '+ s)
		| "\\ No newline at end of file" eol			-> 'no-newline ;

# ---- git's unified diff
diff		= file_diff*:fs						-> fs ;
file_diff	= "diff --git " rest:h eol ext_header*:xs old_new?:on hunk*:hs	-> (diff-file h xs (car on) hs) ;
ext_header	= ( "index " -> 'index | "new file mode " -> 'new | "deleted file mode " -> 'deleted
		  | "old mode " -> 'old-mode | "new mode " -> 'new-mode | "similarity index " -> 'similarity
		  | "dissimilarity index " -> 'dissimilarity | "rename from " -> 'rename-from | "rename to " -> 'rename-to
		  | "copy from " -> 'copy-from | "copy to " -> 'copy-to | "Binary files " -> 'binary ):k
		  rest:v eol						-> (cons k v) ;
old_new		= "--- " side_path:o eol "+++ " side_path:n eol		-> (cons o n) ;
side_path	= "/dev/null" (!"\n" .)*				-> ()
		| quoted:p (!"\n" .)*					-> (diff-strip-side p)
		| (!"\n" !"\t" .)* $:p (!"\n" .)*			-> (diff-strip-side p) ;
quoted		= "\"" qchar*:cs "\""					-> (list->string cs) ;
qchar		= "\\" ([0-7] [0-7] [0-7]) @$#8:n			-> n
		| "\\n" -> 10 | "\\t" -> 9 | "\\\"" -> 34 | "\\\\" -> 92
		| !"\"" . ;
hunk		= "@@ -" range:o " +" range:n " @@" rest eol body_line*:ls	-> (diff-hunk o n ls) ;
range		= number:s ("," number)?:c				-> (cons s (if c (car c) 1)) ;

# ---- jj's conflict markers
ch :c		= .:x &-> (= x c) ;
marker :c	= {ch c} {ch c} {ch c} {ch c} {ch c} {ch c} {ch c} ;
any_marker	= {marker ?<} | {marker ?>} | {marker ?%} | {marker ?\} | {marker ?+} | {marker ?-} ;
conflicted	= (conflict | plain_line)*:xs				-> xs ;
plain_line	= &. !{marker ?<} rest:s eol				-> s ;
conflict	= {marker ?<} " conflict " number:i " of " number:m eol side+:ss
		  {marker ?>} " conflict " number " of " number " ends" eol	-> (diff-conflict i m ss) ;
side		= {marker ?%} " diff from: " rest:f eol {marker ?\} "        to: " rest:t eol (!any_marker body_line)*:ls
								-> (diff-side 'diff (cons f t) ls)
		| {marker ?+} " " rest:l eol (!any_marker &. rest:s eol -> s)*:ls	-> (diff-side 'snapshot l ls)
		| {marker ?-} " " rest:l eol (!any_marker &. rest:s eol -> s)*:ls	-> (diff-side 'base l ls) ;
