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

