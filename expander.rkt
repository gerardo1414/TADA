#lang br/quicklang
(require "game_tokenizer.rkt")
(require "parser.rkt")
(require brag/support)

; runtime (swap for require when Gerardo fixes his file)
(define (make-room name connections characters items x1 y1 x2 y2)
  (displayln (format "Room created: ~a" name))
  (displayln (format "  Links: ~a" connections))
  (list name connections characters items x1 y1 x2 y2))

(define (room-name r)        (list-ref r 0))
(define (room-connections r) (list-ref r 1))

; SYNTAX HELPERS (phase 1, mirrors professor's pattern)
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


; macros (following professor's define-macro style)
; expands a room node into a define that calls make-room
; (room "create_room" (name "cave") (links "a" "b") ...)
; →
; (define cave (make-room "cave" '("a" "b") '() '() 0 0 10 10))
(define-macro (room NAME FEATURE ...)
  #'(begin
      (displayln "--- room macro ran ---")
      (displayln (format "  features: ~a" '(FEATURE ...)))
      (room-register! (make-room ...))))

; expands a character node — ignored for now
(define-macro (character KEYWORD FEATURE ...)
    #'(displayln "--- character macro ran (ignored for now) ---"))


; top-level: expands the whole program
; (program room-defn ... char-defn ...)
; →
; (#%module-begin (define cave ...) (define windy-hall ...) ...)
(define-macro (program DEFN ...)
  (with-pattern
    ([(ROOM-DEFN ...)  (find-definitions 'room      #'(DEFN ...))]
     [(CHAR-DEFN ...)  (find-definitions 'character #'(DEFN ...))])
    #'(#%module-begin
      (displayln "=== expander running ===")
      ; (displayln (format "rooms found: ~a" '(ROOM-DEFN ...)))
      ROOM-DEFN ...
      ; CHAR-DEFN ...
      (game-loop)
       (displayln "=== done ==="))))

;(define-macro (program DEFN ...)
 ; #'(#%module-begin
  ;   (displayln "=== expander running ===")
   ;  (displayln (format "all defns: ~a" '(DEFN ...)))
    ; (displayln "=== done ===")))

(define (read-syntax path port)
  (read-line port)
  (define parse-tree (parse path (make-tokenizer port path)))
  ; parse-tree is (program (room ...) (room ...))
  ; we need to splice its children directly into the module
  (define tree-datum (syntax->datum parse-tree))
  (define children (cdr tree-datum))  ; strip the 'program wrapper
  (strip-bindings
   #`(module game-mod "expander.rkt"
       #,@(map (lambda (c) (datum->syntax parse-tree c))
               children))))

(provide read-syntax)
(provide (rename-out [program #%module-begin]))
(provide room character make-room)