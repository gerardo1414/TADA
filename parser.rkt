#lang brag
program      : section*
@section     : room | character

room         : ROOM LBRACE room-property-pair* RBRACE
room-property-pair: LBRACE (room-property COLON value)* RBRACE
room-property: NAME | LINKS

character    : "N/A"

value        : STRING | list
@list        : LBRACKET list-items RBRACKET
@list-items  : [VALUE] (COMMA VALUE)*
