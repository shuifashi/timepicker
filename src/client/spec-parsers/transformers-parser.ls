transformers-parser = ->

  parse: (name, spec)->
    result = {}
    


  


if define? # AMD
  define 'transformers-parser', [], transformers-parser 
else # other
  root = module?.exports ? @
  root.transformers-parser = transformers-parser!
