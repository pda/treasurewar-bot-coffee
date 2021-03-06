NAME = "pda"
TILE_SIZE = 16
TILES_X = 60
TILES_Y = 45
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

  isPlayerHome: ->
    @player.position.isEqual(@yourStash.position)

  isPlayerOnTreasure: ->
    for t in @treasures
      return true if @player.position.isEqual(t.position)
    false

  deadestEnemyNextToPlayer: ->
    neighbors = @player.position.neighborsIncludingDiagonal()
    _(@enemies).chain().
      filter((enemy) -> _(neighbors).any (point) -> point.isEqual(enemy.position)).
      sort((a, b) -> a.health - b.health).
      value()?[0]

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

  setEnemyTiles: (tiles) ->
    tiles = _(tiles).reject (t) =>
      p = Point.fromRaw(t.position)
      p.isEqual(@player.position)
    @enemies = _(tiles).map (tile) ->
      enemy = new Enemy()
      enemy.setRawPosition(tile.position)
      enemy.health = tile.health
      enemy

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
    @player.setHasTreasure(data.you.item_in_hand?.is_treasure)

    # Wall updates.
    @addWalls(_(data.tiles).filter (t) -> t.type == "wall")
    @addFloors()

    # Your Stash
    @setYourStashRawPosition(data.you.stash)

    # Nearby entities.
    @setTreasureRawPoints(_(data.tiles).filter (t) -> t.type == "treasure")
    @setStashRawPoints(_(data.tiles).filter (t) -> t.type == "stash")

    @setEnemyTiles(_(data.tiles).filter((t) -> t.type == "player"))


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

    # Draw enemies
    entity.draw(drawingMain) for entity in @world.enemies

    # Draw self
    @world.player.draw(drawingMain)

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
  setHasTreasure: (has) ->
    @hasTreasure = has

class Treasure extends Entity
  color: -> COLORS.treasure

class Stash extends Entity
  color: -> COLORS.stash

class Enemy extends Entity
  color: -> COLORS.enemy
  draw: (dt) ->
    super
    for point in @position.neighborsIncludingDiagonal()
      dt.square(point.fromTile(TILE_SIZE), TILE_SIZE, Color.string(255, 0, 0, 0.2))

class Wall extends Entity
  color: -> COLORS.wall


##
# Random shit

directionBetweenPoints = (a, b) ->
  delta = b.subtract(a)
  {
    "-1,-1": "nw"
    "0,-1": "n"
    "1,-1": "ne"
    "-1,0": "w"
    "1,0": "e"
    "-1,1": "sw"
    "0,1": "s"
    "1,1": "se"
  }[delta.toString()]

directionForPath = (world, path) ->
  return unless path[0]?
  directionBetweenPoints(world.player.position, path[0])

drawPath = (player, path) ->
  if path.length
    drawingPathfinding.c.clearRect(0, 0, WIDTH, HEIGHT)
    color = Color.string(128, 128, 255, 1)
    line = new Line(player.position.fromTile(TILE_SIZE), path[0].fromTile(TILE_SIZE))
    drawingOptions = {strokeStyle: color, lineWidth: 4}
    drawingPathfinding.line(line, drawingOptions)
    _(path).inject (memo, point) ->
      if memo
        line = new Line(memo.fromTile(TILE_SIZE), point.fromTile(TILE_SIZE))
        drawingPathfinding.line(line, drawingOptions)
      point

getTraversables = (world) ->
  traversables = new PointSet(world.floors.values())
  for enemy in world.enemies
    traversables.remove(enemy.position)
    for point in enemy.position.neighborsIncludingDiagonal()
      traversables.remove(point)
  traversables

explore = (world) ->
  pp = world.player.position

  goals = new PointSet(world.unexplored.values())
  goals.add(t.position) for t in world.treasures

  explorer = new Explorer(pp, getTraversables(world), goals)
  path = explorer.search()

  drawPath(world.player, path)

  if (dir = directionForPath(world, path))
    socket.emit "move", dir: dir
    true
  else
    false


goHome = (world) ->
  pp = world.player.position
  goals = new PointSet([world.yourStash.position])
  explorer = new Explorer(pp, getTraversables(world), goals)
  path = explorer.search()
  drawPath(world.player, path)
  if (dir = directionForPath(world, path))
    socket.emit "move", dir: dir


##
# Instances

@world = new World
renderer = new WorldRenderer(world)


##
# WebSocket!

host = window.location.hash?.replace("#", "") || "localhost:8000"
@socket = io.connect("http://#{host}")

socket.on "connect", ->
  socket.emit "set name", NAME

socket.on "tick", (data) ->
  world.acceptTickData(data)

  for message in data.messages
    if message?.notice && !message.notice.match(/^You moved/)
      console.log message.notice

  if world.player.hasTreasure
    if world.isPlayerHome()
      socket.emit("drop", {})
    else
      goHome(world)

  else if world.isPlayerOnTreasure()
    socket.emit("pick up")

  else if enemy = world.deadestEnemyNextToPlayer()
    dir = directionBetweenPoints(world.player.position, enemy.position)
    console.log("attack!: #{dir}")
    socket.emit("attack", {dir})

  else
    purposeful = explore(world)
    unless purposeful
      world.unexplored = new PointSet(world.allPoints())

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
