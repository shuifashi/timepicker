root = exports ? @

app-engine = (state, app-spec, state-machine, Meteor-transition, util, model-manager, data-publisher, permissions-manager, model-parser, descriptions-parser, widget-detail-spec-generator, widgets-manager)-> 
  # 此时在app中写的jade template已经加载，但尚未实例化。必须在此时调用widgets-manager.create-meteor-jade-templates-as-b-plus-widgets
  # 让template实例的dom，转变为b-plus widget，可以随app-state变化状态。
  # 早于此，写就的jade template尚未加载，无法通过Template.xxx 访问，也就无法为其添加on-rendered方法，在其中将其dom变为b-plus widget。
  # 晚于此，jade template已经完成render，再添加的on-rendered的方法不会被调用，也同样无法将Template.xxx的dom变为b-plus widget。
  widgets-manager.create-meteor-jade-templates-as-b-plus-widgets! if Meteor.is-client

  root.b-plus-app-engine =
    app-spec: app-spec
    widgets: widgets-manager?.widgets

    start: !->
      @initial!
      if Meteor.is-client
        @add-and-active-all-model-widgets-to-page! 
        state-machine.enable-back-navigation!
        @app-state-machine.start @app-spec.runtime.initial-state if @app-spec.runtime # 渐进式开发，不要求一开始就定义app-state-machine
        @initial-all-third-party-controls-when-app-state-change!

    initial: !-> if not @models
      @models = {}
      @descriptions = {}
      @widgets-detail-specs = {}
      @permission-denies = permissions-manager.parse @app-spec.permissions
      console.log "permissions-denies: ", @permission-denies
      model-manager.create-models @app-spec.models
      if Meteor.is-client
        @create-app-state-machine! if @app-spec.runtime # 渐进式开发，不要求一开始就定义app-state-machine
        @prepare-widgets-detail-spec! 
      else
        data-publisher.start-pub-data @app-spec

    create-app-state-machine: !-> 
      @app-state-machine = new state-machine "app-state": @app-spec.runtime.states 
      @app-state-machine.add-transitions spec: @app-spec.runtime.transitions, Meteor-transition, @app-spec.runtime.states-data
      @app-state-machine.state.observe (app-state)-> Session.set 'b-plus-app-state', app-state if Meteor.is-client

    prepare-widgets-detail-spec: !->
      @parse-models!
      @parse-descriptions!
      @parse-transformers!
      @generate-wigets-detail-specs!
      @widgets

    parse-models: !->
      model-parser.defaults = [model-parser.parse-default @app-spec.models['@default']] if @app-spec.models['@default']
      [@models[name] = model-parser.parse name, model for name, model of @app-spec.models when name isnt '@default']

    parse-transformers: !-> @parse-runtime-aspect-and-store-on-corresponding-model 'transformer'

    parse-runtime-aspect-and-store-on-corresponding-model: (aspect)!->
      @[_.pluralize aspect] = {}
      util.visit-leaf @app-spec.[_.pluralize aspect], (value, path)!~> 
        model-spec-obj = @find-model-spec-obj path
        model-spec-obj[aspect] = value if model-spec-obj

    find-model-spec-obj: (path)->
      [model-name, label-or-key] = path.split '.'
      if model = @models[model-name]
        key = @descriptions[model-name].get-path-key label-or-key
        [return spec for own attr, spec of model when attr is key]

    parse-descriptions: !->
      [@descriptions[model-name] = descriptions-parser.parse @models[model-name], descriptions for model-name, descriptions of @app-spec.descriptions]

    generate-wigets-detail-specs: !->
      for spec in @app-spec.widgets
        # spec = @extends-spec spec if spec['@extends']
        model = @models[spec.model] ; model-descriptions = @descriptions[spec.model]
        descriptions = descriptions-parser.parse model, spec.descriptions, model-descriptions
        widget-detail-spec = widget-detail-spec-generator.generate spec, model, descriptions, @app-spec.runtime
        @widgets-detail-specs[widget-detail-spec.name] = widget-detail-spec

    add-and-active-all-model-widgets-to-page: !->
      $ 'body' .append container = $ "<div id='b-plus-model-widgets-container'></div>"
      [@add-and-activate-widget widget-name, container for own widget-name, spec of @widgets-detail-specs]

    add-and-activate-widget: (widget-name, container, is-include-by-template = false)!->
      detail-spec = @widgets-detail-specs[widget-name]
      model-name = detail-spec.model-name
      widget = widgets-manager.create @widgets-detail-specs[widget-name], @models[model-name], is-include-by-template
      container.append widget.widget-container
      widget.activate!

    initial-all-third-party-controls-when-app-state-change: !-> state.app-state.observe !->
      GridForms.equalize-field-heights! 

if window? # client side
  define 'app-engine', ['state', 'app-spec', 'state-machine', 'meteor-transition' 'util', 'model-manager', 'data-publisher', 'permissions-manager', 'model-parser', 'descriptions-parser', 'widget-detail-spec-generator', 'widgets-manager'], app-engine 
else # server side
  define 'app-engine', ['state', 'app-spec', 'state-machine', 'meteor-transition' 'util', 'model-manager', 'data-publisher', 'permissions-manager'], app-engine   


