class @Map

  constructor: (@width, @height, @tileSize, @player, @walls, @monsters, @loot) ->
    @edges = @findEdges()

  @fromAscii: (tileSize, rows) ->
    width = tileSize * rows[0].length
    height = tileSize * rows.length
    walls = []
    monsters = []
    loot = []
    player = null
    _(rows).each (row, y) ->
      _(row.split("")).each (char, x) ->
        if char == "#" then walls.push(Point.at(x, y))
        if char == "!" then monsters.push(Point.at(x, y))
        if char == "$" then loot.push(Point.at(x, y))
        if char == "@" then player = Point.at(x, y)
    new Map(width, height, tileSize, player, walls, monsters, loot)

  # TODO: refactor this behemoth!
  findEdges: ->
    halfTile = @tileSize / 2
    widthTiles = @width / @tileSize
    heightTiles = @height / @tileSize

    # Lookup table of wall positions in tile-space.
    wallKeys = {}
    _(@walls).each (point) ->
      wallKeys[point.toString()] = true

    # The faces of all wall tiles that are facing non-wall map space.
    wallFaces = []
    _(@walls).each (tilePoint) =>
      screenPoint = tilePoint.fromTile(@tileSize)
      unless wallKeys[tilePoint.add(Point.at(0, -1)).toString()] || tilePoint.y == 0 # above
        wallFaces.push(new Line(
          Point.at(screenPoint.x - halfTile, screenPoint.y - halfTile)
          Point.at(screenPoint.x + halfTile, screenPoint.y - halfTile)
        ))
      unless wallKeys[tilePoint.add(Point.at(1, 0)).toString()] || tilePoint.x == widthTiles - 1 # right
        wallFaces.push(new Line(
          Point.at(screenPoint.x + halfTile, screenPoint.y - halfTile)
          Point.at(screenPoint.x + halfTile, screenPoint.y + halfTile)
        ))
      unless wallKeys[tilePoint.add(Point.at(0, 1)).toString()] || tilePoint.y == heightTiles - 1 # below
        wallFaces.push(new Line(
          Point.at(screenPoint.x - halfTile, screenPoint.y + halfTile)
          Point.at(screenPoint.x + halfTile, screenPoint.y + halfTile)
        ))
      unless wallKeys[tilePoint.add(Point.at(-1, 0)).toString()] || tilePoint.x == 0 # left
        wallFaces.push(new Line(
          Point.at(screenPoint.x - halfTile, screenPoint.y - halfTile)
          Point.at(screenPoint.x - halfTile, screenPoint.y + halfTile)
        ))

    # Condensed geometry describing continuous wall edges.
    edges = []
    wallFacesDiscarded = {}
    _(wallFaces).each (line) ->
      if wallFacesDiscarded[line.toString()] then return
      _(wallFaces).each (otherLine) ->
        if line.isContinuation(otherLine)
          wallFacesDiscarded[otherLine.toString()] = true
          line = line.merge(otherLine)
      edges.push(line)

    @edges = edges

  draw: (context) ->
    _(new DrawingTools(context)).tap (d) =>
      d.grid(@width, @height, @tileSize, Color.gray(0.95))
      _(@walls).each (point) =>
        d.square(point.fromTile(@tileSize), @tileSize, Color.gray(0.8))

      _(@edges).each (line) ->
        d.line(line, strokeStyle: Color.gray(0.6), lineWidth: 4)
        _(line.toArray()).each (p) -> d.square(p, 6, Color.gray(0.6))
