define 'data-publisher', ['permissions-manager'], (permissions-manager)->

  start-pub-data: (app-spec)-> 
    self = @
    for own let model-name, spec of app-spec.models
      collection-name = _.pluralize model-name
      collection = root[collection-name]
      Meteor.publish model-name, (app-state, query)-> self.pub.call @, app-spec, app-state, collection, model-name, query, self # 此方法会在browser Meteor.subscribe的时候被调用
    
    Meteor.publish 'user', (app-state)-> self.pub.call @, app-spec, app-state, Meteor.users, 'user', null, self# 用户信息
    
  pub: (app-spec, app-state, collection, model-name, query, self)->
    # debugger
    # console.log "b-plus-app-page at app-state: '#{app-state}', subscribe: ", model-name
    # role-permission = role-manager.get-permission user-id, collection
    # workflow-permission = workflow-manager.get-current-permission user-id, collection-name
    user = Meteor.users.find-one _id: @user-id
    [query, fields] = self.enforce-permissions query, user, model-name, app-state
    console.log "pub data: #{model-name} for app-state: #{app-state} with query: #{JSON.stringify query}, and fields: ", fields
    # execution-query = permission-manager.resolve collection, query, role-permission, workflow-permission
    if query
      if fields then collection.find query, fields else collection.find query

  enforce-permissions: (query, user, model-name, app-state)->
    query = @get-query query, user, model-name, app-state
    fields = @get-fields user, model-name, app-state
    [query, fields]

  get-query: (query, user, model-name, app-state)-> 
    query ||= {}
    return {} if app-state is '__dev__'  # in dev mode publish all data
    if permissions-manager.is-user-permit-viewing-model model-name, app-state, user then query else null

  get-fields: (user, model-name, app-state)->
    fields = permissions-manager.get-restricted-viewing-fields model-name, app-state, user
    if fields then fields: {[field, 0] for field in fields} else null 


