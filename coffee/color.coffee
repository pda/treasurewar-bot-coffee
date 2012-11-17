# Representation and factory methods for RGBA colors.
class @Color

  constructor: (@r, @g, @b, @a = 1.0) ->

  toString: ->
    "rgba(#{@r}, #{@g}, #{@b}, #{@a})"

  # Color.string(0, 255, 0, 0.5) => "rgba(0, 255, 0, 0.5)"
  @string: (r, g, b, a = 1.0) ->
    new Color(r, g, b, a).toString()

  # Color.black() => "rgba(0, 0, 0, l.0)"
  @black: (alpha = 1.0) ->
    @string(0, 0, 0, alpha)

  # Color.white() => "rgba(255, 255, 255, l.0)"
  @white: (alpha = 1.0) ->
    @string(255, 255, 255, alpha)

  # Color.gray(0.5) => "rgba(128, 128, 128, 1.0)"
  @gray: (lightness = 0.5, alpha = 1.0) ->
    value = Math.ceil(255 * lightness)
    @string(value, value, value, alpha)

  # Returns a function which, when called repeatedly, returns the specified
  # color with the alpha channel fading from 1.0 to 0.0 over the specified
  # amount of time.
  @fader: (r, g, b, seconds, initial = 1) ->
    start = Date.now()
    ->
      elapsed = (Date.now() - start) / 1000
      alpha = Math.max(0, initial - elapsed / seconds * initial)
      Color.string(r, g, b, alpha)

  # Returns a function which, when called repeatedly, returns the specified
  # color with the alpha channel fading in and out.
  # Seconds is the period of the pulse.
  # fadeFactor is the peak amount of alpha subtracted.
  @pulser: (r, g, b, seconds = 1, fadeFactor = 1) ->
    start = Date.now()
    ->
      elapsed = (Date.now() - start) / 1000
      alpha = ((Math.sin(elapsed * 2 * Math.PI / seconds) + 1) / 2)
      alpha = alpha * fadeFactor + 1 - fadeFactor
      Color.string(r, g, b, alpha)
