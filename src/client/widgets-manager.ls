define 'widgets-manager', ['Create-widget', 'List-widget', 'Edit-widget', 'View-widget', 'Meteor-template-widget'], (Create-widget, List-widget, Edit-widget, View-widget, Meteor-template-widget)-> widgets-manager =

  widgets: {} # widgets registry

  create: (spec, model, is-include-by-template)-> 
      widget = @_create spec, model, is-include-by-template
      @widgets[widget.name] = widget

  _create: (spec, model, is-include-by-template)-> 
    widget = switch spec.type
    | 'create'  =>  new Create-widget spec, model, is-include-by-template 
    | 'edit'    =>  new Edit-widget spec, model, is-include-by-template 
    | 'view'    =>  new View-widget spec, model, is-include-by-template 
    | 'list'    =>  new List-widget spec, model, is-include-by-template 
    | 'meteor'  =>  new Meteor-template-widget spec, model, is-include-by-template 
    | otherwise =>  throw new Error "#{spec.type} widget is not implemented"  


  is-bp-managed-meteor-template: (name, template)-> template?.view-name and (name.substr 0, 1) isnt '_' and name isnt 'body'

  is-b-plus-template-widget: (template)-> ((template.$ template.first-node)?.attr 'data-b-plus-template-widget')?

  create-meteor-jade-templates-as-b-plus-widgets: -> 
    self = @
    for own name, template of Template when self.is-bp-managed-meteor-template name, template
      let name = name
        template.on-rendered -> if self.is-b-plus-template-widget @
          # console.log "#{name} @$ @: ", @$ @
          widgets-manager.create spec = type: 'meteor', name: name, dom: $ @.first-node