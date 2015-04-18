if Meteor.is-client
  @extend-from = (old-spec, new-spec)->
    result = $.extend deep = true, {}, old-spec
    $.extend deep = true, result, new-spec

  create-widget =
    type: 'create'
    label: '写作业'
    model: 'homework'
    appearance:
      type: 'gridforms'
      rows:
        ['题目(3)', '截止时间', '老师']
        ['学生', '分数']
        ['要求' 3]
        ['内容' 5]
      buttons: {positive: '提交', negative: '清除'} # 表单总有positive和negative按钮，其名称可以这样客户化定制。

  edit-widget = @extend-from create-widget, 
    type: 'edit'
    label: '更新作业'

  view-widget = @extend-from edit-widget,
    type: 'view'
    label: '作业详情'

  list-widget =
    type: 'list'
    model: 'homework'
    appearance:
      type: 'table.semantic-ui'
      columns: ['题目', '截止时间', '老师', '学生', '分数'] # TODO：已交总数？

define 'homework-widgets-spec', [], -> homework-widgets-spec = [
  create-widget, edit-widget, view-widget, list-widget 
]
