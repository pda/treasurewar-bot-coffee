class @PointSet

  SIZE = 60

  constructor: (@points) ->
    @table = [0..SIZE].map -> new Uint8Array(SIZE)
    @add(p) for p in @points

  add: (point) ->
    return unless @inBounds(point)
    @table[point.x][point.y] = 1

  remove: (point) ->
    return unless @inBounds(point)
    @table[point.x][point.y] = 0

  values: ->
    points = []
    for column, x in @table
      for value, y in column
        points.push new Point(x, y) if value == 1
    points

  any: ->
    for column in @table
      for value in column
        return true if value == 1
    false

  count: ->
    console.log "PointSet#count not optimized"
    @values().length

  contains: (point) ->
    return false unless @inBounds(point)
    @table[point.x][point.y] == 1

  inBounds: (point) ->
    [x, y] = [point.x, point.y]
    0 <= x < SIZE && 0 <= y < SIZE
