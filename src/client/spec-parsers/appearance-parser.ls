appearance-parser = (gridforms-parser, table-semantic-ui-parser)->

  parse: (spec, model, descriptions)->
    switch spec.type
    | 'gridforms'           =>      gridforms-parser.parse spec, model, descriptions
    | 'table.semantic-ui'   =>      table-semantic-ui-parser.parse spec, model, descriptions
    | otherwise             =>      throw new Error "unrecognized layout type: #{type}"


if define? # AMD
  define 'appearance-parser', ['gridforms-parser', 'table-semantic-ui-parser'], appearance-parser
else # other
  root = module?.exports ? @
  root.appearance-parser = appearance-parser gridforms-parser, table-semantic-ui-parser
