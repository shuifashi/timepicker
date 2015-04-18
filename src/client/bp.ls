Template.bp.helpers {
  test: -> 
    # console.log @

} 

Template.bp.on-rendered ->
  # console.log @data
  b-plus-app-engine.add-and-activate-widget @data.widget, ($ @.first-node), is-include-by-template = true 