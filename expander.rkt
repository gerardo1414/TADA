#lang racket

(require "parse-only.rkt")  ; gives you access to read-syntax
(require brag/support)
(require "game_tokenizer.rkt")
(require "parser.rkt")

(define (parse-file path)
  (define port (open-input-file path))
  (read-line port)  ; skip the #lang line
  (define tree (parse path (make-tokenizer port path)))
  (close-input-port port)
  ; strip the outer syntax wrapper, get the raw list
  (syntax->datum tree))

; (require "final_project_racket.rkt") a placeholder function for gerardo, when expanded program runs
(define (make-room name connections characters items x1 y1 x2 y2)
  (displayln (format "Created room '~a', links: ~a" name connections))
  (list name connections characters items x1 y1 x2 y2))


;helper function below
(define (clean-string s) (string-trim s "\"")) ;removes quotations from parsed strings

(define (extract-list val-node) ;This function processes parsed list values and extracts clean strings,
                                ;filtering out commas and unnecessary structure from the parse tree.
  (match val-node
    [`(value ,items ...)
     (filter-map (match-lambda
                   [(? string? s) #:when (not (equal? s ",")) (clean-string s)]
                   [`(value ,s) (clean-string s)]
                   [_ #f])
                 items)]))

(define (extract-room-props pairs) ;walks through parsed room properties and extract specific fields, like room name and its ocnnections (as seen in example1 parse tree) 
  (for/fold ([name ""] [links '()] #:result (values name links))
            ([pair pairs])
    (match pair
      [`(room-property-pair (room-property "name")  (value ,s))  (values (clean-string s) links)]
      [`(room-property-pair (room-property "links") ,val-node)   (values name (extract-list val-node))]
      [_ (values name links)])))

;the actual expander here
(define (expand node)
  (match node
    [`(program ,stmts ...) ;if node a program, recursively expand each statement and wrap them in a begin block so they execute sequentially in Racket.
     `(begin ,@(map expand stmts))]
    [`(room ,_ ,pairs ...) ; when encoutering room node, extract properties and make a racket define statement that creates the room using make-room.
     (define-values (name links) (extract-room-props pairs))
     `(define ,(string->symbol name) (make-room ,name ',links '() '() 0 0 10 10))] ;I convert the room name into a symbol so it can be used as a variable name, and then generate a call to make-room with the parsed data.
    [else
     (error (format "expand: unknown node: ~a" node))]));if node not recognized, give error

;entry port
(define (expand-program parse-tree)
  (define expanded (expand parse-tree))
  (displayln "Expanded:") (pretty-print expanded) ;print expanded parse tree from example1
  (displayln "Running:")
  (define ns (make-base-namespace))
  (namespace-set-variable-value! 'make-room make-room #t ns) ;“The code I generate runs in its own environment,
                                                             ;so I have to manually give it access to the functions it needs, like make-room
  (eval expanded ns))

(expand-program (parse-file "example1.rkt"))