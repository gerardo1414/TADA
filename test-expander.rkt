#lang racket

(require "expander.rkt")

;; Test runtime functions directly
(do-take "key")
(do-move "north")
(do-put "key" "on" "table")
(do-unknown "fly")

;; Test the command macro with manual parse tree shapes
(command (verb-phrase "take") (noun-phrase "key"))
(command (verb-phrase "take") (noun-phrase "the" "key"))
(command (verb-phrase "move"))
(command (verb-phrase "put") (noun-phrase "key") (prep "on") (noun-phrase "table"))