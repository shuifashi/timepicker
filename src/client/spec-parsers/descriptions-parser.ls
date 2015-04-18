class Descriptions
  (@__model__)->

  parse: (descriptions, old-descriptions)->
    @ <<< @clone old-descriptions if old-descriptions
    if descriptions
      @parse-labels descriptions.labels
      # @labels <<< old-descriptions.labels
      @parse-placeholders descriptions.placeholders
      @parse-tooltips descriptions.tooltips
    @set-labels-of-not-defined-attrs!
    @

  clone: (obj)-> 
    $.extend deep = true, {}, obj
    # JSON.parse JSON.stringify obj

  parse-labels: (labels)!->
    @parse-labels-defined labels

  parse-labels-defined: (labels)!-> for own let key, label of labels
    key = key.camelize!
    @set 'label', key, label

  set-labels-of-not-defined-attrs: !->
    for own key, sepc of @__model__ when not @[key]?label?
      @[key] ||= {}
      @[key].label = key

  parse-placeholders: (user-specified-placeholders)!->
    @add-default-placeholders!
    @add-user-specified-placeholders user-specified-placeholders

  add-default-placeholders: !-> for own attr-path, spec of @__model__
    for key, value of spec when key is 'input-control-type'.camelize! and value is 'select' # and (min = spec.multi[0]) is 0
      @set 'placeholder', attr-path, '' # '请选择...'

  add-user-specified-placeholders: (placeholders)!->
    [@set 'placeholder', key-or-label, placeholder for own let key-or-label, placeholder of placeholders]

  parse-tooltips: (user-specified-tooltips)!-> 
    @add-default-tooltips!
    @add-user-specified-tooltips user-specified-tooltips

  add-default-tooltips: !-> 

  add-user-specified-tooltips: (tooltips)!->
    [@set 'tooltip', key-or-label, tooltip for own let key-or-label, tooltip of tooltips]
    

  set: (attr, key-or-label, value)->
    key = if attr is 'label' then key-or-label else @get-path-key key-or-label
    @[key] ||= {}
    @[key][attr] = value

  get-path-key: (key-or-label)-> # 先找key，找到就用，然后找label
    key = key-or-label.camelize!
    key = if @__model__[key-or-label] then key else @find-key key-or-label
    throw new Error "can't find key for #{key-or-label}" if not key
    key

  find-key: (label)->
    [return key for key, description of @ when key isnt '__model__' and description.label is label]

descriptions-parser = ->
  parse: (model, descriptions, old-descriptions)->
    (new Descriptions model).parse descriptions, old-descriptions


if define? # AMD
  define 'descriptions-parser', ['model-parser', 'util'], descriptions-parser 
else # other
  root = module?.exports ? @
  root.descriptions-parser = descriptions-parser model-parser
