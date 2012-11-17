vendors = [
  "vendor/underscore"
]

classes = [
  "a_star"
  "box_collider"
  "box_entity"
  "canvi"
  "color"
  "drawing_tools"
  "line"
  "map"
  "point"
]

require vendors, ->
  require classes, ->
    require ["benchmark"]
