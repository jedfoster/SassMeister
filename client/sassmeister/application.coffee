'use strict'

config = require './config'

require 'angular'
require 'angular-ui-router'
require 'angular-cookies'
require 'ngStorage'
require './index'
require './gist'
require './compiler'
require './ace'
require './control-panel'
require './site-header'

angular.module 'SassMeister', [
  'ui.router'
  'ngStorage'
  'SassMeister.gist'
  'SassMeister.index'
  'SassMeister.compiler'
  'SassMeister.ace'
  'SassMeister.controlPanel'
  'SassMeister.siteHeader'
  'ngCookies'
]

.config ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $locationProvider.html5Mode true

  $urlRouterProvider.otherwise '/'

  $stateProvider
    .state 'application',
      abstract: true
      url: '/'
      template: '<ui-view/>'
      controller: 'ApplicationController'
      resolve:
        data: ($localStorage) ->
          _data = $localStorage.$default config.storageDefaults

          # ngStorage's `$default` doesn't do a deep merge, so we need to apply the merge manually.
          # This ensures that new props added to the defaults are available to the app.
          # But... Turns out that `angular.merge` will over write existing keys, so `merge(data, defaults)` would erase any user values.
          # And, `merge(defaults, data)`—while it respects keys—breaks the automagic localStorage linkage.
          #
          # So. Brute-force it with `extend`. Blech.
          # _data.app = angular.extend config.storageDefaults.app, _data.app
          _data.preferences = angular.extend config.storageDefaults.preferences, _data.preferences

          _data
    .state 'application.logout',
      url: 'logout'

.controller 'ApplicationController', ($scope, $localStorage, $cookies, $window, data, Compiler) ->
  $scope.app = config.storageDefaults.app
  $scope.preferences = data.preferences
  $scope.themes = config.themes()
  $scope.editors = {}
  $scope.githubId = $cookies.get 'github_id'
  $scope.avatarUrl = $cookies.get 'avatar_url'

  $scope.compile = ->
    Compiler.compile {
      input: $scope.app.sass
      compiler: $scope.app.compiler
      syntax: $scope.app.syntax
      original_syntax: $scope.app.originalSyntax
      output_style: $scope.app.outputStyle
    }, (data) ->
      $scope.app.css = data.css

  $scope.insertImport = (imports) ->
    eol = (if $scope.app.syntax == 'scss' then ';' else '') + '\n'

    for _import in imports
      $scope.editors.sass.insert "@import \"#{_import}\"#{eol}"


