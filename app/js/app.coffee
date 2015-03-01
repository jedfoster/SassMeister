'use strict'

require 'angular'
require 'angular-ui-router'
require './gist/gist'
require './index/index'
require './compiler/compiler'

angular.module('SassMeister', [
  'ui.router'
  'SassMeister.gist'
  'SassMeister.index'
  'SassMeister.compiler'
])

.config ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $locationProvider.html5Mode true

  $urlRouterProvider.otherwise '/'

