'use strict'

require 'angular'
require 'angular-ui-router'

angular.module 'SassMeister.about', [
  'ui.router'
]

.config ($stateProvider, $urlRouterProvider, $locationProvider, $httpProvider) ->
  $locationProvider.html5Mode true

  template = require './_about.jade'

  $stateProvider
    .state 'application.about',
      url: '^/about'
      template: template
      controller: 'AboutController'
      resolve:
        data: ($state, $http, Compiler) ->
          $http({method: 'GET', url: '/app/extensions'}).then (data) ->
            data.data

.controller 'AboutController', ($scope, $state, data) ->
  $scope.extensions = data.extensions

