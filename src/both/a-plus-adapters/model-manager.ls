root = exports ? @

always-allow = -> true

cascade-find-by-id = (_id, cascade-refs)->
  # console.log "_id: #{_id}, cascade-refs: ", cascade-refs
  {state-name, attrs}  = cascade-refs.shift!
  attr = attrs[1]
  collection = if state-name is 'users' then Meteor.users else root[state-name]
  # debugger
  ref-obj = collection.find {_id} .fetch!0
  if cascade-refs.length is 0
    return ref-obj[attr]
  else
    cascade-find-by-id ref-obj[attr], cascade-refs
    


Meteor.methods {
  'get-cascade-refs-value': (_id, cascade-refs)-> cascade-find-by-id _id, cascade-refs if Meteor.is-server
}

# debugger
define 'model-manager', ['meteor-mongo-collection-state', 'state'], (Meteor-mongo-collection-state, State)->

  create-models: (models)!-> 
    [@create-mongo-collection-and-make-it-a-a-plus-state model for model in Object.keys models when (model.index-of '@') isnt 0] # @开头的不是model，是directive，例如：@default
    @make-collection-a-plus-state Meteor.users if Meteor.is-client

  create-mongo-collection-and-make-it-a-a-plus-state: (model)!->
    collection-name = _.pluralize model
    root[collection-name] = collection = new Mongo.Collection collection-name
    @set-permission collection
    @add-methods collection
    @make-collection-a-plus-state collection if Meteor.is-client
    # @publish-collection collection if Meteor.is-server

  set-permission: (collection)!-> # TODO：未来可以扩展这里，从model-spec中读入permission。
    collection.allow insert: always-allow, update: always-allow, remove: always-allow, fetch: null

  add-methods: (collection)!->
    @add-update-method collection # Meteor中限制collection的update方法，在client端不能直接update整个document，必须用mongo的$set operator。故而，提供Method，以便在meteor-mongo-collection-state中update。
    @add-other-methods collection

  add-update-method: (collection)!-> Meteor.methods {
    "update-#{collection._name}": (new-document)->
      collection.update {_id: new-document._id}, new-document
  }

  add-other-methods: (collection)!-> # TODO：未来从model-spec中读入、添加。

  make-collection-a-plus-state: (collection)!->
    state = new Meteor-mongo-collection-state collection._name, collection
    State[state.name.camelize!] = state.fn # state都是fn

  publish-collection: (collection)!->
    # console.log "published: ", collection._name
    Meteor.publish collection._name, ->
      # console.log "start subscribe ", collection
      collection.find!

