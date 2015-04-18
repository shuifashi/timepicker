define 'permissions-spec', [], ->
  data:
    assignment:
      denies:
        * 'student #edit, remove, create'
        ...

    homework:
      denies:
        * 'paused.student #create'
        * 'student #edit @截止时间, 老师, 分数, 要求'
        * 'student #know @学生'

  app-state:
    denies:
      * 'supspended.student @student.do-homework'
      ...