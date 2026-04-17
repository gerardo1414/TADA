#lang reader "parse-only.rkt"
<<<<<<< HEAD
 create_room {
     name: "cave"
     links:["tunnel", "dungeon"]
   }
=======

create_room {
    name:       "cave"
    links:      ["windy hall", "forest entrance"]
    size:       ["6 6 8 8"]
    characters: ["old hermit", "bat swarm"]
    dialogue:   ["Who goes there?", "Leave me be."]
    items:      ["torch", "rope"]
    quest:      ["find the lost sword"]
}

create_room {
    name:       "windy hall"
    links:      ["cave", "dungeon"]
    size:       ["4 4 5 5"]
    characters: ["ghost"]
    dialogue:   ["ooooooo"]
    items:      ["lantern"]
    quest:      ["escape the dungeon"]
}
>>>>>>> 31e257112adb016a358c7437c2ede63f82abbf24
