define 'widget-detail-spec-generator', ['model-parser', 'descriptions-parser', 'appearance-parser', 'behaviors-parser'], (model-parser, descriptions-parser, appearance-parser, behaviors-parser)->
  generate: (spec, @model, @descriptions, @runtime)->
    {@name, @type, @label, @class, @folderable, model, descriptions, appearance, behaviors} = spec
    @get-widget-name model
    @parse-descriptions descriptions
    @parse-appearance appearance
    @parse-behaviors behaviors
    @create-detail-spec!

  get-widget-name: (@model-name)!->
    maniplated-data = if @type is 'list' then _.pluralize model-name else _.singularize model-name
    @name ||= "#{@type}-#{maniplated-data}"
    @item-template-name = "#{@name}-template" if @type is 'list'

  parse-descriptions: (descriptions)!-> # if descriptions?
    @descriptions = descriptions-parser.parse @model, descriptions, @descriptions

  parse-behaviors: (directly-specified-behaviors)!->
    @behaviors = {}
    @parse-behaviors-directly-specified directly-specified-behaviors
    @parse-behaviors-from-model!

  parse-behaviors-directly-specified: (behaviors)!->
    for own key, behavior of behaviors
      attr-path = @descriptions.get-path-key key
      @add-behavior attr-path, behavior

  add-behavior: (attr-path, behavior, options)!->
    @behaviors[attr-path] ||= []
    behavior-spec = behaviors-parser.parse behavior, options, attr-path, @model
    @behaviors[attr-path].push behavior-spec if behavior-spec

  parse-behaviors-from-model: !-> for own attr-path, spec of @model
    @add-behavior attr-path, 'initial:selectize' if @type in ['create', 'edit', 'view'] and spec['input-control-type'.camelize!] is 'select'
    @add-behavior attr-path, 'initial:number' if @type in ['create', 'edit'] and spec['input-control-type'.camelize!] is 'input.number'
    @add-behavior attr-path, 'initial:checkbox' if @type in ['create', 'edit', 'view'] and spec['input-control-type'.camelize!] is 'input.checkbox'
    @add-behavior attr-path, 'initial:time' if @type in ['create', 'edit', 'view'] and spec['input-control-type'.camelize!] is 'input.time'

  parse-appearance: (appearance)!->
    @appearance = appearance-parser.parse appearance, @model, @descriptions


  create-detail-spec: ->
    spec = {@type, @class, @name, @model-name, @item-template-name, @label, @folderable, @runtime}
    spec.behaviors = @behaviors
    spec <<< @appearance
