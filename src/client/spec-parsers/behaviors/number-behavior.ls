define 'Number-behavior', [], -> class Number-behavior
  (@attr-path, @model)-> #at @time execute @fn
    @name = 'initial:number'
    @parse-model-spec!

  parse-model-spec: !->
    @spec = $.extend deep = true, {}, @model[@attr-path]
    @ <<< @spec{min, max, step, precision}

  act: (dom, @working-mode)!-> # working-mode: create | edit
    $number = $ dom
    @initial-dom $number
    $number.parent!.spinner {@min, @max, @step, @precision}

  initial-dom: ($dom)!->
    $dom.attr 'type', 'text'
      .attr 'data-parsley-trigger', 'change' # 否则点击按钮修改会验证出错
      .wrap '<div class="spinner" />'
      .after container = $ '<div class="add-on">'
    container.append '<a href="#" data-spin="up"><i class="black icon arrow up"></i></a>'
      .append '<a href="#" data-spin="down"><i class="black icon arrow down"></i></a>'
