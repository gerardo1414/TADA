#lang racket
(require brag/support)

(define adventure-lexer
  (lexer

   ;               WHITESPACE / PUNCTUATION
   [whitespace  (token lexeme #:skip? #t)]
   [":"         (token lexeme #:skip? #t)]
   ["{"         (token 'LBRACE    lexeme)]
   ["}"         (token 'RBRACE    lexeme)]
   ["["         (token 'LBRACKET  lexeme)]
   ["]"         (token 'RBRACKET  lexeme)]
   [","         (token 'COMMA     lexeme)]

   ;               STRINGS
   [(:: #\" (:* (:~ #\")) #\")
                (token 'STRING
                       (substring lexeme 1 (- (string-length lexeme) 1)))]

   ;               SECTION KEYWORDS
   ["create_room"      (token 'ROOM      lexeme)]
   ["create_character" (token 'CHARACTER lexeme)]

   ;               SHARED PROPERTIES
   ["name"      (token 'NAME       lexeme)]
   ["dialogue"  (token 'DIALOGUE   lexeme)]
   ["items"     (token 'ITEMS      lexeme)]
   ["quest"     (token 'QUEST      lexeme)]

   ;               ROOM PROPERTIES
   ["size"       (token 'SIZE       lexeme)]
   ["characters" (token 'CHARACTERS lexeme)]
   ["links"      (token 'LINKS      lexeme)]

   ;               CHARACTER PROPERTIES
   ["room"      (token 'ROOM-PROP  lexeme)]))


(define (make-tokenizer ip [path #f])
  (port-count-lines! ip)
  (lexer-file-path path)
  (define (next-token) (adventure-lexer ip))
  next-token)

(provide make-tokenizer)