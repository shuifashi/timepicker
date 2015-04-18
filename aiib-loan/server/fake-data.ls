Meteor.startup -> define 'fake-data', [], -> fake = 
  users:
    * email: 'zhangsan@test.com'
      username: '张三'
      profile:  avatar: '/images/2.jpg'
      password: 'zhangsan'
    * email: 'lisi@test.com'
      username: '李四'
      profile:  avatar: '/images/2.jpg'
      password: 'lisi'
      roles: ['信贷员']
    * email: 'zhaowu@test.com'
      username: '赵武'
      profile:  avatar: '/images/2.jpg'
      password: 'zhaowu'
      roles: ['部门经理']
    * email: 'qianliu@test.com'
      username: '钱镠'
      profile:  avatar: '/images/2.jpg'
      password: 'qianliu'
      roles: ['风险控制委员会']
