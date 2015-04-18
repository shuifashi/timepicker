# 注意：2015-03-20 开发时用的b-plus-deve-page-data和@subscribe方法通过测试，但是！app-engine中将要使用的prepare-data尚未测试。

root = exports ? @
define 'meteor-transition', ['transition', 'model-manager', 'util', 'data-publisher', 'permissions-manager'], (Transition, model-manager, util, data-publisher, permissions-manager)-> class meteor-transition extends Transition
  @transitions = []
  @subscriptions = {}

  @subscribe = (models-names, done)!-> # development-helper用来订阅数据
    waiter = new util.All-done-waiter done
    for let name in models-names
      @subscriptions[name] = Meteor.subscribe name, '__dev__', waiter.add-waiting-function!
  

  (transition-spec, history, @states-data-mapping)-> 
    throw new Error "meteor-transition should be runing within Meteor" if not Meteor
    @@@transitions.push @
    transition-spec.cause = 'meteor' if Meteor.is-server # server端变成meteor事件
    @prepare-data transition-spec.spec
    super transition-spec, history, states-data-mapping
    @enforce-permissions!
    @data-config = @states-data-mapping?[@to]

  prepare-data: (spec)!->
    if spec.after? 
      spec.after = spec.after.decorate {before: (done)!~> @subscribe done, is-before-async: true} 
    else 
      spec.after = (done)!~> @subscribe done
    spec.after.is-async = true
    
    if spec.action? then spec.action.decorate after: !~> @unsubscribe! else spec.action = !~> @unsubscribe!

  subscribe: (done = ->)!-> 
    done! if not @data-config?
    waiter = new util.All-done-waiter done
    for own let model-name, query of @data-config
      @@@subscriptions[model-name] = Meteor.subscribe model-name, @to, query?!, waiter.add-waiting-function!
  
  unsubscribe: !-> 
    [subscription.stop! for model-name, subscription of @@@subscriptions]
    @@@subscriptions = {}

  enforce-permissions: !->
    if old-condition = @condition
      @condition = -> (permissions-manager.is-permit-to-app-state @to) and old-condition ...

