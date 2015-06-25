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
  $scope.sass = data.sass
  $scope.css = data.css
  $scope.outputStyle = data.outputStyle
  $scope.compiler = data.compiler
  $scope.syntax = data.syntax
  $scope.originalSyntax = data.originalSyntax
  $scope.selectedTheme = data.preferences.theme

  $scope.themes = config.themes()

  $scope.compile = debounce ->
    Compiler.compile {
      input: $scope.sass
      compiler: '3.4'
      syntax: 'SCSS'
      original_syntax: 'SCSS'
      output_style: $scope.outputStyle
    }, (data) ->
      $scope.css = data.css
  , 500 # Production uses 750

