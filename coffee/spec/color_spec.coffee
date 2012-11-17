describe "Color", ->

  color = null
  beforeEach -> color = new Color(1, 2, 3, 0.4)

  it "holds reference to r, b, g, a", ->
    expect(color.r).toBe(1)
    expect(color.g).toBe(2)
    expect(color.b).toBe(3)
    expect(color.a).toBe(0.4)

  it "defaults alpha to 1", ->
    expect(new Color(1, 2, 3).a).toBe(1)

  describe "toString()", ->
    it "represents the color as an rgba string", ->
      expect(color.toString()).toEqual("rgba(1, 2, 3, 0.4)")

  describe ".string()", ->
    it "builds an rgba string", ->
      expect(Color.string(2, 4, 6, 0.8)).toEqual("rgba(2, 4, 6, 0.8)")
    it "defaults to alpha 1", ->
      expect(Color.string(2, 4, 6)).toEqual("rgba(2, 4, 6, 1)")

  describe ".black()", ->
    it "builds a black rgba string", ->
      expect(Color.black()).toEqual("rgba(0, 0, 0, 1)")
    it "accepts alpha parameter", ->
      expect(Color.black(0.2)).toEqual("rgba(0, 0, 0, 0.2)")

  describe ".white()", ->
    it "builds a white rgba string", ->
      expect(Color.white()).toEqual("rgba(255, 255, 255, 1)")
    it "accepts alpha parameter", ->
      expect(Color.white(0.2)).toEqual("rgba(255, 255, 255, 0.2)")

  describe ".gray()", ->
    it "builds a black string for lightness = 0", ->
      expect(Color.gray(0)).toEqual("rgba(0, 0, 0, 1)")
    it "builds a white string for lightness = 1", ->
      expect(Color.gray(1)).toEqual("rgba(255, 255, 255, 1)")
    it "builds a gray string for lightness = 0.25", ->
      expect(Color.gray(0.25)).toEqual("rgba(64, 64, 64, 1)")
    it "accepts alpha parameter", ->
      expect(Color.gray(0.75, 0.1)).toEqual("rgba(192, 192, 192, 0.1)")
    it "defaults to lightness = 0.5, alpha = 1", ->
      expect(Color.gray()).toEqual("rgba(128, 128, 128, 1)")

  describe ".fader()", ->
    it "returns a function", ->
      expect(typeof(Color.fader(1, 2, 3, 10, 1))).toEqual("function")
    it "should be better tested"

  describe ".pulser()", ->
    it "returns a function", ->
      expect(typeof(Color.fader(1, 2, 3, 10, 1))).toEqual("function")
    it "should be better tested"
