define 'permissions-manager', ['permissions-parser', 'state'], (permissions-parser, state)->
  denies: data-denies: {}, app-state-denies: {}, workflow-denies: {}

  parse: (spec)-> 
    @shall-we-control-permissions = spec? 
    permissions-parser.parse spec, @denies
 
  is-user-permit-viewing-model: (model-name, app-state, user)->
    @if-any-role-permit (@is-role-permit-viewing-model model-name, app-state), user

  if-any-role-permit: (role-premit-checker, user)->
    return true if not @shall-we-control-permissions # 如果没有定义permssion，则不进行permissions控制！
    user ||= Meteor.user! if Meteor.is-client
    roles = @get-roles user
    for role in roles
      if @is-sub-role role # 形如male.suspended.student，有两个parents: suspended.student，和student，只有this-and-all-parent都permit，才permit
        return true if @this-and-all-parents-roles-permit role, role-premit-checker
      else
        return true if role-premit-checker @, role
    false

  is-sub-role: (role)-> (role.index-of '.') > 0

  this-and-all-parents-roles-permit: (role, role-premit-checker)->
    roles = @get-this-and-all-parents-roles role
    [return false for role in roles when not role-premit-checker @, role]
    true

  get-this-and-all-parents-roles: (role)-> # 形如male.suspended.student， 返回[student, suspended.student, male.suspended.student]
    tokens = role.trim!split '.' .reverse!
    roles = []
    [tokens[0 to i].reverse!join '.' for token, i in tokens]

  get-roles: (user)->
    roles = ['anonym']
    roles = roles.concat user.roles if user?
    roles

  is-role-permit-viewing-model: (model-name, app-state, self, role)-->
    return false if role is 'anonym'
    return true if not self.denies.data-denies[role]?[model-name]?['@']?
    if 'view' in self.denies.data-denies[role]?[model-name]?['@'] then false else true

  get-restricted-viewing-fields: (model-name, app-state, user)-> if not user? then null else
    _.intersection.apply null, [@get-restricted-viewing-fields-of-role role, model-name, app-state for role in user.roles]
    
  get-restricted-viewing-fields-of-role: (role, model-name, app-state)->
    [attr for own attr, denies of @denies.data-denies[role]?[model-name] when attr isnt '@' and 'view' in denies]

  should-show-field: (model-name, attr-path)->
    @if-any-role-permit @should-show-field-for-role model-name, attr-path

  should-show-field-for-role: (model-name, attr-path, self, role)-->
    return false if role is 'anonym'
    return false if self.denies.data-denies[role]?[model-name]?['@']? and 'view' in self.denies.data-denies[role]?[model-name]?['@']
    if self.denies.data-denies[role]?[model-name]?[attr-path]? and 'know' in self.denies.data-denies[role]?[model-name]?[attr-path] then false else true

  should-edit-field: (model-name, attr-path)->
    @if-any-role-permit @should-edit-field-for-role model-name, attr-path

  should-edit-field-for-role: (model-name, attr-path, self, role)-->
    return false if role is 'anonym'
    return false if self.denies.data-denies[role]?[model-name]?['@']? and 'edit' in self.denies.data-denies[role]?[model-name]?['@']
    if self.denies.data-denies[role]?[model-name]?[attr-path]? and 'edit' in self.denies.data-denies[role]?[model-name]?[attr-path] then false else true

  should-operate-model: (model-name, operation-name)->
    @if-any-role-permit @should-operate-model-for-role model-name, operation-name

  should-operate-model-for-role: (model-name, operation-name, self, role)-->
    return false if role is 'anonym'
    return true if not self.denies.data-denies[role]?[model-name]?['@']?
    if operation-name in self.denies.data-denies[role]?[model-name]?['@'] then false else true

  is-permit-to-app-state: (app-state)->
    @if-any-role-permit @is-permit-to-app-state-for-role app-state

  is-permit-to-app-state-for-role: (app-state, self, role)-->
    if role is 'anonym'
      if app-state in ['splash', 'login'] then true else false
    else
      return false if self.denies.app-state-denies[role]? and app-state in self.denies.app-state-denies[role]
      true

  operation-permission-check: (operation-name, model-name, operation)->
    if @should-operate-model model-name, operation-name
      operation!
    else
      alert "当前用户被限制操作，请联系系统管理员。"
