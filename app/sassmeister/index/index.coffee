'use strict'

require 'angular'
require 'angular-ui-router'

angular.module('SassMeister.index', [
  'ui.router'
])

.config ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $locationProvider.html5Mode true

  $stateProvider
    .state('application.index',
      url: '/'
    )

