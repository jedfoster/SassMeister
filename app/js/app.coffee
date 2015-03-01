'use strict'

require 'angular'
require 'angular-ui-router'
require './gist/gist'
require './index/index'
require './compiler/compiler'

angular.module('sassMeister', [
  'ui.router'
  'sassMeister.gist'
  'sassMeister.index'
  'sassMeister.compiler'
  'ui.ace'
])

.config ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $locationProvider.html5Mode true

  $urlRouterProvider.otherwise '/'

