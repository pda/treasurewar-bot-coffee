class @Line

  constructor: (@from, @to) ->

  toArray: -> [@from, @to]

  toString: -> @toArray().join(":")

  isHorizontal: -> @from.y == @to.y
  isVertical: -> @from.x == @to.x

  # http://cgafaq.info/wiki/Intersecting_line_segments_(2D)
  intersects: (other) ->
    a = @from
    b = @to
    c = other.from
    d = other.to
    r = ((a.y - c.y) * (d.x - c.x) - (a.x - c.x) * (d.y - c.y)) /
      ((b.x - a.x) * (d.y - c.y) - (b.y - a.y) * (d.x - c.x))
    s = ((a.y - c.y) * (b.x - a.x) - (a.x - c.x) * (b.y - a.y)) /
      ((b.x - a.x) * (d.y - c.y) - (b.y - a.y) * (d.x - c.x))
    return (0 <= r && r <= 1) && (0 <= s && s <= 1)

  # http://en.wikipedia.org/wiki/Line-line_intersection
  # Line intersection, not segment; result may be beyond either segment.
  intersection: (other) ->
    x1 = @from.x
    x2 = @to.x
    x3 = other.from.x
    x4 = other.to.x
    y1 = @from.y
    y2 = @to.y
    y3 = other.from.y
    y4 = other.to.y
    x = ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) /
      ((x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4))
    y = ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) /
      ((x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4))
    Point.at(x, y)

  nearestIntersectingLine: (others) ->
    _.chain(others)
      .filter((other) => @intersects(other))
      .sortBy((other) => @intersection(other).subtract(@from).length())
      .first()
      .value()

  nearestIntersection: (others) ->
    _.chain(others)
      .filter((other) => @intersects(other))
      .map((other) => @intersection(other))
      .sortBy((point) => point.subtract(@from).length())
      .first()
      .value()

  length: ->
    @to.subtract(@from).length()

  # Single-direction continuation test.
  # Other lines "from" must start at this lines "to" position.
  isContinuation: (other) ->
    @to.isEqual(other.from) && (
      (@isHorizontal() && other.isHorizontal()) ||
      (@isVertical() && other.isVertical())
    )

  merge: (other) ->
    new Line(@from, other.to)
