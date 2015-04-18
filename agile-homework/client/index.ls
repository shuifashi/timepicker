
require ['app-engine', 'app-spec', 'smart-form-manager', 'development-helper'], (app-engine, app-spec, smart-form-manager, development-helper)->
  Template.header.helpers {
    appState: -> Session.get 'b-plus-app-state' # 让Meteor可以用app-state。TODO：做更好的helper，让Meteor可以用所有的b-plus state
  }

  Meteor.startup ->
    is-dev = development-helper.start!
    console.log "b+ ready in ", (if is-dev then 'development model' else 'app model')
    if not is-dev
      app-engine.start!
      # form = $ "<form class='grid-form' id='create-assignment'></form>" .append app-engine.widgets['create-assignment'].dom
      # window.assignment-form = smart-form-manager.create form
      # $ 'body' .append form


      # table = app-engine.widgets['list-assignments'].dom
      # $ 'body' .append table


