'use strict'

require 'angular'
require 'angular-ui-router'

debounce = (func, wait, immediate) ->
  timeout = undefined
  ->
    context = this
    args = arguments

    later = ->
      timeout = null
      if !immediate
        func.apply context, args
      return

    callNow = immediate and !timeout
    clearTimeout timeout
    timeout = setTimeout(later, wait)
    if callNow
      func.apply context, args
    return


angular.module('sassMeister.index', [
  'ui.router'
])

.config ($stateProvider, $locationProvider) ->
  $locationProvider.html5Mode true

  template = require './index.jade'

  $stateProvider
    .state(
      name: 'index'
      url: '/'
      template: template
      controller: 'IndexController'
    )

.controller 'IndexController', ($scope, Compiler) ->
  $scope.outputStyles = [
    'nested'
    'compressed'
  ]

  $scope.selectedStyle = 'nested'
  $scope.sassInput = ''

  $scope.compile = debounce( ->
      Compiler.compile {
        input: $scope.sassInput
        compiler: '3.4'
        syntax: 'SCSS'
        original_syntax: 'SCSS'
        output_style: $scope.selectedStyle
      }, (data) ->
        $scope.css = data.css
    , 500 ) # Production uses 750

