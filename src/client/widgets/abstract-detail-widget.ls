define 'Abstract-detail-widget', ['Abstract-widget', 'gridforms-creator', 'smart-form-manager', 'state', 'permissions-manager'], (Abstract-widget, gridforms-creator, smart-form-manager, state, permissions-manager)-> class Abstract-detail-widget extends Abstract-widget

  create-dom: !-> 
    @dom = gridforms-creator.create @spec
    @create-smart-form! 

  create-smart-form: !->
    # @form: 1) 用户可点击加、减表单的行(s); 2) f2d，d2f方法，萃取form数据、将数据填充到表单中; 3) save-current和reset方法，保存和恢复表单状态
    @form = smart-form-manager.create @dom, @spec.type, reactivate = (new-dom)!~> # form在操作时有时会更换dom，更换之后需要重新添加行为。
      @dom = new-dom
      @activate!
    @activate-behaviors-specified-in-app-spec!
    @form.activate!

  apply-computation: (name, computation)!->
    $ "[name='#{name}']" .val computation.get-value.apply @data

  activate-behaviors-specified-in-app-spec: !->
    @form.spec-behaviors = @spec.behaviors 

  appearance-state-changed-callback: !-> @enforce-permission!

  enforce-permission: !-> @get-all-fields (field, attr-path)!~> @set-field-appearance field, attr-path

  set-field-appearance: (field, attr-path)!-> 
    if permissions-manager.should-show-field @model-name, attr-path
      $ field .show!
    else
      $ field .hide!

  get-all-fields: (callback)!-> $ '[data-field-span]' .has '[name]' .each !->
    attr-path = $ @ .find '[name]' .attr 'name'
    callback @, attr-path