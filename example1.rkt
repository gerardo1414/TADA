#lang reader "tokenize-only.rkt"
 create_room {
     name: "cave"
     links: ["tunnel"]
   }

create_room {
     name: "tunnel"
     links: ["cave"]
   }