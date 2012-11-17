TILE_SIZE = 32

WIDTH = 1024
HEIGHT = 768

##
# Bootstrap
(->
  @canvi = new Canvi(document, WIDTH, HEIGHT, "back", "main")
  canvi.build()

  canvi.layers["back"].style.backgroundColor = "black"

  drawingTools = new DrawingTools(canvi.contexts["main"])

  drawingTools.line(
    new Line(Point.at(100, 100), Point.at(200, 200))
    strokeStyle: "lightGreen"
    lineWidth: 4
  )

)()
