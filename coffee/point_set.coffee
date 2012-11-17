class @PointSet

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
