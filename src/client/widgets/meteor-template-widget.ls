define 'Meteor-template-widget', ['Abstract-widget'], (Abstract-widget)-> class Meteor-template-widget extends Abstract-widget
  
  create-dom: !-> @dom = $ @spec.dom

  bind-data: !->

  initial-dom: !-> # 注意：Meteor-template-widget形成的dom结构，只有一层外包，widget-container、dom合并成为了一层。这样不会改变Meteor渲染后的dom结构，否则会使得一些js不工作。与之相比，model widget有三层，wrapper、container和dom。因为，我们通过Meteor的template来引入b+的widget，需要1）bp template的内容，2）原有的2层（TODO：这里可以考虑重构Widget的结构和生产）
    @create-dom!
    @widget-container = @dom
    @dom.attr 'data-b-plus-widget', @name
    @dom.attr 'data-b-plus-widget-container', ''
    # @dom.replace-with @widget-container
    # @widget-container.append @dom
    @change-widget-container-class-when-state-changed!
    @hide-dom-when-state-change-to-hidden!
