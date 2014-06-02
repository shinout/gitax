module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON "package.json"
    coffee:
      compile:
        files:
          "lib/gitax.js": "src/gitax.coffee"

  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.registerTask "default", ["coffee"]
