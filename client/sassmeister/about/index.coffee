'use strict'

require 'angular'
require 'angular-ui-router'

angular.module 'SassMeister.about', [
  'ui.router'
]

.config ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $locationProvider.html5Mode true

  template = require './_about.jade'

  $stateProvider
    .state 'application.about',
      url: '^/about'
      template: template
      controller: 'AboutController'
      resolve:
        data: () ->

.controller 'AboutController', ($scope, $state, data) ->

