#lang TADA/parse-only

room {
  name "The Bar"
  size 0 0 10 10
  links {
    "Bathroom" : 10 5
    "Kitchen" : 5 10
  }
  characters ["Bartender"]
  items ["Beer"]
}