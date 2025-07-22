#!/usr/bin/env eval
;;; compile-eval2-utf8.l -- Compile eval2 with UTF-8 support using C emitter

(load "emit.l")      ; Core emit framework 
(load "emit-c.l")    ; C code generation backend
(load "eval.l")      ; Load eval2 source

;;; Generate UTF-8 enabled eval2.c
(define-function compile-eval2-utf8 ()
  (println "/* eval2-utf8.c - UTF-8 enabled Maru evaluator */")
  (println "/* Generated from eval.l using emit-c.l backend */")
  (println)
  
  ;; Add UTF-8 support includes and macros
  (println "#define _GNU_SOURCE")
  (println "#include <stdio.h>")
  (println "#include <stdlib.h>") 
  (println "#include <string.h>")
  (println "#include <wchar.h>")
  (println "#include <locale.h>")
  (println)
  
  ;; UTF-8 compatibility macros
  (println "/* UTF-8 support macros */")
  (println "#if defined(WIN32)")
  (println "# define swnprintf(BUF, SIZE, FMT, ARG) swprintf(BUF, FMT, ARG)")
  (println "#else")  
  (println "# define swnprintf swprintf")
  (println "#endif")
  (println)
  
  ;; Generate global environment with C backend
  (gen-env-c *globals*)
  
  ;; Add UTF-8 initialization in main
  (println "/* UTF-8 initialization in main */")
  (println "int main(int argc, char **argv) {")
  (println "    setlocale(LC_ALL, \"\");")
  (println "    return eval_main(argc, argv);")
  (println "}")
  (println))

;;; Execute compilation
(compile-eval2-utf8)