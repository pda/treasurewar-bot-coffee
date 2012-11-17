class @DrawingTools

  constructor: (context) ->
    @c = context

  line: (line, options = {}) ->
    @c.strokeStyle = options.strokeStyle if options.strokeStyle
    @c.lineWidth = options.lineWidth if options.lineWidth
    @c.beginPath()
    @c.moveTo(line.from.x, line.from.y)
    @c.lineTo(line.to.x, line.to.y)
    @c.stroke()

  grid: (width, height, size, style) ->
    @c.lineWidth = 1
    @c.strokeStyle = style
    _(width / size + 1).times (i) =>
      @line(new Line(Point.at(i * size, 0), Point.at(i * size, height)))
    _(height / size + 1).times (i) =>
      @line(new Line(Point.at(0, i * size), Point.at(width, i * size)))

  square: (point, size, style) ->
    if style then @c.fillStyle = style
    half = size / 2
    @c.fillRect(point.x - half, point.y - half, size, size)
