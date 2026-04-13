#lang br/quicklang
(require "game_parser.rkt"
         "game_tokenizer.rkt"
         brag/support)

(define (read-syntax src port)
  (define parse-tree (parse src (make-tokenizer port)))
  (strip-context parse-tree))

(provide read-syntax)