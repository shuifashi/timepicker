pub: (app-state)->
  user-id = this.user-id
  role-permission = role-manager.get-permission user-id, collection
  workflow-permission = workflow-manager.get-current-permission user-id, collection-name
  query = app-spec.states-data[app-state]
  execution-query = permission-manager.resolve collection, query, role-permission, workflow-permission

  collection.find execution-query