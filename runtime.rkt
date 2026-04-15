#lang racket
;; runtime.rkt
;; Plain Racket functions — NO macros here.
;; These are called by the expander after it transforms (command ...) forms.
;;
;; Right now: stubs that just print.
;; Later: these will call into game-state functions (inventory, rooms, etc.)

(define (do-move [direction #f])
  (if direction
      (printf "You move ~a.\n" direction)
      (printf "Move where?\n")))

(define (do-take noun)
  (printf "You take the ~a.\n" noun))

(define (do-drop noun)
  ;; TODO: connect to inventory-remove! in final_project.rkt
  (printf "You drop the ~a.\n" noun))

(define (do-examine noun)
  (printf "You examine the ~a.\n" noun))

(define (do-talk [noun #f])
  (if noun
      (printf "You talk to the ~a.\n" noun)
      (printf "Talk to whom?\n")))

(define (do-enter noun)
  (printf "You enter the ~a.\n" noun))

(define (do-exit [noun #f])
  (if noun
      (printf "You exit the ~a.\n" noun)
      (printf "You exit.\n")))

(define (do-put noun1 prep noun2)
  (printf "You put the ~a ~a the ~a.\n" noun1 prep noun2))

(define (do-pickup noun)
  (printf "You pick up the ~a.\n" noun))

(define (do-inventory)
  ;; TODO: connect to inventory-show in final_project.rkt
  (printf "You check your inventory.\n"))

(define (do-unknown verb)
  (printf "I don't know how to '~a'.\n" verb))

(provide do-move do-take do-drop do-examine do-talk
         do-enter do-exit do-put do-pickup do-inventory do-unknown)