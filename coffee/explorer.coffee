class @Explorer

  # start: Point
  # traversables: PointSet
  # goals: PointSet
  constructor: (@start, @traversables, @goals) ->

  search: () ->
    start = @start
    open = new PointSet([start]) # To be evaluated.
    closed = new PointSet([])    # Already evaluated.
    cameFrom = {}                # Map of navigated nodes.
    gScores = {}
    gScores[start.toString()] = 0
    fScores = {}
    fScores[start.toString()] = @heuristicCostEstimate(start, gScores)

    while open.any()
      current = @sortByHeuristicCostEstimate(open.values(), gScores)[0]

      # Success
      if @goals.contains(current)
        path = @reconstructPath(cameFrom, current)
        path.shift()
        return path

      open.remove(current)
      closed.add(current)

      for neighbor in current.neighborsIncludingDiagonal()
        continue if closed.contains(neighbor)
        if @traversables.contains(neighbor) || @goals.contains(neighbor)
          tentativeGScore = gScores[current.toString()] + @manhattanDistance(current, neighbor)

          if !open.contains(neighbor) || tentativeGScore < gScores[neighbor.toString()]
            open.add(neighbor)
            cameFrom[neighbor.toString()] = current
            gScores[neighbor.toString()] = tentativeGScore
            fScores[neighbor.toString()] = tentativeGScore + @heuristicCostEstimate(neighbor, gScores)

    [] # failure

  reconstructPath: (cameFrom, currentNode) ->
    if cameFrom[currentNode.toString()]
      p = @reconstructPath(cameFrom, cameFrom[currentNode.toString()])
      p.push(currentNode)
      return p
    else
      return [currentNode]

  heuristicCostEstimate: (point, gScores) ->
    gScores[point.toString()]

  sortByHeuristicCostEstimate: (points, gScores) ->
    points.sort (a, b) =>
      @heuristicCostEstimate(a, gScores) - @heuristicCostEstimate(b, gScores)

  manhattanDistance: (a, b) ->
    Math.abs(a.x - b.x) + Math.abs(a.y - b.y)
