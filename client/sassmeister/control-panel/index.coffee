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
          option = "#{compiler.engine} v#{compiler.sass}"

          scope.app.displayCompiler = option if key == scope.app.compiler

          {
            value: key
            option: option
          }
      )

    getExtensions = ->
      Compiler.extensions {compiler: scope.app.compiler}, (data) ->
        scope.extensions = data.extensions

    scope.$watch 'app.compiler', ->
      do getExtensions
]
