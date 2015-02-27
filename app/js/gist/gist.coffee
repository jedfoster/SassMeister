'use strict'

require 'angular'
require 'angular-ui-router'
require 'angular-resource'

angular.module('sassMeister.gist', [
  'ngResource'
  'ui.router'
])

.config ($stateProvider, $locationProvider) ->
  $locationProvider.html5Mode true

  $stateProvider
    .state(
      name: 'gist'
      url: '/gist/:id'
      templateUrl: 'gist.html'
      controller: 'GistController'
    )
  return

.factory 'Gist', ($resource) ->
  $resource 'http://gist.drft.io/gists/:id.json'

.controller 'GistController', ($scope, $routeParams, Gist) ->
  Gist.get { id: $routeParams.id }, (data) ->
    $scope.sass = data.gist.sass
    $scope.css = data.gist.css
    return
  return

