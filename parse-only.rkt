#lang br/quicklang
(require "parser.rkt"
         "game_tokenizer.rkt"
         brag/support)

(define (read-syntax path port)
  (define parse-tree (parse path (make-tokenizer port path)))
  (strip-bindings
   #`(module smpl-parser-mod "parse-only.rkt"
       #,parse-tree)))
(provide read-syntax)

(define-macro (parser-only-mb PARSE-TREE)
  #'(#%module-begin
     'PARSE-TREE))
(provide (rename-out [parser-only-mb #%module-begin]))