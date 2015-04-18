# ------------------ permissions design ---------------- #
# ---------- unpased permissions spec -------------
spec =
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
# ---------- parsed permission-denies -------------
permission-denies = 
  dataDenies: 
    student: 
      assignment: '@': ['edit', 'remove', 'create']
      homework: 
        '截止时间': ['edit']
        '老师': ['edit']
        '分数': ['edit']
        '要求': ['edit']
        '学生': ['know', 'view', 'edit']

    'paused.student': homework: '@': ['create']
  
  appStateDenies: 'supspended.student': ['student.do-homework']
  # workflowDenies: 
# ------------------ permissions design end ---------------- #

DELEMITER = ','
define 'permissions-parser', [], ->
  parse: (spec, @denies)-> if spec
       # debugger
    @parse-data-denies spec.data
    @parse-app-state-denies spec.app-state
    @denies

  parse-data-denies: (data-denies)!->
    [@parse-model-denies model-name, denies.denies for own model-name, denies of data-denies]

  parse-model-denies: (model-name, denies)!->
    [@parse-data-deny-rule model-name, deny for deny in denies]

  parse-data-deny-rule: (model-name, rule)!-> 
    [__all__, roles, levels, __att-paths__, attr-paths] = rule.match /(.+\S)\s*#([^@]+[^@\s])\s*(@(.+\S)){0,1}/
    [@add-data-deny-rule-for-role role.trim!, model-name, attr-paths, levels for role in roles.split DELEMITER]

  add-data-deny-rule-for-role: (role, model-name, attr-paths, levels)->
    @denies.data-denies[role] ||= {}  
    model-denies = @denies.data-denies[role][model-name] ||= {}
    if attr-paths 
      [@add-deny-rule-for-attr model-denies, attr-path.trim!, levels for attr-path in attr-paths.split DELEMITER]
    else
      [@add-model-deny model-denies, level.trim! for level in levels.split DELEMITER]

  add-deny-rule-for-attr: (model-denies, attr-path, levels)->
    [@add-attr-deny model-denies, attr-path, level.trim! for level in levels.split DELEMITER]

  add-attr-deny: (model-denies, attr-path, level)!->
    current = model-denies[attr-path] ||= []
    model-denies[attr-path] = _.union current, @get-attr-denies-for-level level

  get-attr-denies-for-level: (level)->
    switch level
    | 'know'    => ['know', 'view', 'edit']
    | 'view'    => ['view', 'edit']
    | 'edit'    => ['edit']

  add-model-deny: (model-denies, level)!->
    current = model-denies['@'] ||= [] # rule中没有attr-path（@xxx）时，对应整个model，标记为“@”
    model-denies['@'] = _.union current, @get-model-denies-for-level level

  get-model-denies-for-level: (level)->
    switch level
    | 'list'      => ['list', 'view', 'edit']
    | 'view'      => ['view', 'edit']
    | 'edit'      => ['edit']
    | 'create'    => ['create']
    | 'remove'    => ['remove']

  parse-app-state-denies: (app-state-denies)!->
    [@parse-app-state-deny-rule rule for rule in app-state-denies.denies]

  parse-app-state-deny-rule: (rule)!->
    console.log "rule: ", rule
    [__all__, roles, app-states] = rule.match /(.+\S)\s*@(.+\S)/
    [@add-deny-app-states role.trim!, app-states for role in roles.split DELEMITER]

  add-deny-app-states: (role, app-states)!->
    [@add-deny-app-state role, app-state.trim! for app-state in app-states.split DELEMITER]

  add-deny-app-state: (role, app-state)!->
    denies = @denies.app-state-denies[role] ||= []
    @denies.app-state-denies[role] = _.union denies, [app-state]
