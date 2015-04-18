if Meteor.is-client
  @extend-from = (old-spec, new-spec)->
    result = $.extend deep = true, {}, old-spec
    $.extend deep = true, result, new-spec

  create-widget =
    type: 'create'
    label: '布置作业'
    model: 'assignment'
    appearance:
      type: 'gridforms'
      rows:
        ['题目(2)', '性别', '出题老师']
        ['给学生(2)', '截止时间', '已交总数']
        ['要求' 3]
      buttons: {positive: '发布', negative: '清除'} # 表单总有positive和negative按钮，其名称可以这样客户化定制。
    descriptions: # 可覆盖model中的定义
      placeholders:
        '出题老师': '请登录'

  edit-widget = @extend-from create-widget,
    type: 'edit'
    label: '修改作业安排与要求'
    appearance:
      buttons: {positive: '提交', negative: '放弃'}
    descriptions:
      placeholders:
        '出题老师': '-'

  view-widget = @extend-from edit-widget,
    type: 'view'
    label: '作业安排详情'

  list-widget =
    type: 'list'
    model: 'assignment'
    appearance:
      type: 'table.semantic-ui'
      columns: ['题目', '截止时间', '已交总数']

  student-list-widget = @extend-from list-widget,
    name: 'student-list-assignments' # 默认标准的widget（CLVE)不用给，将从model和type生成
    appearance:
      columns: ['题目', '截止时间', '分数': '@compute':
        observe: 'homeworks'
        get-value: -> (homeworks.findOne '题目': @_id)?['分数']]


define 'assignment-widgets-spec', [], -> assignment-widgets-spec = [
  create-widget, edit-widget, view-widget, list-widget, student-list-widget
]
