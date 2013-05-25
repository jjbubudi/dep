module.exports = (grunt) ->
  
  grunt.initConfig
    "jasmine-node":
      options:
        coffee: true
      run:
        spec: "test"

    "coffee":
      compile:
        files:
          "lib/dep.js": ["src/*.coffee"]
  
  grunt.loadNpmTasks "grunt-contrib-jasmine-node"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  
  grunt.registerTask "default", ["jasmine-node", "coffee"]