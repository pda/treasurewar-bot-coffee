class @BoxCollider

  constructor: (@boxEntity) ->

  withLines: (lines, timeDelta) ->
    entity = @boxEntity
    _(entity.corners).each (corner) ->
      movement = new Line(corner, corner.add(entity.velocity.multiply(timeDelta)))
      if (line = movement.nearestIntersectingLine(lines))
        if line.isHorizontal()
          entity.velocity.y = 0
        else if line.isVertical()
          entity.velocity.x = 0
