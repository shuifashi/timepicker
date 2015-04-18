# 职责：将meteor的collection adapt到a+中，实现其reactive与a+ state的reactive的对接
# 设计：其对外的接口和行为都与array-state保持一致
# TODO: refactor, 抽取出与array-state相同的逻辑，减少代码冗余
define 'meteor-mongo-collection-state', ['abstract-state', 'object-state', 'util'], (abstract-state, object-state, util)->
  class Meteor-collection-state extends abstract-state
    (name, collection)->
      @is-array = false
      @type = 'meteor-collection'
      @create-observable-collection collection
      super name

    create-observable-collection: (@collection)!->
      @elements-observers = {}
      @create-observable! # collection本身的observable
      @collection-observers = {}
      [@create-element-observer element for element in @collection.find!.fetch!]

      @add-observed-collection-operations!
      whole-collection-reset-observe = @fn.observe
      @fn.observe = (observer, observer-type = 'collection')~> # observer-type : add | remove | collection ; add, remove是collection元素的变化，collection是整个collection被set
        console.error "observer-type is wrong #{observer-type}" if observer-type not in ['add', 'remove', 'collection']
        if observer-type is 'collection'
          whole-collection-reset-observe ...
        else
          key = util.get-random-key!
          @collection-observers[observer-type] ||= {}
          @collection-observers[observer-type][key] = observer
          let key = key
            ~> delete @collection-observers[observer-type][key]

      @fn.get-element = (element-id)-> @state.elements-observers[element-id]

      @fn.clear = !-> throw new Error "meteor collection can only be clear (remove all) from meteor method call to server "

      @start-observing-collection-changes-on-server!


    get-value: -> @collection.find {} .fetch!

    set-value: (elements)->
      throw new Error "all elements of observable collection must have id." if not @every-element-has-id elements
      for _id, object-state of @elements-observers then @fn.remove _id, is-origin-change = true
      for element in elements then @fn.add element

    every-element-has-id: (elements)->
      for element in elements then return false if not element._id?
      return true

    create-element-observer: (element)~>
      is-need-to-create-on-server = not element._id? # _id是server端分配的，客户端新建时没有_id，需要在服务端创建。
      _id = element._id or util.get-random-key! 
      element-state = new object-state @name + _id
      element-observable = @elements-observers[_id] = element-state.fn
      element-observable element if not is-need-to-create-on-server # else 在服务端创建完成之后，再做次操作 
      @start-emiting-element-change-to-server element-observable
      element-observable

    add-observed-collection-operations: !->
      @add-observed-collection-add!
      @add-observed-collection-remove!

    add-observed-collection-add: !->
      @fn.add = (element, @is-origin-change = true, is-origin-change-caused-event = false)~>
        if @is-origin-change
          @add-element-on-server element
        else
          @create-element-observer element if not is-origin-change-caused-event # 避免本地add之后，又在added event中再添加

    add-element-on-server: (element, element-observable)->
      element-observable = @create-element-observer element
      @collection.insert element, (err, _id)!~>
        if err then console.log err else 
          @update-element-id element, element-observable, _id
          @run-collection-observers element, 'add'
      element-observable

    update-element-id : (element, element-observable, _id)->
      element-observable.state.name = @name + _id
      @elements-observers[_id] = element-observable
      delete @elements-observers[element._client-tmp-id] 

      element._id = _id
      delete element._client-tmp-id
      @is-server-change = true
      element-observable element

    start-emiting-element-change-to-server: (element-observable)!-> element-observable.observe (new-value, old-value)!~>
      if @is-server-change
        @is-server-change = false
      else
        @is-origin-change = true
        Meteor.call "update-#{@name}", new-value, (err, result)!~> console.log err if err

    run-collection-observers: (value, operation)!->
      # console.log "\n\n*************** run element observer for #{operation} ***************\n\n"
      observers = [observer for key, observer of @collection-observers[operation]] ++ [observer for key, observer of @observers]
      [observer value, operation for observer in observers when @should-run-observer observer]

    add-observed-collection-remove: !->
      @fn.remove = (element-or-id, @is-origin-change = true, is-origin-change-caused-event = false)~>
        console.log "fn.remove"
        _id = element-or-id?._id ? element-or-id
        if @is-origin-change
          @remove-element-on-server _id
        else
          delete @elements-observers[_id] if not is-origin-change-caused-event

    remove-element-on-server: (_id)->
      element-observable = @elements-observers[_id]
      @collection.remove {_id}, (err, removed-items-count)!~>
        if err then console.log err else
          @run-collection-observers element-observable!, 'remove'
          delete @elements-observers[_id]
      element-observable

    start-observing-collection-changes-on-server: !->
      @is-creating-observable-collection = true # 避免第一次query中的added事件
      @observe-collection-changes-on-server!
      set-timeout (!~> @is-creating-observable-collection = false), 0 # 开始真正监听

    observe-collection-changes-on-server: !->
      @server-change-observers?.stop?!
      @server-change-observers = @collection.find {} .observe {
        added: (element)!~> if not @is-creating-observable-collection # 避免第一次query中的added事件
          is-origin-change-caused-event =  @is-origin-change
          @is-origin-change = false
          @fn.add element, @is-origin-change, is-origin-change-caused-event
          @run-collection-observers element, 'add' if not is-origin-change-caused-event

        removed: (element)!~>
          is-origin-change-caused-event =  @is-origin-change
          @is-origin-change = false
          @fn.remove element, @is-origin-change, is-origin-change-caused-event
          @run-collection-observers element, 'remove' if not is-origin-change-caused-event

        changed: (new-element, old-element)!~>
          if @is-origin-change
            @is-origin-change = false
          else
            element-observable = @elements-observers[old-element._id]
            @is-server-change = true
            element-observable new-element

          if new-element._id isnt old-element._id
            @elements-observers[new-element._id] = element-observable
            delete @elements-observers[old-element._id]
      }

