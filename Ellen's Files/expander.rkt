#lang br/quicklang
(require brag/support)
(require "TADA_Racket.rkt")

; SYNTAX HELPERS 
(begin-for-syntax
  (require racket/list)

  ; find-property: searches a list of syntax nodes for one that
  ; starts with a given symbol, returns the rest of its contents
  ; mirrors professor's find-property exactly
  (define (find-property which stx-list)
    (for/first ([stx (in-list (syntax->list stx-list))]
                #:when (and (syntax->list stx)
                            (eq? which (syntax->datum
                                        (car (syntax->list stx))))))
      (cdr (syntax->list stx))))  ; return all children, not just first

  ; find-definitions: like find-property but returns ALL matching nodes
  ; mirrors professor's find-definitions exactly
  (define (find-definitions which stx-list)
    (for/list ([stx (in-list (syntax->list stx-list))]
               #:when (and (syntax->list stx)
                           (eq? which (syntax->datum
                                       (car (syntax->list stx))))))
      stx)))


; expands a character node — ignored for now
(define-macro (character KEYWORD FEATURE ...)
  #'(displayln "--- character macro ran (ignored for now) ---"))

; macros (following professor's define-macro style)
; expands a room node into a define that calls make-room
; (room "create_room" (name "cave") (links "a" "b") ...)
; (define cave (make-room "cave" '("a" "b") '() '() 0 0 10 10))
(define-macro (room-def FEATURE ...)
  (with-pattern
      ([NAME-PARTS  (or (find-property 'rname      #'(FEATURE ...)) #'())]
       [SIZE-PARTS  (or (find-property 'size       #'(FEATURE ...)) #'())]
       [CHARS-PARTS (or (find-property 'characters #'(FEATURE ...)) #'())]
       [ITEMS-PARTS (or (find-property 'room-items #'(FEATURE ...)) #'())]
       [LINK-PARTS  (or (find-property 'links      #'(FEATURE ...)) #'())])
 
    ; pull the single name string (first child of rname node)
    (define name-stx
      (let ([parts (syntax->list #'NAME-PARTS)])
        (if (null? parts) #'"unnamed" (car parts))))
 
    ; pull size coords; default to 0 0 10 10 if size absent
    (define size-list (syntax->list #'SIZE-PARTS))
    (define x1-stx (if (>= (length size-list) 4) (list-ref size-list 0) #'0))
    (define y1-stx (if (>= (length size-list) 4) (list-ref size-list 1) #'0))
    (define x2-stx (if (>= (length size-list) 4) (list-ref size-list 2) #'10))
    (define y2-stx (if (>= (length size-list) 4) (list-ref size-list 3) #'10))
     ; build one (make-connection ...) form per link child
    ; example: ((link "Armory" 10 5) (link "Garden" 5 0)) is LINK-PARTS, get 
    (define conn-exprs
      (map (lambda (ln)
             (define parts (syntax->list ln))
             (define dest (cadr  parts)) 
             (define dx   (caddr parts))
             (define dy   (cadddr parts))
             #`(make-connection #,dest #,dx #,dy))
           (syntax->list #'LINK-PARTS)))
 
    ; chars and items are flat string lists
    (define char-stxs (syntax->list #'CHARS-PARTS))
    (define item-stxs (syntax->list #'ITEMS-PARTS))
 
    ; assemble final syntax — everything runs at RUNTIME (phase 0)
    (with-syntax ([ROOM-NAME          name-stx]
                  [X1                 x1-stx]
                  [Y1                 y1-stx]
                  [X2                 x2-stx]
                  [Y2                 y2-stx]
                  [(CONN-EXPR ...) (datum->syntax #'(FEATURE ...) conn-exprs)]
                  [(CHAR-STR ...)  (datum->syntax #'(FEATURE ...) char-stxs)]
                  [(ITEM-STR ...)  (datum->syntax #'(FEATURE ...) item-stxs)])
      #'(room-register!
         (make-room
          ROOM-NAME
          (list CONN-EXPR ...)
          (list CHAR-STR ...)
          (list ITEM-STR ...)
          X1 Y1 X2 Y2)))))

;start-def
(define-macro (start-def FEATURE ...)
  (with-pattern
      ([(ROOM)  (find-property 'start-room      #'(FEATURE ...))]
       [(TITLE)  (find-property 'start-title      #'(FEATURE ...))]
       [INTRO  (find-property 'start-intro      #'(FEATURE ...))])

        #'(make-main ROOM
                     TITLE
                    'INTRO)))


   

; top-level: expands the whole program
; (program room-defn ... char-defn ...)
; (#%module-begin (define cave ...) (define windy-hall ...) ...)
(define-macro (tada-macro-begin (program DEFN ...))
  ;(with-pattern
      ;([(ROOM-DEFN ...)  (find-definitions 'room-def      #'(DEFN ...))]
       ;[(CHAR-DEFN ...)  (find-definitions 'character #'(DEFN ...))])
    #'(#%module-begin
       (displayln "=== expander running ===")
       (displayln (format "defns found: ~a" '(DEFN ...)))
       DEFN ...
       ; CHAR-DEFN ...
       
       (displayln "=== done ===")))


(provide read-syntax)
(provide (rename-out [tada-macro-begin #%module-begin]))
(provide room-def character make-room)
(provide start-def )