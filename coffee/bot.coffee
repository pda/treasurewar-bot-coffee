NAME = "pda"
TILE_SIZE = 16
TILES_X = 40
TILES_Y = 40
WIDTH = TILES_X * TILE_SIZE
HEIGHT = TILES_Y * TILE_SIZE
BACKGROUND = "black"
VISION = 7
COLORS = {
  unexplored: Color.black()
  explored: Color.gray(0.8)
  fog: Color.black(0.5)
  grid: Color.string(255, 255, 255, 0.1)
  wall: Color.gray(0.2)
  player: Color.string(32, 32, 255)
  enemy: Color.string(255, 0, 0)
  treasure: Color.string(255, 255, 128)
  stash: Color.string(0, 255, 0)
}

# Canvas and its drawing context.
@canvi = new Canvi(document, WIDTH, HEIGHT,
  "back",
  "fog",
  "walls",
  "main",
  "pathfinding"
  "grid"
)
canvi.build()
canvi.layers["back"].style.backgroundColor = COLORS.unexplored

@drawingBack = new DrawingTools(canvi.contexts["back"])
@drawingFog = new DrawingTools(canvi.contexts["fog"])
@drawingWalls = new DrawingTools(canvi.contexts["walls"])
@drawingMain = new DrawingTools(canvi.contexts["main"])
@drawingPathfinding = new DrawingTools(canvi.contexts["pathfinding"])
@drawingGrid = new DrawingTools(canvi.contexts["grid"])

# Background grid.
drawingGrid.grid(WIDTH, HEIGHT, TILE_SIZE, COLORS.grid)

##
# Classes

class World
  constructor: ->
    @unexplored = new PointSet(@allPoints())
    @walls = new PointSet([])
    @floors = new PointSet([])
    @player = new Player()
    @treasures = []
    @stashes = []
    @enemies = []

  allPoints: ->
    points = []
    for y in [0...TILES_Y]
      for x in [0...TILES_X]
        points.push Point.at(x, y)
    points

  setTreasureRawPoints: (rawPoints) ->
    @treasures = _(rawPoints).map (rp) ->
      _(new Treasure).tap (t) ->
        t.setRawPosition(rp)

  setYourStashRawPosition: (rawPoint) ->
    @yourStash = _(new Stash()).tap (s) ->
      s.setRawPosition(rawPoint)

  setStashRawPoints: (rawPoints) ->
    @stashes = _(rawPoints).map (rp) ->
      _(new Stash).tap (t) -> t.setRawPosition(rp)

  setEnemyRawPoints: (rawPoints) ->
    @enemies = _(rawPoints).map (rp) ->
      _(new Enemy).tap (t) -> t.setRawPosition(rp)

  addWalls: (rawPoints) ->
    @addedWalls = []
    for rp in rawPoints
      point = Point.fromRaw(rp)
      unless @walls.contains(point)
        wall = new Wall
        wall.setPosition(point)
        @addedWalls.push(wall)
      @walls.add(point)

  # Remembers floor tiles.
  # Also reduces unexplored points.
  addFloors: ->
    position = @player.position
    radius = Math.floor(VISION / 2)
    for y in [(position.y - radius)..(position.y + radius)]
      for x in [(position.x - radius)..(position.x + radius)]
        point = Point.at(x, y)
        @unexplored.remove(point)
        unless @walls.contains(point) || @floors.contains(point)
          @floors.add(point)

  acceptTickData: (data) ->

    # Player updates.
    @player.setRawPosition(data.you.position)
    @player.setHealth(data.you.health)

    # Wall updates.
    @addWalls(data.tiles.filter (t) -> t.type == "wall")
    @addFloors()

    # Your Stash
    @setYourStashRawPosition(data.you.stash)

    # Nearby entities.
    @setTreasureRawPoints(_(data.nearby_items).filter (i) -> i.is_treasure)
    @setStashRawPoints(data.nearby_stashes)
    @setEnemyRawPoints(data.nearby_players)


class WorldRenderer
  constructor: (@world) ->

  render: ->
    # Clear per-tick layers.
    for layer in ["main", "fog"]
      canvi.contexts[layer].clearRect(0, 0, WIDTH, HEIGHT)

    # Draw added walls
    for wall in @world.addedWalls
      wall.draw(drawingWalls)

    # Draw stashes
    entity.draw(drawingMain) for entity in @world.stashes

    @world.yourStash.draw(drawingMain)

    # Draw treasure
    entity.draw(drawingMain) for entity in @world.treasures

    # Draw self
    @world.player.draw(drawingMain)

    # Draw enemies
    entity.draw(drawingMain) for entity in @world.enemies

    # Draw explored area
    @drawExploredArea()

    # Draw fog of war, clear fog around player.
    @drawFog()

  drawWall: (point) ->
    p = point.fromTile(TILE_SIZE)
    drawingWalls.square(p, TILE_SIZE, COLORS.wall)

  drawExploredArea: ->
    p = @world.player.position.fromTile(TILE_SIZE)
    drawingBack.square(p, TILE_SIZE * VISION, COLORS.explored)

  drawFog: ->
    p = @world.player.position.fromTile(TILE_SIZE)
    drawingFog.c.fillStyle = COLORS.fog
    drawingFog.c.fillRect(0, 0, WIDTH, HEIGHT)
    size = VISION * TILE_SIZE
    half = size / 2
    drawingFog.c.clearRect(p.x - half, p.y - half, size, size)


class Entity
  constructor: ->
    @position = Point.Zero
    @size = TILE_SIZE
  draw: (drawingTools) ->
    position = @position.fromTile(TILE_SIZE)
    drawingTools.square(position, @size, @color())
  setPosition: (point) ->
    @position = point
  setRawPosition: (rawPoint) ->
    @setPosition(Point.fromRaw(rawPoint))

class Player extends Entity
  color: -> Color.string(128, 128, 255)
  setHealth: (health) ->
    @health = health

class Treasure extends Entity
  color: -> COLORS.treasure

class Stash extends Entity
  color: -> COLORS.stash

class Enemy extends Entity
  color: -> COLORS.enemy

class Wall extends Entity
  color: -> COLORS.wall


##
# Random shit

explore = (world) ->
  pp = world.player.position
  goals = new PointSet(world.unexplored.values())
  for t in world.treasures
    goals.add(t.position)
  window.explorer = new Explorer(
    pp,
    world.floors,
    goals
  )
  path = explorer.search()
  drawingPathfinding.c.clearRect(0, 0, WIDTH, HEIGHT)
  for point in path
    drawingPathfinding.square(point.fromTile(TILE_SIZE), TILE_SIZE, Color.string(0, 255, 0, 0.5))

  if path[0]?
    nextPoint = path[0]
    if path[0].x == pp.x
      if nextPoint.y == pp.y + 1 then dir = "s"
      else if nextPoint.y == pp.y - 1 then dir = "n"
    else if path[0].y == pp.y
      if nextPoint.x == pp.x - 1 then dir = "w"
      else if nextPoint.x == pp.x + 1 then dir = "e"

  if dir?
    socket.emit "move", dir: dir


##
# Instances

@world = new World
renderer = new WorldRenderer(world)


##
# WebSocket!

@socket = io.connect("http://treasure-war:8000")

socket.on "connect", ->
  socket.emit "set name", NAME

socket.on "tick", (data) ->

  world.acceptTickData(data)

  explore(world)

  renderer.render()


##
# Key bindings

move = (dir) -> socket.emit "move", dir: dir

document.addEventListener "keyup", (event) ->
  switch event.keyIdentifier
    when "Up" then move("n")
    when "Down" then move("s")
    when "Left" then move("w")
    when "Right" then move("e")
