# Browserify entry point for the global.js bundle (yay CoffeeScript!)
# View =  require './view'
console.log 'global.js loaded!'


app = angular.module('App', [
  'ngResource'
  'ngRoute'
])

app.config ($routeProvider, $locationProvider) ->
  $locationProvider.html5Mode true
  $routeProvider
    .when('/gist/:id',
      templateUrl: 'gist.html'
      controller: 'GistController'
    )
    .otherwise(
      templateUrl: 'index.html'
      controller: 'IndexController'
    )
  return

app.factory 'Gist', ($resource) ->
  $resource 'http://gist.drft.io/gists/:id.json'

app.factory 'Compiler', ($resource) ->
  $resource 'compile', null, 'compile': method: 'PUT'

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
    Compiler.compile { compiler:
      sass: $scope.sassInput
      outputStyle: $scope.selectedStyle }, (data) ->
      $scope.css = data.compiler.css
      return
    return

  return

