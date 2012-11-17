NAME = "pda"
TILE_SIZE = 8
WIDTH = 800
HEIGHT = 800
BACKGROUND = "black"
VISION = 5
COLORS = {
  background: Color.gray(0.1)
  explored: Color.black()
  grid: Color.string(255, 255, 255, 0.1)
  wall: Color.gray(0.2)
  player: Color.string(32, 32, 255)
}

# Canvas and its drawing context.
@canvi = new Canvi(document, WIDTH, HEIGHT, "back", "main", "grid")
canvi.build()
canvi.layers["back"].style.backgroundColor = COLORS.background

@drawingMain = new DrawingTools(canvi.contexts["main"])
@drawingGrid = new DrawingTools(canvi.contexts["grid"])
@drawingBack = new DrawingTools(canvi.contexts["back"])

# Background grid.
drawingGrid.grid(WIDTH, HEIGHT, TILE_SIZE, COLORS.grid)

##
# Classes

class Player
  constructor: ->
    @position = Point.Zero
    @size = TILE_SIZE
  color: ->
    Color.string(128, 128, 255)
  draw: (drawingTools) ->
    position = @position.fromTile(TILE_SIZE)
    drawingTools.square(position, @size, @color())
  setPosition: (rawPosition) ->
    position = Point.fromRaw(rawPosition)
    unless @position.isEqual(position)
      console.log("Position: #{@position.toString()} -> #{position.toString()}")
    @position = position
  setHealth: (health) ->
    if health != @health
      console.log("Health: #{@health} -> #{health}")
    @health = health

class PointSet
  constructor: (@points) ->
  add: (point) ->
    @points.push(point) unless @contains(point)
  remove: (point) ->
    for p, i in @points
      if p.isEqual(point)
        @points.splice(i, 1)
        return
  values: ->
    @points
  count: ->
    @points.length
  contains: (point) ->
    for p in @points
      return true if p.isEqual(point)
    return false

##
# Random shit.

drawWall = (point) ->
  p = point.fromTile(TILE_SIZE)
  drawingBack.square(p, TILE_SIZE, COLORS.wall)

clearFog = (point) ->
  p = point.fromTile(TILE_SIZE)
  drawingBack.square(p, TILE_SIZE * VISION, COLORS.explored)


##
# Instances

@player = new Player
@walls = new PointSet([])

##
# WebSocket!

@socket = io.connect("http://localhost:3001")

socket.on "connect", ->
  console.log "Setting name to #{NAME}"
  socket.emit "set name", NAME

socket.on "tick", (data) ->
  #console.log "you: %o", data.you
  #console.log "tiles: %o", data.tiles

  # Player position
  player.setPosition(data.you.position)
  clearFog(player.position)

  # Player health
  player.setHealth(data.you.health)

  # Walls
  _(data.tiles).each (item) ->
    if item.type == "wall"
      point = Point.at(item.x, item.y)
      drawWall(point)
      walls.add(point)

  canvi.contexts["main"].clearRect(0, 0, WIDTH, HEIGHT)
  player.draw(drawingMain)
