define 'Selectize-behavior', ['state'], (state)-> class Selectize-behavior
  (@attr-path, @model)-> #at @time execute @fn
    @name = 'initial:selectize'
    @time = 'dom-ready'
    @parse-model-spec!

  parse-model-spec: !->
    @spec = $.extend deep = true, {}, @model[@attr-path]
    @ <<< @spec{multi, values, initial, disabled, ref}
    [@min, @max] =  @multi ? [0, 1]
    if @ref
      {@state-name, @attrs} = @ref
      [_id, @attr] = @attrs

  act: (dom, @working-mode)!-> # dom is the select, working-mode: create | edit | view
    origin-select = $ dom
    @selectizer = (origin-select.selectize @get-selectize-config!)[0].selectize
    @selectizer['@set-value'] = (value)!~> @set-value value
    if @working-mode is 'create' then @set-auto-run-to-update-meteor-related-options! else @update-selected-items!
    @watch-state-to-update-options! if @state-name # 根据ref的state的变化，调整options
    @disabled = @working-mode is 'view'
    @disable! if @disabled

  set-auto-run-to-update-meteor-related-options: !-> Tracker.autorun !~>
    Meteor.user! # TODO：这里是Hack！Meteor的autorun不能够追踪我们这里的执行。而只有user数据是用meteor的，故而暂时Hack下。
    @update-selected-items!

  update-selected-items: !->
    value = @selectizer.get-value!
    @selectizer.clear!
    if isEmpty = (not value or value.length)
      # @add-item item if @options?.length and @working-mode is 'create' and item = @initial? @selectizer
      @set-value item if @working-mode is 'create' and item = @initial? @selectizer
      # @selectizer.clear!
    else
      @set-value value

  disable: !->
    @selectizer.disable!
    @selectizer.settings.placeholder = '-'
    @selectizer.updatePlaceholder!

  get-selectize-config: (selectizer)->
    config = max-items: @max
    if @values
      config.options = [{text: value, value} for value in @values]
    else
      config.options = @get-options-from-state! if not @ref.cascade-refs
      config.value-field = '_id'
      config.label-field = @attr
      config.search-field = @attr
    config

  get-options-from-state: -> # 注意：因为options随时会变化，所以不宜用@config.option保留，而是每次计算。
    @options = state[@state-name]!map (obj)~> _.pick obj, @attrs

  watch-state-to-update-options: -> state[@state-name].observe (new-value)~>
    @update-options!
    @update-selected-items!

  update-options: ->
    @selectizer.clear-options!
    @selectizer.add-option @get-options-from-state!
    # @selectizer.refresh-options!

  set-value: (_id)!-> if @ref?.cascade-refs then @set-cascade-refs-value _id else @selectizer.set-value _id

  set-cascade-refs-value: (_id)->
    Meteor.call 'get-cascade-refs-value', _id, @ref.cascade-refs, (error, value)~> #[{first._id, cascade-end-value}]
      @selectizer.clear-options!
      @selectizer.add-option [{_id, "#{@attr}": value}]
      @selectizer.add-item _id
