class @Explorer

  # start: Point
  # traversables: PointSet
  # unexplored: PointSet
  constructor: (@start, @traversables, @unexplored) ->

  search: ->
    open = new PointSet([@start]) # To be evaluated.
    closed = new PointSet([])    # Already evaluated.
    cameFrom = {}                 # Map of navigated nodes.
    obstacles = new PointSet(obstacles)

    while open.count()
      current = open.values()[0]

      # Success
      if @unexplored.contains(current)
        path = @reconstructPath(cameFrom, current)
        path.shift()
        return path

      open.remove(current)
      closed.add(current)

      for neighbor in @neighbors(current)
        continue if closed.contains(neighbor)
        if @traversables.contains(neighbor) || @unexplored.contains(neighbor)
          open.add(neighbor)
          cameFrom[neighbor.toString()] = current

    [] # failure

  reconstructPath: (cameFrom, currentNode) ->
    if cameFrom[currentNode.toString()]
      p = @reconstructPath(cameFrom, cameFrom[currentNode.toString()])
      p.push(currentNode)
      return p
    else
      return [currentNode]

  neighbors: (point) ->
    x = point.x
    y = point.y
    [
      [x, y - 1]
      [x - 1, y]
      [x + 1, y]
      [x, y + 1]
    ].map (p) -> new Point(p[0], p[1])
