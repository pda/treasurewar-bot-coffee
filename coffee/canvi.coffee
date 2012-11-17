class @Canvi

  constructor: (@document, @width, @height, @names...) ->
    @layers = {}
    @contexts = {}

  build: ->
    _(@names).each (name) =>
      canvas = @buildCanvas(@width, @height, @nameForId(name))
      @layers[name] = canvas
      @contexts[name] = canvas.getContext("2d")
      @document.body.appendChild(canvas)

  nameForId: (name) ->
    "canvas_#{name}"

  # Build a canvas element.
  buildCanvas: (width, height, id) ->
    _.tap @document.createElement("canvas"), (c) ->
      c.width = width
      c.height = height
      c.id = id
      c.style.position = "absolute"
