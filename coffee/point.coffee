# A point in two dimentional space.
class @Point

  constructor: (@x, @y) ->

  @at: (x, y) ->
    new Point(x, y)

  @fromRaw: (raw) ->
    new Point(raw.x, raw.y)

  @Zero: new Point(0, 0)

  isZero: ->
    @x == 0 && @y == 0

  toString: ->
    "#{@x},#{@y}"

  toTile: (size) ->
    Point.at(Math.floor(@x / size), Math.floor(@y / size))

  fromTile: (size) ->
    half = size / 2
    Point.at(@x * size + half, @y * size + half)

  isEqual: (other) ->
    other.x == @x && other.y == @y

  add: (other) ->
    Point.at(@x + other.x, @y + other.y)

  subtract: (other) ->
    Point.at(@x - other.x, @y - other.y)

  multiply: (scalar) ->
    Point.at(@x * scalar, @y * scalar)

  divide: (scalar) ->
    Point.at(@x / scalar, @y / scalar)

  length: ->
    Math.sqrt(@x * @x + @y * @y)

  normalized: ->
    l = @length()
    if l > 0 then Point.at(@x / l, @y / l) else this

  # Neighbors, not including diagonals.
  neighbors: ->
    [
      [@x, @y - 1]
      [@x - 1, @y]
      [@x + 1, @y]
      [@x, @y + 1]
    ].map (p) -> new Point(p[0], p[1])

  neighborsIncludingDiagonal: ->
    [
      [@x - 1, @y - 1], [@x, @y - 1], [@x + 1, @y - 1],
      [@x - 1, @y], [@x + 1, @y],
      [@x - 1, @y + 1], [@x, @y + 1], [@x + 1, @y + 1],
    ].map (p) -> new Point(p[0], p[1])
