define 'Create-widget', ['Abstract-modify-widget', 'gridforms-creator', 'permissions-manager'], (Abstract-modify-widget, gridforms-creator, permissions-manager)-> class Create-widget extends Abstract-modify-widget
  set-data-state: !->
    @data-state-name = _.pluralize @model-name

  activate: !-> 
    super ...
    @activate-clicking-clear-button-to-clear-all-field!
    @activate-clicking-submit-button-to-submit-data!
    @activate-auto-recovery-data-when-reload!

  activate-clicking-clear-button-to-clear-all-field: !->
    $ @dom .on 'click', " .button.clear", !~> @form.clear!

  activate-clicking-submit-button-to-submit-data: !->
    $ @dom .on 'click', " .button.submit", !~> permissions-manager.operation-permission-check 'create', @model-name, !~>
      if $ @dom .parsley!validate!
        @get-state!add @data = @form.f2d!
        @form.clear!
      false # prevent default submission

