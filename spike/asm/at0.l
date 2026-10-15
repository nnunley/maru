(require "text-parser.l")
(load "spike/asm/arm64.g.l")
(map dumpln (parse-string <a64spec> $file (contents-of-file-named "spike/asm/arm64.spec")))
