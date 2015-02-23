'use strict'

require 'angular'
require 'angular-ui-router'
require 'angular-resource'

app = angular.module('sassmeisterApp', [
  'ngResource'
  'ui.router'
])

app.config ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $locationProvider.html5Mode true

  $urlRouterProvider.otherwise '/'
  
  $stateProvider
    .state(
      name: 'gist'
      url: '/gist/:id'
      templateUrl: 'gist.html'
      controller: 'GistController'
    )
    .state(
      name: 'index'
      url: '/'
      templateUrl: 'index.html'
      controller: 'IndexController'
    )
  return

app.factory 'Gist', ($resource) ->
  $resource 'http://gist.drft.io/gists/:id.json'

app.factory 'Compiler', ($resource) ->
  $resource 'app/3.4/compile', null,
    'compile':
      method: 'POST'

app.controller 'GistController', ($scope, $routeParams, Gist) ->
  Gist.get { id: $routeParams.id }, (data) ->
    $scope.sass = data.gist.sass
    $scope.css = data.gist.css
    return
  return

app.controller 'IndexController', ($scope, Compiler) ->
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

