define 'development-helper', ['app-engine', 'state', 'model-manager', 'meteor-transition'], (app-engine, state, model-manager, meteor-transition)->
  start: ->
    app-engine.initial!
    model-name = @get-development-model-name!
    if model-name 
      @load-development-page model-name
      is-dev = true
    else
      is-dev = false

  get-development-model-name: ->
    matches = window.location.pathname.match /^\/dev\/(.+)$/
    [_all_, model-name] = matches if matches
    @show-error-and-return-to-app model-name if model-name? and model-name not in Object.keys app-engine.models
    model-name

  show-error-and-return-to-app: (not-exist-model-name)!->
    $ 'body' .replace-with "Can't find #{not-exist-model-name}. We are heading to app in 3 seconds."
    set-timeout (!-> window.location.href = window.location.origin), 3000ms
    
  load-development-page: (model-name)!-> $ 'body' .replace-with @get-development-page model-name

  get-development-page: (model-name)->
    self = @
    dev-page = $ "<body></body>" .append container = $ "<div id='b-plus-#{model-name}-development-container'><h1> Development Page: #{model-name} </h1></div>" 
    @add-login-buttons container


    for let name, spec of app-engine.widgets-detail-specs when spec.model-name is model-name # and spec.type in ['view', 'list']

      refs = app-engine.models[model-name]['@refs']
      models-names = [model-name] ++ [_.singularize ref.state-name for ref in refs]
      meteor-transition.subscribe models-names, -> 
        # [self.set-random-model-data collection-name for collection-name in collections-names when collection-name isnt _.pluralize model-name]
        container.append $ " <h2> #{name} </h2>" 
        widget = app-engine.add-and-activate-widget name, container
        container.append " <hr/>"

    dev-page

  set-random-model-data: (collection-name)!->
    model-name = _.singularize collection-name
    collection-length = state[collection-name]!.length
    if collection-length
      random-index = Math.floor Math.random! * collection-length
      random-model-data = state[collection-name]![random-index] 
      data-state = state[collection-name].get-element random-model-data._id
      state.bind model-name, data-state


  add-login-buttons: (container)!->
    Blaze.render-with-data Template.loginButtons, align: 'right', container[0]