define 'View-widget', ['Abstract-detail-widget', 'gridforms-creator', 'state'], (Abstract-detail-widget, gridforms-creator, state)-> class View-widget extends Abstract-detail-widget
  set-data-state: !->
    @data-state-name = _.singularize @model-name
    state.bind @data-state-name, null # 预留好state，数据到达时再行绑定（参考state.bind）


  bind-data: !-> 
    @form.d2f @data = @get-state!!
    @get-state!.observe (new-data)!~> @form.d2f @data = @get-state!! # TODO：add yellow-fade
    super ...

