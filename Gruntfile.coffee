module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON "package.json"
    meta:
      shebang: '#!/usr/bin/env node'
    coffee:
      compile:
        files:
          "lib/gitax.js": "src/gitax.coffee"
          "lib/set.js": "src/set.coffee"
          "bin/gitax": "src/exe.coffee"
    concat:
      options:
        banner: '<%= meta.shebang %>\n\n'
      dist:
        src:  "bin/gitax"
        dest: "bin/gitax"

  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.registerTask "default", ["coffee", "concat"]
