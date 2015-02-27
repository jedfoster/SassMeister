'use strict'

require 'angular'
require 'angular-ui-router'

template = require './index.jade'

angular.module('sassMeister.index', [
  'ui.router'
])

.config ($stateProvider, $locationProvider) ->
  $locationProvider.html5Mode true

  $stateProvider
    .state(
      name: 'index'
      url: '/'
      template: template
      controller: 'IndexController'
    )
  return

.controller 'IndexController', ($scope, Compiler) ->
  $scope.outputStyles = [
    'nested'
    'compressed'
  ]

  $scope.selectedStyle = 'nested'
  $scope.sassInput = ''

  $scope.compile = ->
    Compiler.compile {
      input: $scope.sassInput
      compiler: '3.4'
      syntax: 'SCSS'
      original_syntax: 'SCSS'
      output_style: $scope.selectedStyle
    }, (data) ->
      $scope.css = data.css
      return
    return

  return


