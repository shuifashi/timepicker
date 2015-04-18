define 'model-parser', [], ->
  __models__: {} # 为分析ref，特别是cascade ref，缓存parse过的model

  parse: (name, spec)-> 
    @model = {__name__: name, '@computations': {}}; @path = '' # ; @deep = 0 
    @defaults ||= []
    @_parse spec
    @_nomalize!
    @__models__[name] = @model
    @model

  _parse: (spec)!-> 
    for own key, value of spec
      if @is-directive key then @parse-top-level-directive key, value else
        @add-model-spec key, value
        @path = @move-path-down key, value
        @path = "#{@path}[]" if @model[@path]?.multi?
        @_parse value if value # end null 不用 parse
        @path = @move-path-up!

  parse-top-level-directive: (key, value)-> if key is '@default'
    @defaults.push @parse-default value

  parse-default: (spec)-> {[(@get-directive-key key), value] for own key, value of spec}
      
  move-path-down: (key, value)-> 
    @defaults.push @parse-default value
    if @path is '' then key else "#{@path}.#{key}"

  move-path-up: (key)-> 
    @defaults.pop! 
    (@path.split '.')[0 to -2].join '.'
        
  add-model-spec: (attr, obj)-> 
    if obj is null # 属性: null ， 此时属性的spec为空
      full-attr-path = @move-path-down attr
      @model[full-attr-path] = @get-default-options!
      @model[full-attr-path].input-control-type = @parse-input-control-type full-attr-path
    else
      all-directive-keys = true
      full-attr-path = @move-path-down attr
      @model[full-attr-path] ||= @get-default-options!
      for key, value of obj 
        (all-directive-keys = false ; continue) if not @is-directive key
        directive-key = @get-directive-key key
        (@model['@computations'][full-attr-path] = value ; @model[full-attr-path].valid.required = false) if directive-key is 'compute'
        $.extend deep = true, @model[full-attr-path], {"#{directive-key}": value} if key isnt '@default'
      if all-directive-keys and not @model[full-attr-path]?input-control-type
        @model[full-attr-path].input-control-type =  @parse-input-control-type full-attr-path

  get-default-options: -> 
    effective-default = {}
    [effective-default <<< ($.extend deep = true, {}, def) for def in @defaults]
    effective-default

  parse-input-control-type: (attr)->
    if type = @model[attr]?.type
      switch type
      | 'text'      =>    'textarea'
      | 'select'    =>    'select'
      | 'typeahead' =>    'typeahead'
      | otherwise   =>    "input.#{type}"
    else
      @guess-input-control-type attr

  guess-input-control-type: (attr)-> @guess-by-directive attr or @guess-by-name attr

  guess-by-directive: (attr)-> 
    switch
    | @model[attr]?.ref or @model[attr]?.multi or @model[attr]?.values    =>    'select' # 1）multi values，选择。2）ref values是_id，显示出对应内容，却不保存。
    | otherwise                                                           =>     null

  guess-by-name: (attr)->
    last = (start, end)-> attr.substr (attr.length - start), (attr.length - end) .to-lower-case!
    switch
    | attr is '_id'                        =>    'input.hidden'
    | (last 4, 1) is 'time'                =>    'input.datetime-local'
    | (last 2, 1) is '时间'                 =>    'input.datetime-local'
    | (last 5, 1) in ['count', 'times']    =>    'input.number'
    | (last 1, 1) is '数'                  =>    'input.number'
    | (last 6, 1) is 'amount'              =>    'input.number'
    | otherwise                            =>    'input.text'

  is-directive: (key)-> (key.index-of '@') is 0

  get-directive-key: (key)-> if key[0] is '@' then key.substr 1, key.length else key# strip the leading @

  _nomalize: !->
    @parse-refs!
    @collect-all-refs!

  parse-refs: !-> 
    [spec.ref = @parse-ref spec.ref for attr-path, spec of @model when spec.ref?]

  collect-all-refs: !-> 
    @model['@refs'] = [spec.ref for attr-path, spec of @model when spec.ref?]

  parse-ref: (ref)->
    [model, attr] = ref.split '.'
    ref-spec = state-name: (_.pluralize model) , attrs: ['_id', attr] 
    _ref-spec = {} <<< ref-spec
    ref-model = @__models__[model] 
    if ref = ref-model?[attr]?ref
      ref-spec.cascade-refs = []
      ref-spec.cascade-refs.push _ref-spec
      @parse-cascade-refs ref-spec.cascade-refs, ref  
    ref-spec

  parse-cascade-refs: (cascade-refs, ref-spec)->
    cascade-refs.push ref-spec
    ref-model-name = _.singularize ref-spec.state-name
    ref-model = @__models__[ref-model-name]
    ref-attr = ref-model?[ref-spec.attrs[1]]
    if ref-model-name isnt 'user' and ref-attr.ref 
      @parse-cascade-refs cascade-refs, ref-attr.ref
