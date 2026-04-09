#lang br/quicklang

;; expander.rkt
;; Transforms parse tree nodes (from the command grammar) into runnable Racket.
;;
;; Pipeline reminder:
;;   reader.rkt       → tokenizes player input
;;   command-grammar  → parses tokens into a parse tree
;;   THIS FILE        → macros transform parse tree into Racket function calls
;;   runtime.rkt      → plain Racket functions that execute those calls

(require "runtime.rkt")

;; ── #%module-begin ──────────────────────────────────────────────────────────
;; Required by br/quicklang. Wraps all top-level forms in the .tada file.
;; We intercept it here so we could add setup/teardown later (game intro, etc.)

(define-syntax (tada-module-begin stx)
  (syntax-case stx ()
    [(_ body ...)
     #'(#%module-begin body ...)]))

(provide (rename-out [tada-module-begin #%module-begin]))


;; ── noun-phrase ─────────────────────────────────────────────────────────────
;; Strips articles and adjectives — we only care about the noun itself.
;; The grammar can produce:
;;   (noun-phrase "key")
;;   (noun-phrase "the" "key")
;;   (noun-phrase "a" "big" "door")

(define-macro-cases noun-phrase
  [(_ noun)             #'noun]
  [(_ article noun)     #'noun]
  [(_ article adj noun) #'noun])


;; ── verb-phrase ─────────────────────────────────────────────────────────────
;; Just extracts the verb string. Simple passthrough.

(define-macro-cases verb-phrase
  [(_ verb) #'verb])


;; ── prep ────────────────────────────────────────────────────────────────────
;; Just extracts the preposition string.

(define-macro-cases prep
  [(_ p) #'p])


;; ── command ─────────────────────────────────────────────────────────────────
;; This is the core macro. It pattern-matches on the shape of the parse tree
;; and dispatches to the right runtime function.
;;
;; THIS is where syntax transformation happens:
;;   (command (verb-phrase "take") (noun-phrase "the" "key"))
;;   becomes →  (do-take "key")
;;
;; The macro runs at COMPILE TIME (expansion time), not at runtime.
;; By the time the program runs, all (command ...) forms are gone —
;; they've been replaced by plain Racket function calls.

(define-macro-cases command

  ;; Shape 1: bare verb only — "move", "exit", "inventory"
  [(_ (verb-phrase v))
   #'(cond
       [(equal? v "move")      (do-move)]
       [(equal? v "exit")      (do-exit)]
       [(equal? v "talk")      (do-talk)]
       [(equal? v "inventory") (do-inventory)]   ; TODO: wire up later
       [else                   (do-unknown v)])]

  ;; Shape 2: verb + bare noun — "take key"
  [(_ (verb-phrase v) (noun-phrase n))
   #'(cond
       [(equal? v "take")    (do-take n)]
       [(equal? v "pickup")  (do-pickup n)]
       [(equal? v "drop")    (do-drop n)]        ; TODO: stub in runtime
       [(equal? v "examine") (do-examine n)]
       [(equal? v "talk")    (do-talk n)]
       [(equal? v "enter")   (do-enter n)]
       [(equal? v "exit")    (do-exit n)]
       [(equal? v "move")    (do-move n)]
       [else                 (do-unknown v)])]

  ;; Shape 2b: verb + article + noun — "take the key"
  [(_ (verb-phrase v) (noun-phrase art n))
   #'(cond
       [(equal? v "take")    (do-take n)]
       [(equal? v "pickup")  (do-pickup n)]
       [(equal? v "drop")    (do-drop n)]
       [(equal? v "examine") (do-examine n)]
       [(equal? v "talk")    (do-talk n)]
       [(equal? v "enter")   (do-enter n)]
       [(equal? v "exit")    (do-exit n)]
       [(equal? v "move")    (do-move n)]
       [else                 (do-unknown v)])]

  ;; Shape 3: verb + noun + prep + noun — "put key on table"
  [(_ (verb-phrase v) (noun-phrase n1) (prep p) (noun-phrase n2))
   #'(cond
       [(equal? v "put") (do-put n1 p n2)]
       [else             (do-unknown v)])]

  ;; Shape 3b: verb + article+noun + prep + article+noun
  [(_ (verb-phrase v) (noun-phrase a1 n1) (prep p) (noun-phrase a2 n2))
   #'(cond
       [(equal? v "put") (do-put n1 p n2)]
       [else             (do-unknown v)])])


(provide verb-phrase
         noun-phrase
         prep
         command
         (all-from-out "runtime.rkt"))