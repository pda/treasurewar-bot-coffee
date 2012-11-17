class @BoxEntity

  constructor: (position = Point.Zero) ->
    @collider = new BoxCollider(this)
    @setVelocity(Point.Zero)
    @setSize(@size || 0)
    @setPosition(position)

  # Move towards other point, return new distance remaining.
  # Returns true if the destination is reached, else false.
  moveTowards: (point, speed, timeDelta) ->
    positionDelta = point.subtract(@position)
    direction = positionDelta.normalized()
    distance = positionDelta.length()
    cappedSpeed = Math.min(speed, distance / timeDelta)
    @setVelocity(direction.multiply(cappedSpeed))
    return cappedSpeed == 0

  # Update position, recalculating related coordinates.
  setPosition: (p...) ->
    @position = @_pointFromParameters(p)
    @top = @position.subtract(@sizeDelta).y
    @bottom = @position.add(@sizeDelta).y
    @left = @position.subtract(@sizeDelta).x
    @right = @position.add(@sizeDelta).x
    @corners = [
      Point.at(@left, @top),
      Point.at(@right, @top),
      Point.at(@left, @bottom),
      Point.at(@right, @bottom)
    ]
    @

  # Sets the square size, takes a scalar.
  setSize: (size) ->
    halfSize = size / 2
    @size = size
    @sizeDelta = Point.at(halfSize, halfSize)
    @

  # Sets velocity, takes x, y or a Point.
  setVelocity: (p...) ->
    @velocity = @_pointFromParameters(p)
    @

  # Set velocity to zero.
  stop: ->
    @setVelocity(Point.Zero) unless @velocity.isZero()

  # Draw the entity using DrawingTools
  draw: (drawingTools) ->
    drawingTools.square(@position, @size, @color())

  # Update position based on velocity and timeDelta.
  update: (timeDelta) ->
    @setPosition(@position.add(@velocity.multiply(timeDelta)))

  _pointFromParameters: (p) ->
    if p.length == 2 then Point.at(p...) else p[0]
