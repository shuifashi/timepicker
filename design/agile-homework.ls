# Agile Homework Specification for b+

# ----------- DSL Helpers -------------
@add-as-current-user-at-creation =
  '@ref': 'user.username'
  '@initial': -> Meteor.user-id!
  '@disabled': true

@extend-from = (old-spec, new-spec)->
  result = $.extends deep = true, {}, old-spec
  $.extends deep = true, result, new-spec

agile-homework = ->
  name: 'Agile Homework'
  roles: ['student', 'teacher']

  models:
    assignment:
      '题目': '@valid': {required: true, max: 30}
      '出题老师': @add-as-current-user-at-creation
      '给学生': 
        '@ref': 'user.username'
        '@multi': [1, 5]
      '截止时间': null # TODO：@after-today
      '已交总数': null # TODO: @count-on-homeworks @ref @compute: ->
      '要求': '@type': 'text'

  descriptions:
    assignment:
      placeholders:
        '题目': '作业的题目，不超过30字'
        '要求': '作业详细要求'

  transformers: 
    assignment:
      '截止时间': (end-time, dom)-> moment end-time .from-now!


  widgets:





