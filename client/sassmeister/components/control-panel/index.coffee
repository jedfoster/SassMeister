'use strict'

require 'angular'
require 'ng-toast'
require 'angular-sanitize'

template = require './_control-panel.jade'

angular.module 'SassMeister.controlPanel', [
  'SassMeister.compiler'
  'ngToast'
]

.directive 'controlPanel', ['Compiler', '$sce', 'ngToast', (Compiler, $sce, ngToast) ->
  restrict: 'E'
  template: template
  link: (scope, element, attrs) ->
    Compiler.compilers {}, (data) ->
      scope.compilers = (
        keys = Object.keys(data.compilers)

        if keys.indexOf(scope.app.compiler) == -1
          scope.app.compiler = keys[0]

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

    scope.autoprefixerBrowsers = ->
      ngToast.create
        className: 'info modal autoprefixer-browsers'
        compileContent: scope
        dismissButton: true
        dismissOnClick : false
        dismissButtonHtml : '<button type="button">Done</button>'
        dismissOnTimeout: false
        content: $sce.trustAsHtml('<input name="autoprefixerBrowsers" placeholder="Example: > 1%, last 2 versions" ng-model="preferences.autoprefixerBrowsers" ng-model-options="{ debounce: 500 }" ng-change="compile(app)"> <a href="https://github.com/ai/browserslist#queries" target="_blank">(?)</a>')
]

