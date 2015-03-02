'use strict'

require 'angular'
require 'angular-ui-router'
require 'angular-resource'

angular.module('SassMeister.gist', [
  'ngResource'
  'ui.router'
])

.config ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $locationProvider.html5Mode true

  $stateProvider
    .state('application.gist',
      url: '/gist/:id'
      controller: 'GistController'
    )

.factory 'Gist', ($resource) ->
  $resource 'http://gist.drft.io/gists/:id.json'

.controller 'GistController', ($scope, $routeParams, Gist) ->
  
  Gist.get { id: $routeParams.id }, (data) ->
    $scope.sass = data.gist.sass
    $scope.css = data.gist.css



