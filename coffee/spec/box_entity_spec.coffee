describe "BoxEntity", ->

  p = (x, y) -> new Point(x, y)

  subject = new BoxEntity()

  describe "moveTowards()", ->
    it "sets full-speed velocity", ->
      arrived = subject.moveTowards(p(40, 30), 10, 0.1)
      expect(subject.velocity).toEqual(p(8, 6))
      expect(subject.velocity.length()).toEqual(10)
      expect(arrived).toBe(false)
    it "caps speed to remaining distance, to arrive after this tick", ->
      arrived = subject.moveTowards(p(40, 30), 10000, 0.5)
      expect(subject.velocity).toEqual(p(80, 60))
      expect(subject.velocity.length()).toEqual(100)
      expect(arrived).toBe(false)
    it "stops and returns true when moving towards current position", ->
      arrived = subject.moveTowards(p(0, 0), 10, 0.012)
      expect(subject.velocity).toEqual(p(0, 0))
      expect(arrived).toBe(true)

  describe "setPosition()", ->
    beforeEach ->
      subject.setSize(10)
      subject.setPosition(p(20, 40))
    it "sets position", ->
      expect(subject.position).toEqual(p(20, 40))
    it "sets top, bottom, left, right scalars", ->
      expect(subject.top).toBe(35)
      expect(subject.bottom).toBe(45)
      expect(subject.left).toBe(15)
      expect(subject.right).toBe(25)
    it "sets corner points", ->
      expect(subject.corners).toEqual([
        p(subject.left, subject.top)
        p(subject.right, subject.top)
        p(subject.left, subject.bottom)
        p(subject.right, subject.bottom)
      ])

  describe "setSize()", ->
    it "sets size", ->
      expect(subject.setSize(8).size).toBe(8)
    it "sets sizeDelta", ->
      expect(subject.setSize(8).sizeDelta).toEqual(p(4, 4))

  describe "setVelocity()", ->
    it "sets velocity from x, y", ->
      expect(subject.setVelocity(2, 4).velocity).toEqual(p(2, 4))
    it "sets velocity from Point", ->
      expect(subject.setVelocity(p(4, 8)).velocity).toEqual(p(4, 8))

  describe "stop()", ->
    it "sets velocity to zero", ->
      expect(subject.setVelocity(2, 2).stop().velocity).toEqual(Point.Zero)

  describe "update()", ->
    it "updatess position based on velocity and timeDelta", ->
      subject.setPosition(2, 2)
      subject.setVelocity(40, 20)
      subject.update(0.05)
      expect(subject.position).toEqual(p(4, 3))
