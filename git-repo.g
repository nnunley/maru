# git-repo.g -- what git-object.l reads of a repository: a .git file's gitdir: line, and a config's sections and keys.
# A config line is a [section] header, a key = value line, or anything else (comments, blank lines), skipped.
<git-repo> : <text-parser> ()
eol		= "\n" | !. ;
rest		= (!"\n" .)* $:s					-> s ;
space		= [ \t] ;
gitfile		= "gitdir: " rest:p eol					-> p ;
line		= rest:s eol						-> s ;	# commondir's path
name		= (!"]" !"\n" .)* $:n					-> n ;
key		= [a-zA-Z0-9-]+ $:k					-> k ;
value		= ( "\"" (!"\"" !"\n" .)* $:v "\""				-> v	# a value: quoted, or a word; then whitespace,
		  | (![ \t;#\r\n] .)* $:v					-> v	# a comment or a CR, skipped
		  ):v rest						-> v ;
config		= cline*:ls !.						-> ls ;
cline		= &. space* ( "[" name:n "]" rest eol			-> (cons 'section n)
			    | key:k space* "=" space* value:v eol		-> (cons k v)
			    | rest eol					-> () ) ;
