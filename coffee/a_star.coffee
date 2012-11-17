class @AStar

  search: (start, goal, obstacles, costLimit) ->
    open = new @PointSet([start]) # To be evaluated.
    closed = new @PointSet([])    # Already evaluated.
    cameFrom = {}                 # Map of navigated nodes.
    obstacles = new @PointSet(obstacles)
    gScores = {}
    gScores[start.toString()] = 0
    fScores = {}
    fScores[start.toString()] = @heuristicCostEstimate(start, goal, gScores)

    cost = 0
    while open.count()
      current = @sortByHeuristicCostEstimate(open.values(), goal, gScores)[0]

      if current.isEqual(goal)
        return @reconstructPath(cameFrom, goal)

      open.remove(current)
      closed.add(current)

      for neighbor in @neighbors(current)
        cost++
        if closed.contains(neighbor) then continue
        if obstacles && obstacles.contains(neighbor) then continue
        tentativeGScore = gScores[current.toString()] + @manhattanDistance(current, neighbor)

        if !open.contains(neighbor) || tentativeGScore < gScores[neighbor.toString()]
          open.add(neighbor)
          cameFrom[neighbor.toString()] = current
          gScores[neighbor.toString()] = tentativeGScore
          fScores[neighbor.toString()] = tentativeGScore + @heuristicCostEstimate(neighbor, goal, gScores)

      if cost >= costLimit
        return []

    [] # failure

  reconstructPath: (cameFrom, currentNode) ->
    if cameFrom[currentNode.toString()]
      p = @reconstructPath(cameFrom, cameFrom[currentNode.toString()])
      p.push(currentNode)
      return p
    else
      return [currentNode]

  # f(x): g(x) + h(x)
  # g(x): cost from the starting node to the current node
  # h(x): estimated distance to goal
  heuristicCostEstimate: (point, destination, gScores) ->
    @manhattanDistance(point, destination) + gScores[point.toString()]

  sortByHeuristicCostEstimate: (points, destination, gScores) ->
    points.sort (a, b) =>
      @heuristicCostEstimate(a, destination, gScores) -
        @heuristicCostEstimate(b, destination, gScores)

  manhattanDistance: (a, b) ->
    Math.abs(a.x - b.x) + Math.abs(a.y - b.y)

  neighbors: (point) ->
    x = point.x
    y = point.y
    [
      [x, y - 1]
      [x - 1, y]
      [x + 1, y]
      [x, y + 1]
    ].map (p) -> new Point(p[0], p[1])

  neighborsIncludingDiagonal: (point) ->
    x = point.x
    y = point.y
    [
      [x - 1, y - 1], [x, y - 1], [x + 1, y - 1],
      [x - 1, y], [x + 1, y],
      [x - 1, y + 1], [x, y + 1], [x + 1, y + 1],
    ].map (p) -> new Point(p[0], p[1])

  PointSet: class
    constructor: (@points) ->
    add: (point) ->
      @points.push(point)
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
