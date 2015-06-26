'use strict'

require 'angular'

template = require './_control-panel.jade'

angular.module 'SassMeister.controlPanel', ['ngResource']

.factory 'Compilers', ($resource) ->
  $resource '/app/compilers'

.directive 'controlPanel', ['Compilers', (Compilers) ->
  restrict: 'E'
  template: template
  link: (scope, element, attrs) ->
    Compilers.get()
      .$promise
      .then (data) ->
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

        console.log scope.compilers
]
