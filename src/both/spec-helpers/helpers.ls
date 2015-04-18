define 'helpers', ['state'], (state)->

  # --------------------- model helpers --------------------- #
  add-as-current-user-at-creation: 
    '@ref': 'user.username'
    '@initial': -> Meteor.user-id!
    '@disabled': true 

  # 当前环境有model时，取其值，并不可更改。否则，根据主选择的选择更改
  find-or-select: (model-name, attr, is-associated = true)->
    '@ref': "#{model-name}.#{attr}"
    '@disabled': is-associated
    '@initial': (selectizer)!~> 
      @set-as-select-or-associate-select model-name, selectizer, is-associated

  set-as-select-or-associate-select: (model-name, selectizer, is-associated)->
    if is-associated
      state.bind model-name, null if not state[model-name]?
      state[model-name].observe (model)!~> selectizer['@set-value'] model._id
    else
      collection-name = _.pluralize model-name
      selectizer.on 'change', (_id)!~> state.bind model-name, state[collection-name].get-element _id

  set-and-then-disable-when-model-present: (model-name, selectizer)-> if model = state[model-name]?!
    selectizer.disable!
    model._id # intial返回的值会被set-value

  # --------------------- state-machine helpers --------------------- #
  extend-widget: (old-spec, new-spec)->
    result = $.extend deep = true, {}, old-spec
    $.extend deep = true, result, new-spec

  # --------------------- state-machine helpers --------------------- #

  show-edit-widget-when-has-an-item-otherwise-show-create-widget: (model-name)!-> 
    model = state[model-name]
    collection = state[_.pluralize model-name]
    create-widget-state = state["a-plus-widgets-create-#{model-name}".camelize!]
    edit-widget-state = state["a-plus-widgets-edit-#{model-name}".camelize!]
    Meteor.defer !-> Meteor.defer !-> # 等待数据sub完成后
      if collection!length > 0
        create-widget-state 'hidden' ; edit-widget-state 'normal'
        state.bind model-name, collection.get-element collection![0]._id # 抽象出API
      else
        create-widget-state 'normal' ; edit-widget-state 'hidden'