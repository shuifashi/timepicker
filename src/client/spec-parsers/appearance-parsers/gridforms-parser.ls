gridforms-parser = ->

  parse: (spec, @model, @descriptions)->
    @sections = {}
    if spec.sections? then @parse-sections spec else @parse-rows spec
    {@sections, buttons: spec.buttons}

  parse-sections: (spec)!-> for own section-name, rows-spec of spec.sections
    @parse-rows (@alter-rows-spec spec, rows-spec, section-name), section-name

  alter-rows-spec: (spec, rows-spec, section-name)->
    rows = [[@alter-field-spec field-spec, section-name for field-spec in row-spec] for row-spec in rows-spec]
    $.extend deep = true, {rows}, spec{type, rows-css, fields-css}

  alter-field-spec: (field-spec, section-name)-> # ['姓名(2)', '性别', '婚姻状况(2)', '出生日期(2)' 3] 后面这个3是row hight
    if is-row-height = (typeof field-spec is 'number')
      field-spec
    else
      "#{section-name}.#{field-spec}"

  parse-rows: ({type, rows, rows-css, fields-css, sections}, section-name='@no-section')!->
    rows-specs = []
    for row, index in rows # 注意：不支持row嵌套
      row-spec = @parse-row row, fields-css, section-name
      row-spec.css = rows-css[index] if rows-css?[index]?
      rows-specs.push row-spec 
    @sections[section-name] = [@create-row row-spec, section-name for row-spec in rows-specs]

  parse-row: (row, field-css)->
    row-spec = {}
    if @is-multi-rows row
      row-spec.name = name = @descriptions.get-path-key row[0]
      row-spec.label = @descriptions[name].label
      row-spec.multi = @model[name].multi
      row-spec.rows = [@parse-row row, field-css for row in row[1 to -1]]
    else
      if (typeof last = row[row.length - 1]) is 'number'
        (row-spec.height = last ; row = row[0 to -2]) 
      else
        row-spec.height = 1
      row-spec.fields = [@parse-field field-name, field-css for field-name in row]
      row-spec.width = row-spec.fields.reduce ((pre, field)->  pre + field.width), 0
    row-spec

  is-multi-rows: (row)-> row.length >=2 and Array.is-array row[1]

  parse-field: (name, field-css)->
    [_all_, name, width] = name .match /(^.+)\((\d+)\)$/ if is-width-specified = name[name.length - 1] is ')'
    name = @descriptions.get-path-key name
    width = if width? then parse-int width else 1
    {name, width, css: field-css?[name]}

  create-row: (spec, section-name)->
    if spec.multi
      row = spec{name, multi}
      row.label = @get-label spec.label, section-name
      row.rows = [@create-row row-spec for row-spec in spec.rows]
    else
      row = spec{width, height, css}
      row.fields = [@create-field field-spec, section-name for field-spec in spec.fields] # TODO: 这里section的逻辑比较混乱，为了aiib demo，暂时这样。日后，一定要重构。
    row

  get-label: (label, section-name)->
    if section-name is '@no-section' then label else label.split "#{section-name}." .1 # TODO: 这里section的逻辑比较混乱，为了aiib demo，暂时这样。日后，一定要重构。

  create-field: (spec, section-name)->
    field = {}
    field{name, width, css} = spec
    field{valid, ref, value, multi, input-control-type, compute} = @model[spec.name]
    field{placeholder, tooltip} = @descriptions[spec.name]
    field.label = @get-label @descriptions[spec.name].label, section-name
    field



if define? # AMD
  define 'gridforms-parser', [], gridforms-parser 
else # other
  root = module?.exports ? @
  root.gridforms-parser = gridforms-parser!
