describe "Map", ->

  p = (x, y) -> Point.at(x, y)
  l = (a, b, c, d) -> new Line(p(a, b), p(c, d))

  map = Map.fromAscii(32, [
    "### $"
    "%@!$#"
    "! ###"
  ])

  list = (points) ->
    _(points).map((p) -> p.toString()).join(" ")

  describe ".fromAscii()", ->
    it "parses @ as player", ->
      expect(map.player).toEqual(Point.at(1, 1))
    it "parses # as walls", ->
      expect(list(map.walls)).toEqual("0,0 1,0 2,0 4,1 2,2 3,2 4,2")
    it "parses ! as monsers", ->
      expect(list(map.monsters)).toEqual("2,1 0,2")
    it "parses $ as loot", ->
      expect(list(map.loot)).toEqual("4,0 3,1")

  describe "draw()", ->
    it "should be tested"

  describe "edges", ->
    it "should be four internal lines", ->
      map = Map.fromAscii(32, [
        "#####"
        "#   #"
        "#   #"
        "#####"
      ])
      expect(map.edges.length).toEqual(4)
      expect(map.edges).toEqual([
        l(32,32,128,32)
        l(32,32,32,96)
        l(128,32,128,96)
        l(32,96,128,96)
      ])
