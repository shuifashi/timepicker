# define 'app-spec', ['state', 'helpers'], (state, helpers)-> spec =
define 'app-spec', ['widgets-spec', 'state', 'helpers'], (widgets-spec, state, helpers)-> spec =
  name: '亚洲基础设施投资银行贷款申请'
  roles: ['信贷员', '申请人', '部门经理']

  # permissions: data: {}, app-state: {}

  models:
    '@default': '@valid': {required: true}
    application:
      申请人:
        '姓名': null
        '性别': '@values': ['男', '女']
        '婚姻状况': '@values': ['未婚', '已婚', '离婚', '丧偶']
        '出生日期': '@type': 'date'
        '教育程度': '@values': ['博士及以上', '硕士', '本科', '大专', '高中/中专', '初中及以下']
        '身份证号': null
        '证件到期日': null
        '发证机关所在地': null
        '单位名称': null
        '部门': null
        '单位性质': '@values': <[事业/机关 国有 私营 股份 个体 军/警 其他]>
        '职务名称': null
        '职务类型': '@values': <[普通工作人员 科室负责人或科级 部门负责人或处级 单位负责人或局级以上]>
        '雇佣类型': '@values': <[自雇 受薪]>
        '现单位工作年限': null
        '企业成立年限': null
        '月收入': null
        '有无本地房产': '@values': <[有 无]>
        '居住状况': '@values': <[自建 自购无按揭 租用 亲属住房 单位住房]>
        '电子邮箱': null
        '户口所在地': '@values': <[本地 非本地]>
        '有无子女': '@values': <[有 无]>
        '居住地址': null
        '单位地址': null
        '手机': null
        '家庭固话': null
        '单位固话': null
        '人事部门联系人': null
        '人事部联系电话': null

      联系人:
        '@default': '@valid': {required: false} # '@valid': -> h.at-least-one-set '亲属', '其他'
        '亲属联系人姓名': null
        '亲属联系人关系': '@values': <[ 配偶 父母 子女 其他 ]>
        '亲属联系人手机': null # '@type': 'chinese.mobile'
        '亲属联系人宅电': null # '@type': 'chinese.residential.phone'
        '其他联系人姓名': null
        '其他联系人关系': '@values': <[ 朋友 同学 同事 其他 ]>
        '其他联系人手机': null # '@type': 'chinese.mobile'
        '其他联系人宅电': null # '@type': 'chinese.residential.phone'

      贷款申请:
        '申请金额': null
        '贷款期限': '@values': <[ 12月 24月 36月 48月 60月 ]>
        '利率调整方式': '@values': <[ 固定 按月 按季 按年 ]>
        '还款方式': '@values': <[ 按月等额 按月付息，到期还本 ]>
        '平安守护': '@values': <[ 意外+疾病保障 意外保障 ]>
        '贷款用途': '@values': <[ 购车 装修 婚庆 教育 旅游 经营 其它消费 ]>

      账户信息:
        '支付方式': '@values': <[ 自主支付 受托支付 ]>
        '还款账户开户行': null
        '还款账户户名': null
        '还款账户卡/账号': null
        '收款账户开户行': null
        '收款账户户名': null
        '收款账户卡/账号': null

    audit:
      申请号: '@ref': 'application._id'
      审批情况: '@values': <[ 待审 调查完成 审核批准 审核否决 ]>
      '部门经理姓名/编号': null
      '调查员姓名/编号': null
      信用调查意见: '@type': 'text'
      审批意见: '@type': 'text'

  descriptions:
    application:
      placeholders:
        '申请人.姓名': '申请人姓名'

  widgets: widgets-spec

  runtime:
    states: ['splash', '申请']

    states-widgets:
      '申请': ['create-application']

    states-data: null # TODO: 从model中推断默认的设置

    transitions: 
      'splash  ->  申请'   :   '@+:auto'    :   delay: 2000ms , condition: -> true # Roles.user-is-in-role Meteor.user!, 'teacher'


    initial-state: 'splash'




