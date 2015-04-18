define 'fake-data-loader', ['fake-data', 'app-spec'], (fake, app-spec)->
  load: ->
    console.log "loading fake data ...."
    for data-name, data of fake
      if data-name is 'users'
        @load-users data
      # else
      #   @load-data data-name, data if data-name in Object.keys _.pluralize app-spec.models

  load-users: (users)!-> [@load-user user for user in users]

  load-user: (user)!->
    user-already-exists = (typeof Meteor.users.find-one username: user.username) is 'object'
    if not user-already-exists
      id = Accounts.create-user user 
      Roles.add-users-to-roles id, user.roles if user.roles?.length > 0

  load-data: (collection-name, data)->
    collection = eval collection-name
    collection.remove {}
    [collection.insert item for item in data]
