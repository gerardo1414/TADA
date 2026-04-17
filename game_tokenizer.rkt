#lang racket

(require brag/support)

(define adventure-lexer
  (lexer

   [whitespace (token lexeme #:skip? #t)]

   ["{"  (token 'LBRACE "{")]
   ["}"  (token 'RBRACE "}")]
   [":"  (token 'COLON ":")]

 
 [(:: #\" (:* (:~ #\")) #\")
 (token 'STRING
        (substring lexeme 1 (- (string-length lexeme) 1)))]
   
   ["["  (token 'LBRACKET "[")]
   ["]"  (token 'RBRACKET "]")]
   [","  (token 'COMMA    ",")]

   ; special create keywords
   ["create_room" (token 'ROOM lexeme)]

   ; general properties
   ["name" (token 'NAME lexeme)]
   ["size"       (token 'SIZE lexeme)]
   ["characters" (token 'CHARACTERS lexeme)]
   ["dialogue"   (token 'DIALOGUE lexeme)]
   ["items"      (token 'ITEMS lexeme)]
   ["quest"      (token 'QUEST lexeme)]

   ; room properties
   ["links" (token 'LINKS lexeme)]))

  

(define (make-tokenizer ip [path #f])
  (port-count-lines! ip)
  (lexer-file-path path)
  (define (next-token) (adventure-lexer ip))
  next-token)

(provide make-tokenizer)
