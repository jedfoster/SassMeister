'use strict'

require 'angular'
require 'angular-ui-router'

angular.module 'SassMeister.404', [
  'ui.router'
]

.config ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $locationProvider.html5Mode true

  template = require './_404.jade'

  $stateProvider
    .state 'application.404',
      template: template
      params:
        id: null
      controller: '404Controller'

    .state 'application.404.gist',
      parent: 'application.404'

.controller '404Controller', ($scope, $state, $stateParams) ->
  $scope.resource = if $state.current.name == 'application.404.gist' then 'gist' else 'page'
  $scope.id = $stateParams.id if $stateParams.id
  $scope.goToGist = (id) ->
    $state.go 'application.gist', id: id


