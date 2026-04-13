#lang racket
(require "game_tokenizer.rkt")

(define simple-source
  "create_room {
     name: \"cave\"
     exits: [north, south]
   }")

(define (print-tokens thunk)
  (let loop ()
    (define tok (thunk))
    (when tok
      (displayln tok)
      (loop))))

(print-tokens (make-tokenizer simple-source))