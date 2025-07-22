#!/usr/bin/env eval
;;; test-source-tracking.l -- Test source location tracking

(load "emit-gc-c-debug.l")

;;; Generate the enhanced C program with source tracking
(generate-gc-c-debug-program)