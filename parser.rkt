#lang brag
program      : section*
@section     : room | characters

room         : ROOM /LBRACE room-property-pair* /RBRACE
room-property-pair: room-property /COLON value
room-property: NAME | LINKS | SIZE
size         : list

characters    : NAME | list | dialogue | quests

items          : list

dialogue       : STRING | list

quests         : list


value        : STRING | list 
number       : INT | FLOAT
;>>>>>>> cd769779b2a876b29aba209ddf161ad298f2d59f
@list        : /LBRACKET list-items /RBRACKET
@list-items  : [value] (COMMA value)*
