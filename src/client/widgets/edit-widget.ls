define 'Edit-widget', ['Abstract-modify-widget', 'gridforms-creator', 'state'], (Abstract-modify-widget, gridforms-creator, state)-> class Edit-widget extends Abstract-modify-widget
  set-data-state: !->
    @data-state-name = _.singularize @model-name
    state.bind @data-state-name, null # 预留好state，数据到达时再行绑定（参考state.bind）

  bind-data: !-> 

    @data = @get-state!?!
    @update-dom-with-data!
    @get-state!.observe (new-data, old-data, options)!~> 
      @data = new-data
      if @is-state-updated-by-myself
        @is-state-updated-by-myself = false
      else 
        if not options?.local-change-auto-update 
          if confirm("update with new data? NOTE: current data will be lost! new data: #{JSON.stringify new-data}")
            @update-dom-with-data!
        else
          @update-dom-with-data!
    super ...

  update-dom-with-data: !->
    @fill-with-main-data!
    @fill-computed-data!

  fill-with-main-data: !->
    @form.d2f @data 
    @form.save-current!


  activate: !->
    super ...
    @activate-clicking-clear-button-to-reset-all-field!
    @activate-clicking-submit-button-to-submit-data!
    @activate-auto-recovery-data-when-reload!

  activate-clicking-clear-button-to-reset-all-field: !->
    $ @dom .on 'click', ".button.clear", !~> @form.reset!

  activate-clicking-submit-button-to-submit-data: !->
    $ @dom .on 'click', ".button.submit", !~> 
      if $ @form.form .parsley!validate!
        @is-state-updated-by-myself = true
        @get-state! @data = @form.f2d!
        @form.save-current!
      false # prevent default submission


