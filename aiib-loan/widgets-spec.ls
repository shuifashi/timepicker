get-widgets-specs = (h)->
  (get-application-widgets-specs h) ++ (get-audit-widgets-specs h)

get-application-widgets-specs = (h)->
  create-application = type: 'create', label: '申请贷款', model: 'application', appearance:
    type: 'gridforms'
    sections:
      贷款申请:
        ['申请金额', '贷款期限']
        ['利率调整方式', '还款方式', '平安守护', '贷款用途']
      申请人:
        ['姓名(2)', '性别', '婚姻状况(2)', '出生日期(2)']
        ['教育程度', '身份证号']
        ['证件到期日', '发证机关所在地(2)']
        ['单位名称(2)', '部门', '单位性质(2)']
        ['职务名称(2)', '职务类型(3)']
        ['雇佣类型(2)', '现单位工作年限', '企业成立年限(2)']
        ['月收入', '有无本地房产', '居住状况(2)']
        ['电子邮箱(2)', '户口所在地', '有无子女']
        ['居住地址']
        ['单位地址']
        ['手机', '家庭固话', '单位固话']
        ['人事部门联系人', '人事部联系电话']
      账户信息:
        ['支付方式', '还款账户开户行', '还款账户户名', '还款账户卡/账号']
        ['收款账户开户行', '收款账户户名', '收款账户卡/账号']
      联系人:
        ['亲属联系人姓名', '亲属联系人关系', '亲属联系人手机', '亲属联系人宅电']
        ['其他联系人姓名', '其他联系人关系', '其他联系人手机', '其他联系人宅电']

  edit-application = h.extend-widget create-application, {type: 'edit', label: '修改贷款申请'}

  view-application = h.extend-widget create-application, {type: 'view', label: '贷款申请详情'}

  list-application = type: 'list', model: 'application', appearance:
    type: 'table.semantic-ui'
    columns: ['申请人.姓名', '贷款申请.申请金额', '贷款申请.还款方式']
    
  [create-application, edit-application, view-application, list-application]

get-audit-widgets-specs = (h)->
  create-audit = type: 'create', label: '审核贷款', model: 'audit', appearance:
    type: 'gridforms'
    rows: 
      ['申请号', '部门经理姓名/编号', '调查员姓名/编号', '审批情况']
      ['信用调查意见' 3]
      ['审批意见' 3]

  edit-audit = h.extend-widget create-audit, {type: 'edit', label: '修改贷款审核'}

  view-audit = h.extend-widget create-audit, {type: 'view', label: '贷款审核详情'}

  list-audit = type: 'list', model: 'audit', appearance:
    type: 'table.semantic-ui'
    columns: ['申请号', '部门经理姓名/编号', '调查员姓名/编号', '审批情况']
    
  [create-audit, edit-audit, view-audit, list-audit]




define 'widgets-spec', ['helpers'], (helpers)-> 
  if Meteor.is-client then get-widgets-specs helpers else []
