'use strict'

require 'angular'
require 'angular-ui-router'
require './index'
require './gist'
require './compiler'
require './ace'
require './control-panel'

debounce = require './lib/debounce'

angular.module('SassMeister', [
  'ui.router'
  'SassMeister.gist'
  'SassMeister.index'
  'SassMeister.compiler'
  'SassMeister.ace'
  'SassMeister.controlPanel'
])

.config ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $locationProvider.html5Mode true

  $urlRouterProvider.otherwise '/'

  template = require './application.jade'

  $stateProvider
    .state('application',
      abstract: true
      template: template
      controller: 'ApplicationController'
    )

.controller 'ApplicationController', ($scope, Compiler) ->
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

