module.exports = (grunt) ->
  require('load-grunt-tasks')(grunt)
  path = require('path')
  pkg = grunt.file.readJSON("package.json")

  DEBUG = false # 添加测试所需代码，发布时应该为false

  grunt.initConfig 
    pkg: pkg
    meta:
      banner: "/**\n" + " * <%= pkg.name %> - v<%= pkg.version %> - <%= grunt.template.today(\"yyyy-mm-dd\") %>\n" + " * <%= pkg.homepage %>\n" + " *\n" + " * Copyright (c) <%= grunt.template.today(\"yyyy\") %> <%= pkg.author %>\n" + " * Licensed <%= pkg.licenses.type %> <<%= pkg.licenses.url %>>\n" + " */\n"

    changelog:
      options:
        dest: "CHANGELOG.md"
        template: "changelog.tpl"

    bump:
      options:
        files: ["package.json", "bower.json"]
        commit: true
        commitMessage: "chore(release): v%VERSION%"
        commitFiles: ["-a"]
        createTag: true
        tagName: "v%VERSION%"
        tagMessage: "Version %VERSION%"
        push: true
        pushTo: "origin"

    clean: 
      bin:
        dot: true
        files:
          src: [
            "bin/*"
            ".temp"
          ]

    copy:
      other:
        files: [
          src: ["**/*.js", '**/*.css', "README.md"]
          dest: "agile-homework/packages/ericwangqing:b-plus/"
          cwd: "src/"
          expand: true
        ]


    livescript:
      options:
        bare: false
      all:
        expand: true
        # flatten: true
        cwd: "src/"
        src: ['**/**.ls']
        dest: "agile-homework/packages/ericwangqing:b-plus/"
        ext: ".js"

    jade:
      options:
        pretty: true
        # data: 
        #   pkg: pkg
        #   host: host
        #   debug: DEBUG
      all:
        expand: true
        cwd: "src"
        src: ["**/*.jade"]
        dest: "agile-homework/packages/ericwangqing:b-plus/"
        ext: ".html"



    delta:
      options:
        livereload: true

      livescript:
        files: ["src/**/*.ls"]
        tasks: ["clean:bin", "newer:livescript"]

      jade:
        files: ["src/**/*.jade"]
        tasks: ["newer:jade"]

      other:
        files: ["src/**/*.js", "src/**/*.css", "src/README.md"]
        tasks: ["newer:copy:other"]

      grunt:
        files: ['Gruntfile.coffee']

 
  grunt.renameTask "watch", "delta"

  grunt.registerTask "watch", [
    "build"
    "delta"
  ]

  grunt.registerTask "default", [
    "build"
  ]

  grunt.registerTask "build", [
    "clean"
    "livescript"
    "copy"
    "jade"
  ]
  