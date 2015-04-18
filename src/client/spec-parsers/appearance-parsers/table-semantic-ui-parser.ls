table-semantic-ui-parser = ->

  parse: ({type, columns}, @model, @descriptions)->
    appearance = columns: []
    [appearance.columns.push @get-column-spec column for column, index in columns]
    appearance

  get-column-spec: (column)->
    if typeof column is 'object'
      attr-path = Object.keys column .0
      spec = {name: attr-path, bind: attr-path}
      value = column[attr-path]['@compute']
      @model['@computations'][attr-path] = value
      spec.is-computed = true
    else
      bind = @descriptions.get-path-key column
      spec = name: column, bind: bind
    spec

if define? # AMD
  define 'table-semantic-ui-parser', [], table-semantic-ui-parser 
else # other
  root = module?.exports ? @
  root.table-semantic-ui-parser = table-semantic-ui-parser!
