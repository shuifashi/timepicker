define 'Time-behavior', [], -> class Time-behavior
  (@attr-path, @model)->
    @name = 'initial:time'
    @parse-model-spec!

  parse-model-spec: !->
    @spec = $.extend deep = true, {}, @model[@attr-path]

  act: (dom, @working-mode)!->
    $dom = $ dom
    @initial-dom $dom

  initial-dom: ($dom)!->
    $dom.attr 'type', 'text'
    # $dom.attr 'class', 'datetimepicker'
    # @options = {}
    # if @spec.start-date? then @options.start-date = @spec.start-date
    $dom.datetimepicker @options

