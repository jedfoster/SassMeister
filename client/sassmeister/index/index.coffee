'use strict'

require 'angular'
require 'angular-ui-router'

angular.module 'SassMeister.index', [
  'ui.router'
]

.config ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $locationProvider.html5Mode true

  template = require '../_application.jade'

  $stateProvider
    .state 'application.index',
      url: '^/'
      template: template
      controller: 'ApplicationController'

