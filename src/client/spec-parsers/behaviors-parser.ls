define 'behaviors-parser', ['Selectize-behavior', 'Number-behavior', 'Checkbox-behavior', 'Time-behavior'], (Selectize-behavior, Number-behavior, Checkbox-behavior,Time-behavior)->
  parse: (behavior, options, attr-path, model)->
    switch behavior
    | 'initial:selectize' => new Selectize-behavior attr-path, model
    | 'initial:number'    => new Number-behavior attr-path, model
    | 'initial:checkbox'  => new Checkbox-behavior attr-path, model
    | 'initial:time'      => new Time-behavior attr-path, model
    | otherwise           => console.warn "behavior: #{behavior} has't implemented yet."
