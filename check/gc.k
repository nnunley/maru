;;; Replaces maru-gc.k's main (check.l splices it in): the allocator must grow
;;; the heap for a request larger than all of it, and must merge adjacent free
;;; chunks.  500 small unreachable objects split the first heap block; after a
;;; collection, 20000 bytes fit in that block only if the freed run merged.

(define-function main int ((argc int) (argv char * *))
  (gc_initialise)
  (let ((i    0)
	(base (cast gc_memory_base long)))
    (while (< i 500)
      (gc_malloc 64)
      (set i (+ i 1)))
    (gc_gcollect)
    (gc_malloc 200000)
    (let ((big (cast (gc_malloc 20000) long)))
      (if (and (>= big base) (< big (+ base gc_quantum)))
	  (printf "gc ok\n")
	(printf "FAIL freed chunks did not merge\n"))))
  (return (cast 0 int)))
