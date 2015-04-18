define 'Checkbox-behavior', [], -> class Checkbox-behavior
  (@attr-path, @model)-> #at @time execute @fn
    @name = 'initial:checkbox'
    @parse-model-spec!

  parse-model-spec: !->
    @spec = $.extend deep = true, {}, @model[@attr-path]
    @ <<< @spec{values, multi}
    [@min, @max] = @multi ? [0, 1]

  act: (dom, @working-mode)!-> # working-mode: create | edit
    $dom = $ dom
    @container = $dom.parent!
    @initial-dom $dom
    @add-validation!
    @activite-set-value-event!
    @disable! if disabled = @working-mode is 'view'

  initial-dom: ($dom)!->
    for value in @values
      [__all__, value] = matches-default if matches-default = value.match /(.*)\(default\)$/
      ( [__all__, value] = matches-input ; @free-input-key = value ) if matches-input = value.match /(.*)\(input\)$/
      container = $ '<div>' .add-class 'ui checkbox'
        .append ($checkbox = $dom.clone!.attr 'value', value)
        .append "<label> #{value} </label>"
      $dom.before container.checkbox!
      @check container if matches-default
      if matches-input # 如果放在container里面调用checkbox方法不生效
        $dom.before (@free-input-field = $ '<input>' .attr 'type', 'text' .attr 'placeholder', value)
        @add-free-input-event $checkbox
    $dom.remove!

  check: ($dom)!->
    $dom.closest '.ui.checkbox' .checkbox 'check'

  add-free-input-event: ($checkbox)!->
    @free-input-field.on 'blur keyup', !-> $checkbox.attr 'value', ($ @ .val!)

  add-validation: !->
    @container.attr 'data-b-plus-parsley-container', @attr-path
    @container.find '[type=checkbox]' .attr do
      'data-parsley-trigger': 'change'
    .first!.attr do
      'data-parsley-check': "[#{@min}, #{@max}]"
      'data-parsley-errors-container': "[data-b-plus-parsley-container='#{@attr-path}']"

  activite-set-value-event: !->
    @container.find '[type=checkbox]' .first!.on 'set-value', (event, data)!~>
      @container.find '[type=checkbox]' .prop 'checked', false
      data.split /\s*,\s*/ .for-each (value)!~>
        match-checkbox = @container.find "[value='#{value}']"
        if match-checkbox.length > 0
          @check match-checkbox
        else if @free-input-field?.length > 0
          @check(@container.find "[value='#{@free-input-key}']" .attr 'value', value)
          @free-input-field.val value

  disable: !->
    @container.find 'input[type=checkbox]' .prop 'disabled', true
