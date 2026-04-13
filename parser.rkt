#lang brag
program      : section*
@section     : room | character

room         : ROOM /LBRACE room-property-pair* /RBRACE
room-property-pair: room-property /COLON value
room-property: NAME | LINKS

character    : "N/A"

value        : STRING | list
@list        : /LBRACKET list-items /RBRACKET
@list-items  : [value] (COMMA value)*
