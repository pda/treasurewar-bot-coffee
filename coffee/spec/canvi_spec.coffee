describe "Canvi", ->

  doc = {}
  canvi = new Canvi(doc, 10, 20, "a", "b")

  it "holds reference to document", ->
    expect(canvi.document).toBe(doc)

  it "holds reference to width & height", ->
    expect(canvi.width).toBe(10)
    expect(canvi.height).toBe(20)

  it "holds reference to names", ->
    expect(canvi.names).toEqual(["a", "b"])

  describe "nameForId()", ->
    it "prepends 'canvas_' to name", ->
      expect(canvi.nameForId("test")).toEqual("canvas_test")

  describe "build()", ->
    beforeEach ->
      doc = {body: {appendChild: null}, createElement: null, canvases: []}

      # doc creates and store fake canvases
      doc.createElement = ->
        _({getContext: null, style: {}}).tap (canvas) ->
          doc.canvases.push(canvas)
          spyOn(canvas, "getContext").andCallFake((param) -> "#{this.id}.#{param}")

      spyOn(doc.body, "appendChild")

      canvi = new Canvi(doc, 10, 20, "a", "b")
      canvi.build()

    it "stores layers (canvas elements) by name", ->
      expect(canvi.layers["a"]).toBe(doc.canvases[0])
      expect(canvi.layers["b"]).toBe(doc.canvases[1])

    it "stores 2d contexts by name", ->
      expect(canvi.contexts["a"]).toEqual("canvas_a.2d")
      expect(canvi.contexts["b"]).toEqual("canvas_b.2d")

    it "appends layers to document.body", ->
      _(doc.canvases).each (canvas) ->
        expect(doc.body.appendChild).toHaveBeenCalledWith(canvas)

    it "sets canvas attributes", ->
      keys = ["width", "height", "id", "style"]
      expect(_(doc.canvases[0]).pick(keys)).toEqual(
        width: 10
        height: 20
        id: "canvas_a"
        style: {position: "absolute"}
      )
