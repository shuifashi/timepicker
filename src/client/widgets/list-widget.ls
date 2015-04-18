# TODO：这里的大部分方法和container-widget重复，考虑如何重构。
define 'List-widget', ['Abstract-widget', 'table-semantic-ui-dom-creator', 'state', 'permissions-manager'], (Abstract-widget, table-semantic-ui-dom-creator, state, permissions-manager)-> class List-widget extends Abstract-widget
  set-data-state: !->
    @data-state-name = _.pluralize @model-name
 
  create-dom: !-> 
    [@dom, @template] = table-semantic-ui-dom-creator.create @spec
    @items-doms = {}

  bind-data: !-> 
    [@create-item item for item in @get-state!!reverse!]
    @listen-for-add-item!
    super ...

  activate: !-> 
    super ...
    @activate-clicking-tr-to-select-data!
    @activate-clicking-operation-td-to-delete-data!
    
  create-item: (item)->
    dom = if (is-already-added-to-dom = $ "[iid='#{item._id}']" .length > 0) then $ "[iid='#{item._id}']" else $ @template .clone!remove-attr 'id' .add-class _.singularize @model-name .show!
    dom.remove-attr 'data-b-plus-list-item-template'
    state = @get-state!get-element item._id
    @bind-state-to-dom state, dom
    @after-render-item dom, item if not is-already-added-to-dom
    @listen-for-remove-item @get-state!, item, dom
    @items-doms[item._id] = dom

  bind-state-to-dom: (state, dom)!-> 
    @update-dom-with-data dom, state!
    state.observe (new-data)!~> 
      @update-dom-with-data dom, state!

  apply-computation-on-item: (name, computation)!->
    $ @current-item-dom .find "[data-a-plus-bind='#{name}']" .text computation.get-value.apply @item-data

  apply-computation: (name, computation)!-> [@update-dom-with-data dom, (@get-state!get-element item-id)! for own item-id, dom of @items-doms]

  update-dom-with-data: (dom, data)!->
    self = @
    $ dom .find '[data-a-plus-bind]:not([data-a-plus-computation])' .each -> self.update-element-with-data @, data
    @current-item-dom = dom ; @item-data = data
    @fill-computed-data!

  update-element-with-data: (element, data)!->
    bind-expression = $ element .attr 'data-a-plus-bind'
    @evaluate bind-expression, data, element, (text)-> $ element .text text

  evaluate: (exp, data, element, done)->
    if @model[exp]?transformer?
      @evaluate-by-transformer exp, data, element, done
    else
      @evaluate-bind-expression exp, data, done

  evaluate-by-transformer: (exp, data, element, done)->
    @evaluate-bind-expression exp, data, (result)~>
      done @model[exp].transformer.call data, result, element

  evaluate-bind-expression: (exp, context, done)->
    try 
      result = eval ("context." + exp)
    catch
      try
        result = eval exp
    finally
      if typeof result is 'function' 
        done result.apply context 
      else if @model[exp]?.ref?
        @get-ref-value exp, result, done
      else 
        done result

  get-ref-value: (attr, _id, done)->
    if @model[attr].ref.cascade-refs
      @get-cascade-ref-value attr, _id, done 
    else 
      data-state = state[@model[attr].ref.state-name].get-element _id
      done data-state?![@model[attr].ref.attrs[1]]

  get-cascade-ref-value: (attr, _id, done)->
    Meteor.call 'get-cascade-refs-value', _id, @model[attr].ref.cascade-refs, (error, value)~> #[{first._id, cascade-end-value}]
      done value

  listen-for-add-item: !->
    @get-state!.observe (item)!~>
      @create-and-show-item-dom item # post图片comment的时候，先直接create-and-show-item-dom了，add的时候，触发服务端的数据添加，而不再在本地create dom。
    , observer-type = 'add'

  create-and-show-item-dom: (item, is-add-to-state = true)->
    new-dom = @create-item(item, is-add-to-state).add-class 'yellow-fade yellow-fade-start' 
    set-timeout !~>
      new-dom.remove-class 'yellow-fade-start'
      @after-add? item, @new-dom 
      set-timeout !-> new-dom.remove-class 'yellow-fade', 0
    , 0
    new-dom

  listen-for-remove-item: (state, item, dom)!->
    state.observe (removed-item)!~> 
      if removed-item._id is item._id then $ dom .remove! ; delete @items-doms[item._id]
    , observer-type = 'remove'

  after-render-item: (dom, item)!-> if item.is-new then $ @dom ?.prepend dom else $ @dom ?.append dom

  activate-clicking-operation-td-to-delete-data: !->
    self = @
    @dom.on 'click', '.operation.delete', (event)!-> 
      _id = $ @ .parents 'tr' .find "input[data-a-plus-bind='_id']" .text!
      first-column = $ @ .parents 'tr' .find 'td' [0]
      self.get-state!remove _id if confirm "删除 #{first-column.text!} ?"

  activate-clicking-tr-to-select-data: (event)!->
    self = @
    @dom.on 'click', 'tr', (event)!-> if not $ event.target .parents!has-class 'delete'
      _id = $ @ .find "input[data-a-plus-bind='_id']" .text!
      data-state = self.get-state!.get-element _id
      state.bind self.model-name, data-state

  appearance-state-changed-callback: !-> @enforce-permission!

  enforce-permission: !-> 
    if permissions-manager.should-operate-model @model-name, 'remove'
      @dom.find '.a-plus.operation.delete' .show!
    else
      @dom.find '.a-plus.operation.delete' .hide!



