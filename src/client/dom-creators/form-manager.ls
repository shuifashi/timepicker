# 1) 初始化后用户可点击加、减表单的行(s)。根据multi的restriction添加并维护加（+）、减（-）按钮，达到上限不显示加，达到下限不显示减。
# 2）提供了f2d，d2f方法，萃取form数据、将数据填充到表单中（自动根据数据增减行）。
# 3）提供了save-current和reset方法，保存和恢复表单状态。
class Smart-form
  (@form, @is-editable, @working-mode, @form-data, @add-dom-behaviors)!-> 
    @unrendered-form = @form.clone!

  activate: (need-save-current = true)!->
    console.warn "spec-behaviors 没有设定！" if not @spec-behaviors
    @render-form @form
    if @is-editable 
      @save-current! if need-save-current
    else
      @form.find 'input, select, textarea' .attr 'disabled', 'disabled' # 提醒：与下面行交换后，界面将显示彩色选项。现在是灰色。
      @form.find '.button' .hide!

  save-current: !-> @data = @f2d!

  clear: !->
    new-form = @unrendered-form.clone!
    @form.replace-with new-form
    @form = new-form
    @activate need-save-current = false
    @add-dom-behaviors @form

  reset: !->
    @d2f @data

  add-behaviros: (_dom)!->
    dom = $ (_dom or @form) # 对整个表单，或者新增的dom
    @add-clicking-to-add-remove-item dom
    @add-input-fields-behaviors dom

  add-clicking-to-add-remove-item: (dom)!->
    self = @
    dom.find '.a-plus.add-array-item' .click -> self.clicking-button-to-add-array-item @
    dom.find '.a-plus.remove-array-item' .click -> self.clicking-button-to-remove-array-item @

  add-input-fields-behaviors: (dom)!-> 
    self = @
    for own attr-path, behaviors of @spec-behaviors 
      targets = @get-dom-contain-target dom, attr-path
      targets.each -> [behavior.act @, self.working-mode for behavior in behaviors]

  get-dom-contain-target: (dom, attr-path)->
    self = @ 
    dom.find '[name]' .filter -> self.strip-index-number-in-name($ @ .attr 'name') is attr-path

  strip-index-number-in-name: (name)-> name.replace /\[\d+]/g, '[]'

  render-form: (dom)!->
    containers = @form.find '.a-plus.array-container'
    @render-containers containers
    @add-behaviros!

  render-containers: (containers)!-> for container in containers
    container = $ container
    {min, max} = @parse-restriction container # 注意：这里将min，max写入dom，而不是通过model来查询，是为了调试时的便利。如果影响效率，可考虑改回用model。
    if @is-editable
      @insert-adding-item-button container
      @insert-removing-item-button container
      @save-unrendered-item-for-future-clone container
      @add-up-to-minium-items container
      @show-or-hide-adding-removing-buttons container
    else
      @save-unrendered-item-for-future-clone container


  save-unrendered-item-for-future-clone: (container)->
    item = container.children '.a-plus.array-item' .get 0
    unrendered-item = $ item .clone!
    unrendered-item.remove-class 'array-item' .add-class 'unrendered-item' 
    @rename-attr unrendered-item, 'name', '__name__'
    unrendered-item.hide!
    $ item .before unrendered-item

  rename-attr: (dom, old-name, new-name)->
    dom.find "[#{old-name}]" .each -> 
      $ @ .attr new-name, ($ @ .attr old-name)
      $ @ .remove-attr old-name

  get-container-item-template: (container)->
    unrendered-item = container.children '.unrendered-item' .get 0
    template = $ unrendered-item .clone!
    @rename-attr template, '__name__', 'name'
    template.remove-class 'unrendered-item' .add-class 'array-item'

  add-up-to-minium-items: (container)!-> 
    {min, max} = @parse-restriction container
    [@add-array-item container for i in [1 to min]] if min > 1

  show-or-hide-adding-removing-buttons: (container)!-> 
    length = parse-int container.attr 'data-a-plus-length'
    {max, min} = @parse-restriction container
    removes = container.children '.array-item' .children '.a-plus.remove-array-item'
    adds    = container.children '.a-plus.add-array-item'
    switch
    | length <= min       => removes.hide! ; adds.show!
    | min < length < max  => removes.show! ; adds.show!
    | length >= max       => removes.show! ; adds.hide!

  insert-adding-item-button: (container)!->
    self = @
    button = $ '<i class="plus icon a-plus add-array-item"></i>' # TODO：refactor出一个style-classes-manager，更加appearance.type，动态确定classes
    container .prepend button 

  insert-removing-item-button: (container)!->
    items = container.children '.a-plus.array-item'
    [@add-clicking-to-remove-this-item container, item for item in items]

  clicking-button-to-add-array-item: (button)-> 
    container = $ button .closest '.array-container'
    length = parse-int container.attr 'data-a-plus-length' 
    if length is 0
      item = container.children '.array-item'
      @change-fields-name item.show!, 'name' # 从0增加时，仅仅是恢复隐藏的。
      container.attr 'data-a-plus-length', 1
      @show-or-hide-adding-removing-buttons container 
    else
      @add-array-item container 
    false

  add-array-item: (container)!-> 
    @form-data.add-array-item  container
      , (container, item)!~> @add-item-behavior container, item
      , (container)~> @get-container-item-template container
  
  add-item-behavior: (container, item)!->
    @add-behaviros item
    @increase-index-and-length container, item
    @show-or-hide-adding-removing-buttons container

  add-clicking-to-remove-this-item: (container, item)->
    button = $ '<i class="remove icon a-plus remove-array-item"></i>'
    $ item .prepend button 

  clicking-button-to-remove-array-item: (button)->
    item = $ button .closest '.array-item'
    container = $ button .closest '.array-container'
    length = parse-int container.attr 'data-a-plus-length'
    if length > 1 
      item.remove! 
      @decrease-index-and-length container
    else 
      @change-fields-name item.hide!, '_name_' # 当仅剩一个item，不能移除，以便将来添加时，能够有模板clone
      container.attr 'data-a-plus-length', 0
    @show-or-hide-adding-removing-buttons container ; false

  change-fields-name: (item, _to)->
    from = if _to is '_name_' then 'name' else '_name_'
    item.find "[#{from}]" .each -> $ @ .attr _to, ($ @ .attr from) .remove-attr from

  decrease-index-and-length: (container)!->
    items = container.children '.a-plus.array-item'
    [@update-item-index item, index for item, index in items]
    length = (container.attr 'data-a-plus-length') - 1 
    container.attr 'data-a-plus-length',  length


  parse-restriction:  do ->
    parse-number = (number)-> if number is '*' then Infinity else parse-int number
    (container)!->
      restriction = container.attr 'data-a-plus-restriction'
      if not restriction
        [min = 0, max = Infinity]
      else
        [__all__, min, max] = restriction.match /\[(\d+).+([\d*]+)]/
        [min = (parse-number min), max = (parse-number max)]
      return {restriction, min, max}

  increase-index-and-length: (container, new-item)!->
    new-item-index = parse-int container.attr 'data-a-plus-length'
    @update-item-index new-item, new-item-index
    container.attr 'data-a-plus-length', length = new-item-index + 1 

  update-item-index: (item, index)!-> 
    old-item-name = $ item .attr 'name' or $ item .children '[name]' .attr 'name'
    new-item-name = (old-item-name[0 to -4].join '') + "[#{index}]"
    fields = $ item .find '[name]'
    [@update-name ($ field), old-item-name, new-item-name for field in fields]
    @update-name item, old-item-name, new-item-name

  update-name: (dom, old-item-name, new-item-name)!-> if old-name = $ dom .attr 'name'
    new-name =  old-name.replace old-item-name, new-item-name
    $ dom .attr 'name' new-name

  f2d: (data)-> @form-data.f2d @form, data

  d2f: (data)-> 
    @form-data.d2f data, @ # 不能直接传@form，clear时，会发生置换
      , (container, item)~> @add-item-behavior container, item
      , (container)~> @get-container-item-template container
      , !~> @clear!


define 'smart-form-manager', ['form-data'], (form-data)->
  create: (dom, type, add-dom-behaviors)-> # type: create | edit | view
    working-mode = type 
    is-editable = type isnt 'view' 
    new Smart-form dom, is-editable, working-mode, form-data, add-dom-behaviors
