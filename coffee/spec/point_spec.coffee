describe "Point", ->

  p = (x, y) -> Point.at(x, y)

  it "holds x and y coordinates", ->
    point = new Point(10, 20)
    expect(point.x).toBe(10)
    expect(point.y).toBe(20)

  describe ".at(x, y)", ->
    it "constructs a Point", ->
      expect(Point.at(2, 4)).toEqual(new Point(2, 4))

  describe ".Zero", ->
    it "is a zero Point", ->
      expect(Point.Zero).toEqual(new Point(0, 0))

  describe "isZero()", ->
    it "is true for 0,0", ->
      expect(Point.Zero.isZero()).toBe(true)
    it "is false for 2,2", ->
      expect(Point.at(2, 2).isZero()).toBe(false)

  describe "toTile(tileSize)", ->
    it "converts 10,20 to 2,5 for tileSize = 4", ->
      expect(Point.at(10, 20).toTile(4)).toEqual(Point.at(2, 5))

  describe "fromTile(tileSize)", ->
    it "converts 0,0 to 8,8 for tileSize = 16", ->
      expect(Point.at(0, 0).fromTile(16)).toEqual(Point.at(8, 8))
    it "converts 2,5 to 10,22 for tileSize = 4", ->
      expect(Point.at(2, 5).fromTile(4)).toEqual(Point.at(10, 22))

  describe "toString()", ->
    it "represents points as '2,4'", ->
      expect(Point.at(2, 4).toString()).toEqual("2,4")

  describe "add()", ->
    it "(0,1) + (3,-2) = (3,-1)", ->
      expect(p(0,1).add(p(3,-2))).toEqual(p(3,-1))

  describe "isEqual(other)", ->
    it "is true for same coordinates", ->
      expect(p(8, 8).isEqual(p(8, 8))).toBe(true)
    it "is false for different coordinates", ->
      expect(p(8, 8).isEqual(p(8, 0))).toBe(false)


  describe "subtract()", ->
    it "(4,3) - (1,2) = (3,1)", ->
      expect(p(4,3).subtract(p(1,2))).toEqual(p(3,1))

  describe "multiply()", ->
    it "(2,4) * 4 = (8,16)", ->
      expect(p(2,4).multiply(4)).toEqual(p(8,16))

  describe "divide()", ->
    it "(9,6) / 3 = (3,2)", ->
      expect(p(9,6).divide(3)).toEqual(p(3,2))

  describe "length()", ->
    it "is 5 for (4,3)", ->
      expect(p(4,3).length()).toEqual(5)

  describe "normalized()", ->
    it "is (3/5,4/5) for (3,4)", ->
      expect(p(3,4).normalized()).toEqual(p(3/5, 4/5))
    it "is (0,0) for (0,0) (divide-by-zero, technically undefined)", ->
      expect(p(0,0).normalized()).toEqual(p(0, 0))
