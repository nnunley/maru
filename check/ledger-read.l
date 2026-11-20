;;; check/ledger-read.l -- prints check/ledger as ledger.l reads it, (sums . notes); check/git-object.l runs it with git
;;; off PATH, to show the ledger reads with no git process.
(require "ledger.l")
(println (ledger-read (contents-of-file-named "check/ledger")))
