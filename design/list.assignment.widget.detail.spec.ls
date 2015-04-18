spec = ->
    'name': 'list-assignments'
    'model-name': 'assignment' 
    'data': ['assignments'] # 从app-spec的state-data来
    'type': 'list'
    'item-template-name': 'assignment-template'
    'label': '布置作业' # 默认值 Create Assignment
    columns:
      * class: ''
        name: '题目'
        bind: 'title'
      * name: '截止时间'
        bind: 'restrictions.end-time'
      * name: '已交作业数'
        bind: 'submits-amount'
      * name: '操作'
        type: 'action'


if define? # a+运行时
  define 'spec', [], spec 
else # 独立运行
  root = module?.exports ? @
  root.spec = spec!


