#lang racket

(require brag/support)

(define adventure-lexer
  (lexer

   [whitespace (token lexeme #:skip? #t)]

   ["{"  (token 'LBRACE "{")]
   ["}"  (token 'RBRACE "}")]
   [":"  (token 'COLON ":")]

   [(from/to #\" #\")
    (token 'STRING lexeme)]
   
   ["["  (token 'LBRACKET "[")]
   ["]"  (token 'RBRACKET "]")]
   [","  (token 'COMMA    ",")]

   ; special create keywords
   ["create_room" (token 'ROOM lexeme)]

   ; general properties
   ["name" (token 'NAME lexeme)]

   ; room properties
   ["links" (token 'LINKS lexeme)]

   [(eof) (token 'EOF "eof")]))

(define (make-tokenizer ip [path #f])
  (port-count-lines! ip)
  (lexer-file-path path)
  (define (next-token) (adventure-lexer ip))
  next-token)

(provide make-tokenizer)
