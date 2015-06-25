'use strict'

config = require './config'

require 'angular'
require 'angular-ui-router'
require 'ngStorage'
require './index'
require './gist'
require './compiler'
require './ace'
require './control-panel'

debounce = require './lib/debounce'

angular.module 'SassMeister', [
  'ui.router'
  'ngStorage'
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
        data: ($localStorage) ->
          $localStorage.$default config.storageDefaults

.controller 'ApplicationController', ($scope, $localStorage, data, Compiler) ->
  $scope.app = data.app
  $scope.preferences = data.preferences

  $scope.themes = config.themes()

  $scope.compile = debounce ->
    Compiler.compile {
      input: $scope.app.sass
      compiler: $scope.app.compiler
      syntax: $scope.app.syntax
      original_syntax: $scope.app.originalSyntax
      output_style: $scope.app.outputStyle
    }, (data) ->
      $scope.app.css = data.css
  , 500 # Production uses 750

