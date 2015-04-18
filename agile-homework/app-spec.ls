# Agile Homework Specification for b+

define 'app-spec', ['assignment-widgets-spec', 'homework-widgets-spec', 'permissions-spec', 'state', 'helpers'], (assignment-widgets-spec, homework-widgets-spec, permissions-spec, state, h)->
  spec =
    name: 'Agile Homework'
    roles: ['student', 'teacher', 'supspended.student']

    permissions: permissions-spec

    models:
      '@default': '@valid': {required: true}
      assignment:
        '题目': '@valid': {min: 5, max: 30}
        '出题老师': h.add-as-current-user-at-creation
        '给学生':
          '@ref': 'user.username'
          '@multi': [1, 5]
        '截止时间':
          '@type': 'time'# TODO：@after-today
          '@lang': 'en'
          '@step': 60
          '@timepicker': true
          '@datepicker': true
          '@theme': 'default'
          '@startdate': false
        '已交总数':
          '@compute':
            observe: 'homeworks'
            get-value: -> homeworks?.find '题目': @_id .count!
        '要求': '@type': 'text'
        # '某个数':
        #   '@type': 'number'
        #   '@min': 1
        #   '@max': 100
        #   '@step': 3
        '性别':
          '@type': 'checkbox'
          '@values': <[男 女(default) 其他(input)]>
          '@multi': [1, 2]

      homework:
        '题目': h.find-or-select 'assignment', '题目', is-associated = false # 主选择 '@ref': 'assignment.题目'
        '老师': h.find-or-select 'assignment', '出题老师' # 附属选择 FEATURE：cascade relationship
        '截止时间': h.find-or-select 'assignment', '截止时间'
        '要求': h.find-or-select 'assignment', '要求'
        '学生': h.add-as-current-user-at-creation
        '分数': '@valid': {required: false}
        '内容':  '@type': 'text'

    descriptions:
      assignment:
        placeholders:
          '题目': '作业的题目，不超过30字'
          '要求': '作业详细要求'
        label:
          '题目': 'title'

      homework:
        placeholders:
          '内容': '写作业...'

    transformers:
      assignment:
        '截止时间': (end-time, dom)-> moment end-time .from-now!

    widgets: assignment-widgets-spec ++ homework-widgets-spec

    runtime:
      states: [
        'splash',
        'teacher.assignments-list', 'teacher.score-homework'
        'student.assignments-list', 'student.do-homework'
      ]

      states-widgets:
        'teacher.score-homework': ['list-homeworks', 'edit-homework']
        'student.assignments-list': ['student-list-assignments']
        'student.do-homework': ['create-homework', 'edit-homework']

      states-data: # TODO: 从model中推断默认的设置
        'teacher.assignments-list': 'user': null, 'assignment': null, 'homework': null
        'teacher.score-homework': 'user': null, 'assignment': null, 'homework': -> '题目': state.assignment!_id
        'student.assignments-list':
          'user': null
          'assignment': -> '给学生': Meteor.user-id!
          'homework': -> '学生': Meteor.user-id!
        'student.do-homework':
          'user': null
          'assignment': -> _id: state.assignment!_id
          'homework': -> $and: [{'题目': state.assignment!_id}, {'学生': Meteor.user-id!}]

      transitions:
        'splash  ->  teacher.assignments-list'   :   '@+:auto'    :   delay: 2000ms , condition: -> Roles.user-is-in-role Meteor.user!, 'teacher'
        'splash  ->  student.assignments-list'   :   '@+:auto'    :   delay: 2000ms , condition: -> !Roles.user-is-in-role Meteor.user!, 'teacher'
        'teacher.assignments-list -> teacher.score-homework'      :   'click' : hot-area: {selector : 'tr.assignment'} , condition: (event)-> not $ @event.target .parents!has-class 'delete'
        'student.assignments-list -> student.do-homework'         :   'click' : hot-area: {selector : 'tr.assignment'} , after :  !~> h.show-edit-widget-when-has-an-item-otherwise-show-create-widget 'homework'
        'student.do-homework -> student.assignments-list'         :   'click' : hot-area: {selector : '.button.submit'}


      initial-state: 'splash'





