#lang brag

;               PROGRAM
program    : section*
@section   : room | character


;               ROOM
room       : ROOM /LBRACE room-prop* /RBRACE

@room-prop : name | links | size | characters | items | dialogue | quest

name       : /NAME STRING
links      : /LINKS str-list
size       : /SIZE str-list
characters : /CHARACTERS str-list
items      : /ITEMS str-list
dialogue   : /DIALOGUE str-list
quest      : /QUEST str-list


;               CHARACTER
character  : CHARACTER /LBRACE char-prop* /RBRACE

@char-prop : name | char-room | dialogue | items | quest

char-room  : /ROOM-PROP STRING


;               SHARED
@str-list   : /LBRACKET [STRING (/COMMA STRING)*] /RBRACKET