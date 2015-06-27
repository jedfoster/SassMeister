'use strict'

require 'angular'

template = require './_control-panel.jade'

angular.module 'SassMeister.controlPanel', ['SassMeister.compiler']

.directive 'controlPanel', ['Compiler', (Compiler) ->
  restrict: 'E'
  template: template
  link: (scope, element, attrs) ->
    Compiler.compilers {}, (data) ->
      scope.compilers = (
        keys = Object.keys(data.compilers)

        for key in keys
          compiler = data.compilers[key]
          compiler.engine = 'Sass' if compiler.engine.match /Ruby/
          
          {
            value: key
            option: "#{compiler.engine} #{compiler.sass}"
          }
      )
]
