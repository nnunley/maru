(require "text-parser.l")
(load "spike/asm/x86.g.l")
(map dumpln (parse-string <x86spec> $file (contents-of-file-named "spike/asm/x86.spec")))
