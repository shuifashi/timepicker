Meteor.startup -> define 'fake-data', [], -> fake = 
  assignments:
    * title: 'HTML基础'
      content: '熟悉HTML标签的使用，完成菜单应用'
      end-time: '2015-01-11T13:12'
    * title: 'CSS初步'
      content: '初步使用CSS，掌握选择器和基本CSS属性'
      end-time: '2015-02-11T13:12'
    * title: 'CSS高级'
      content: '网页布局'
      end-time: '2015-03-11T13:12'
    * title: 'Javascript初步'
      content: '熟悉Javascript语法和基本DOM操作'
      end-time: '2015-04-11T13:12'
  homeworks:
    * title: 'a+ b+框架原理分析'
      teacher: '王青'
      end-time: '2015-12-11T13:12'
      score: 86
      content: 'a+和b+框架是现代SPA应用全解决方案，提供了完整的技术、工具和过程。'
    ...
  users:
    * email: 'zhangsan@test.com'
      username: '张三'
      profile:  avatar: '/images/2.jpg'
      password: 'zhangsan'
      roles: ['student', 'teacher']
    * email: 'lisi@test.com'
      username: '李四'
      profile:  avatar: '/images/2.jpg'
      password: 'lisi'
      roles: ['supspended.student']
    * email: 'zhaowu@test.com'
      username: '赵武'
      profile:  avatar: '/images/2.jpg'
      password: 'zhaowu'
      roles: ['student']
    * email: 'qianliu@test.com'
      username: '钱镠'
      profile:  avatar: '/images/2.jpg'
      password: 'qianliu'
      roles: ['student']
    * email: 'admin@test.com'
      username: 'admin'
      profile:  avatar: '/images/2.jpg'
      password: 'supersecret'
      roles: ['admin', 'reviewer']
    * email: 'collector@test.com'
      username: 'collector'
      profile:  avatar: '/images/3.jpg'
      password: 'collector'
    * email: 'reviewer@test.com'
      username: 'reviewer'
      profile:  avatar: '/images/4.jpg'
      password: 'reviewer'
      roles: ['reviewer']
