log = (message) ->
  p = document.createElement("p")
  p.appendChild(document.createTextNode(message))
  document.body.appendChild(p)

tableRow = (cells, type = "td") ->
  tr = document.createElement("tr")
  for content in cells
    cell = document.createElement(type)
    cell.appendChild(document.createTextNode(content))
    tr.appendChild(cell)
  tr


class Timer
  constructor: ->
    @start = Date.now()
    @marks = []
    @count = 0
  mark: (message) ->
    @count++
    message ||= "Mark #{@count}"
    @marks.push([Date.now(), message])
  report: ->
    table = document.createElement("table")
    table.style.minWidth = "400px"
    table.appendChild(tableRow([
      "Message"
      "Step"
      "Total"
    ], "th"))
    previous = @start
    for [time, message] in @marks
      table.appendChild(tableRow([
        message
        "#{time - previous} ms"
        "#{time - @start} ms"
      ]))
      previous = time
    document.body.appendChild(table)


MAP = [
  "################################"
  "#                              #"
  "#   #                      #   #"
  "#   #          @           #   #"
  "#   #                      #   #"
  "#   #                      #   #"
  "#   #                      #   #"
  "#   #                      #   #"
  "#   ########################   #"
  "#                              #"
  "#                              #"
  "#                              #"
  "#                              #"
  "#               $              #"
  "################################"
]

map = Map.fromAscii(0, MAP)

origin = map.player
destination = map.loot[0]
walls = map.walls

timer = new Timer()

path = undefined
for x in [1..10]
  path = new AStar().search(origin, destination, walls, 1024000)
  timer.mark()

log "Benchmarked AStar for path of length #{path.length}"
timer.report()

log "History of ten iterations:"
log "2661ms: originally."
log " 780ms: changed from euclidean to manhattan distance."
log " 510ms: changed Point#toString from array join to string concatentaion."
log " 345ms: eliminated unnecessary CoffeeScript function binding."
log " 140ms: AStar.PointSet uses array, not string-indexed object."
