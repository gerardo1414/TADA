#lang racket
(require "TADA_Racket.rkt")

; courtesy of claude
; TEST / MAIN

; items
(define beer
  (make-item "Beer"
             "A frothy mug of ale. Smells strong."
             5
             '(take drop inspect drink)))

(define bread
  (make-item "Bread"
             "A stale loaf of bread sitting on the counter."
             1
             '(take drop inspect eat)))

(define knife
  (make-item "Kitchen Knife"
             "A very sharp knife used for cooking. Probably shouldn't take this."
             10
             '(inspect)))

(define mop
  (make-item "Mop"
             "A dirty mop leaning against the bathroom wall."
             1
             '(inspect)))

(define trinket
  (make-item "Peculiar Trinket"
             "A strange little object. You're not sure where it came from, but it catches the light oddly."
             0
             '(take drop inspect)))

; rooms
(define bar
  (make-room "The Bar"
             (list (make-connection "Bathroom" 10 5)
                   (make-connection "Kitchen"   5 10))
             '()
             (list beer bread trinket)
             0 0 10 10))

(define bathroom
  (make-room "Bathroom"
             (list (make-connection "The Bar" 11 5))
             '()
             (list mop)
             11 0 15 10))

(define kitchen
  (make-room "Kitchen"
             (list (make-connection "The Bar" 5 11))
             '()
             (list knife)
             0 11 10 15))

(room-register! bar)
(room-register! bathroom)
(room-register! kitchen)

(define bartender
  (make-npc "Bartender"
            (make-dialogue-node
             '("Hey there. What can I get ya?")
             (list
              (make-option "I'll have a beer."
                           '("Coming right up. That'll be 5 gold.")

                           (list
                            (make-option "Here you go."
                                         (lambda ()
                                           (if (>= player-gold 5)
                                               (begin
                                                 (gold-spend! 5)
                                                 (inventory-add! beer)
                                                 '("Cheers! Enjoy your drink."))
                                               '("You're a bit short. Come back when you have the gold.")))
                                         '())
                            (make-option "Actually nevermind."
                                         '("Suit yourself.")
                                         '())))
              (make-option "What's good here?"
                           '("The ale is fresh. Kitchen's got bread too if you're hungry.")
                           (list
                            (make-option "I'll keep that in mind, thanks."
                                         '("No worries. Holler if you need anything.")
                                         '())))
              (make-option "Where does that door go?"
                           '("Bathroom's to the east. Kitchen's to the north. Don't go snooping around back there.")
                           (list
                            (make-option "Wasn't planning to."
                                         '("Good. Drink up.")
                                         '())
                            (make-option "What if I do?"
                                         '("Then we're gonna have a problem, friend.")
                                         '())))
              (make-option "You look like you need something."
                           (lambda ()
                             (let ((q (findf (lambda (q)
                                               (and (string-ci=? (quest-giver q) "Bartender")
                                                    (not (quest-assigned? q))))
                                             quests)))
                               (if q
                                   (begin
                                     (quest-assign! (quest-desc q))
                                     '("Actually yeah... I lost a peculiar little trinket somewhere in here."
                                       "Odd little thing, catches the light strangely."
                                       "Find it and bring it back to me. I'll make it worth your while."))
                                   '("Nah I'm good. Drink up."))))
                           '())
              (make-option "Goodbye."
                           '("Take care now.")
                           '())))
            '()
            '()))

(npc-register! bartender)

; register the trinket quest (not yet assigned — bartender gives it during dialogue)
(quest-register!
 (make-quest "Find the Bartender's Trinket"
             '("Peculiar Trinket")
             (list (make-item "Coin Pouch"
                              "A small pouch of coins tied with twine."
                              15
                              '(take drop inspect)))
             "Bartender"))

; friend npc
(define friend
  (make-npc "Friend"
            (make-dialogue-node
             '("Hey! Good to see you. Quite the place, huh?")
             (list
              (make-option "Yeah! Hey, can I borrow some gold?"
                           (lambda ()
                             (if (>= player-gold 5)
                                 '("You already look like you're doing fine!")
                                 (begin
                                   (gold-add! 5)
                                   '("Sure, I've got you covered. Here's 5 gold. Pay me back later!"))))
                           '())
              (make-option "What are you drinking?"
                           '("Just some water, I'm trying to save money.")
                           (list
                            (make-option "Smart."
                                         '("Unlike some people I know...")
                                         '())
                            (make-option "Boring!"
                                         '("Hey, not all of us are here to party.")
                                         '())))
              (make-option "Goodbye."
                           '("See you around!")
                           '())))
            '()
            '()))

(npc-register! friend)

; main - make sure to use provide when saul is ready with the expander
(define (main)
  (set-current-room! bar)
  (set-floor-items!  (room-items bar))
  (displayln "===========================================")
  (displayln "   Welcome to The Rusty Flagon            ")
  (displayln "===========================================")
  (displayln "You step into a dimly lit bar.")
  (displayln "The smell of ale and sawdust fills the air.")
  (displayln "A bartender wipes down the counter.")
  (displayln "Your friend waves at you from a nearby stool.")
  (displayln "Something glimmers by your foot.")
  (displayln "")
  (displayln "Commands: move [forward/backward/left/right]")
  (displayln "          look")
  (displayln "          talk [name]")
  (displayln "          take [item]")
  (displayln "          drop [item]")
  (displayln "          inspect [item]")
  (displayln "          inventory")
  (displayln "          wander")
  (displayln "          quit")
  (displayln "===========================================")
  (displayln "")
  (game-loop))

(main)