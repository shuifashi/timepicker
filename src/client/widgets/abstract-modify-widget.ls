define 'Abstract-modify-widget', ['Abstract-detail-widget', 'permissions-manager', 'state'], (Abstract-detail-widget, permissions-manager, state)-> class Abstract-modify-widget extends Abstract-detail-widget

  activate: !-> 
    super ...
    @activate-form-validation!
    @activate-auto-recovery-data-when-reload!

  activate-form-validation: !-> @dom.parsley!

  activate-auto-recovery-data-when-reload: !-> # TODO

  set-field-appearance: (field, attr-path)!-> # TODO: 如果此处效率影响用户体验，可以和super中的方法合并调用permissions-manager一次，以提高效率
    super ...
    element = $ field .find '[name]'
    @on-off-element element, permissions-manager.should-edit-field @model-name, attr-path

  on-off-element: (element, is-on)!-> 
    tagName = $ element .prop 'tagName' .to-lower-case!
    switch tagName
    | 'select'    =>  (selectizer = $ element .selectize!0.selectize ; if is-on then selectizer.enable! else selectizer.disable!)
    | 'input'     =>  $ element .prop 'disabled', if is-on then false else true
