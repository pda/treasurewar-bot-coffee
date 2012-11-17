require ["vendor/underscore", "vendor/jasmine"], ->
  require ["vendor/jasmine-html"], ->

    subject_files = [
      "box_collider"
      "box_entity"
      "canvi"
      "color"
      "line"
      "map"
      "point"
    ]

    spec_files = _(subject_files).map (f) -> "spec/#{f}_spec"

    require subject_files, ->
      require spec_files, ->

        jasmineEnv = jasmine.getEnv()
        jasmineEnv.updateInterval = 1000

        htmlReporter = new jasmine.HtmlReporter()

        jasmineEnv.addReporter(htmlReporter)

        jasmineEnv.specFilter = (spec) ->
          htmlReporter.specFilter(spec)

        currentWindowOnload = window.onload

        window.onload = ->
          if currentWindowOnload then currentWindowOnload()
          execJasmine()

        window.execJasmine = ->
          jasmineEnv.execute()
