'use strict'

config = require '../config'

require 'angular'
require 'angular-ui-router'
require 'ngStorage'
require '../../github-adapter'

angular.module 'SassMeister.index', [
  'ui.router'
  'ngStorage'
  'github-adapter'
]

.config ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $locationProvider.html5Mode true

  template = require '../_application.jade'

  $stateProvider
    .state 'application.index',
      url: '^/'
      params:
        reset: false
      template: template
      controller: 'IndexController'
      resolve:
        data: ($localStorage, $stateParams) ->
          if $stateParams.reset
            $localStorage.app = config.storageDefaults().app

          _data = $localStorage.$default config.storageDefaults()

          # ngStorage's `$default` doesn't do a deep merge, so we need to apply the merge manually.
          # This ensures that new props added to the defaults are available to the app.
          # But... Turns out that `angular.merge` will over write existing keys, so `merge(data, defaults)` would erase any user values.
          # And, `merge(defaults, data)`—while it respects keys—breaks the automagic localStorage linkage.

          # So. Brute-force it with `extend`. Blech.
          _data.app = angular.extend config.storageDefaults().app, _data.app

          _data

.controller 'IndexController', ($scope, $sassMeisterGist, $localStorage, $state, data) ->
  $scope.$parent.app = data.app

  $scope.createGist = ->
    $sassMeisterGist.create $scope, (gist) ->
      $state.go '^.gist',
        id: gist.id
        gist: gist

