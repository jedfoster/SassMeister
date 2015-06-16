'use strict'

require 'angular'
require 'angular-ui-router'
require './index'
require './gist'
require './compiler'
require './ace'
require './control-panel'

debounce = require './lib/debounce'

angular.module 'SassMeister', [
  'ui.router'
  'SassMeister.gist'
  'SassMeister.index'
  'SassMeister.compiler'
  'SassMeister.ace'
  'SassMeister.controlPanel'
]

.config ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $locationProvider.html5Mode true

  $urlRouterProvider.otherwise '/'

  $stateProvider
    .state 'application',
      abstract: true
      url: '/'
      template: '<ui-view/>'
      controller: 'ApplicationController'
      resolve:
        data: ->
          sass: ''
          css: ''
          outputStyle: 'nested'

.controller 'ApplicationController', ($scope, data, Compiler) ->
  $scope.sass = data.sass
  $scope.css = data.css

  $scope.outputStyles = [
    'nested'
    'compressed'
  ]

  $scope.selectedStyle = data.outputStyle

  $scope.compile = debounce ->
    Compiler.compile {
      input: $scope.sass
      compiler: '3.4'
      syntax: 'SCSS'
      original_syntax: 'SCSS'
      output_style: $scope.selectedStyle
    }, (data) ->
      $scope.css = data.css
  , 500 # Production uses 750

