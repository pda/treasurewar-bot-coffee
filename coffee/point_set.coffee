class @PointSet

  constructor: (@points) ->
    @table = [0..50].map -> new Uint8Array(50)
    @add(p) for p in @points

  add: (point) ->
    @table[point.x][point.y] = 1

  remove: (point) ->
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
    @table[point.x][point.y] == 1
