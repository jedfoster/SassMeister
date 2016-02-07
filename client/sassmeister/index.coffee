'use strict'

config = require './config'

require 'angular'
require 'angular-ui-router'
require 'angular-cookies'
require 'ngStorage'
require 'angular-load'
require '../angular-resizable'
require 'angular-sanitize'
require 'angular-hotkeys'

require './states/index'
require './states/gist'
require './states/about'
require './states/404'

require './components/control-panel'
require './components/site-header'
require './components/cloud-menu'
require './components/carbon-ad'

require './compiler'
require './ace'
require './sandbox'

angular.module 'SassMeister', [
  'ui.router'
  'ngStorage'
  'angularLoad'
  'angularResizable'
  'SassMeister.gist'
  'SassMeister.index'
  'SassMeister.compiler'
  'SassMeister.ace'
  'SassMeister.controlPanel'
  'SassMeister.siteHeader'
  'SassMeister.cloudMenu'
  'SassMeister.about'
  'SassMeister.404'
  'ngCookies'
  'SassMeister.sandbox'
  'ngToast'
  'SassMeister.carbonAd'
  'cfp.hotkeys'
]

.config ['ngToastProvider', (ngToastProvider) ->
  ngToastProvider.configure
    animation: 'fade'
    maxNumber: 1
]

.config ($stateProvider, $urlRouterProvider, $locationProvider, $sceDelegateProvider, hotkeysProvider) ->
  $locationProvider.html5Mode true

  $urlRouterProvider.otherwise ($injector, $location) ->
    $injector
      .get('$state')
      .go 'application.404', null, location: false

    do $location.path

  $sceDelegateProvider.resourceUrlWhitelist [
    'self',
    "#{config.sandbox}/**"
  ]

  $stateProvider
    .state 'application',
      abstract: true
      url: '/'
      template: '<ui-view/>'
      controller: 'ApplicationController'
      resolve:
        data: ($localStorage) ->
          _data = $localStorage.$default config.storageDefaults()

          # ngStorage's `$default` doesn't do a deep merge, so we need to apply the merge manually.
          # This ensures that new props added to the defaults are available to the app.
          # But... Turns out that `angular.merge` will over write existing keys, so `merge(data, defaults)` would erase any user values.
          # And, `merge(defaults, data)`—while it respects keys—breaks the automagic localStorage linkage.

          # So. Brute-force it with `extend`. Blech.
          _data.preferences = angular.extend config.storageDefaults().preferences, _data.preferences

          _data

    .state 'application.logout',
      url: 'logout'

  hotkeysProvider.includeCheatSheet = false

.controller 'ApplicationController', ($scope, $rootScope, $state, $localStorage, $sce, $cookies, $window, data, Compiler, angularLoad, Sandbox, ngToast, hotkeys) ->
  $rootScope.$state = $state

  $scope.app = config.storageDefaults().app
  $scope.preferences = data.preferences
  $rootScope.orientation = $scope.preferences.orientation
  $scope.themes = config.themes()
  $scope.editors = {}
  $scope.sandbox =  config.sandbox
  $scope.githubId = $cookies.get 'github_id'
  $scope.avatarUrl = $cookies.get 'avatar_url'

  # Set default values for commonly evaluated values
  $scope.gist = false
  $scope.canEditGist = ->
    false

  $scope.autoprefixerBrowsers = ->
    browsers = $scope.preferences.autoprefixerBrowsers

    browsers = browsers.split(',').map (x) ->
      x.trim()

    if browsers.length > 0
      return browsers

    return ['> 1%', 'last 2 versions']

  $scope.compile = (app)->
    Compiler.compile {
      input: app.sass
      compiler: app.compiler
      syntax: app.syntax
      original_syntax: app.originalSyntax
      output_style: app.outputStyle
    }, (data) ->
      app.dependencies = data.dependencies

      if $scope.autoprefixer and $window.autoprefixer
        try
          app.css = $window.autoprefixer.process(data.css, browsers: $scope.autoprefixerBrowsers()).css
        catch e
          app.css = data.css
          console.warn e
      else
        app.css = data.css

      if app.html
        $scope.renderHtml app

  $scope.convert = (app) ->
    Compiler.convert {
      input: app.sass
      compiler: app.compiler
      original_syntax: app.originalSyntax
      syntax: app.syntax
    }, (data) ->
      app.sass = data.css
      app.originalSyntax = app.syntax

  $scope.insertImport = (imports, app) ->
    eol = (if app.syntax == 'scss' then ';' else '') + '\n'
    collection = []

    for _import in imports
      collection.push "@import \"#{_import}\"#{eol}"

    $scope.editors.sass.insert collection.join ''

    app.sass = $scope.editors.sass.getValue()

    do $scope.compile

  $scope.renderHtml = (app) ->
    Sandbox.render app

  $scope.$watch 'preferences.emmet', (value) ->
    if value and not $window.emmet
      angularLoad.loadScript 'http://nightwing.github.io/emmet-core/emmet.js'
        .then ->
          $scope.emmet = value

    else
      $scope.emmet = value

  $scope.$watch 'preferences.autoprefixer', (value) ->
    $scope.autoprefixer = value

    if value and not $window.autoprefixer
      angularLoad.loadScript 'https://cdn.rawgit.com/ai/autoprefixer-rails/6.0.3/vendor/autoprefixer.js'
        .then ->
          $scope.compile $scope.app

    else
      $scope.compile $scope.app

  $scope.resetSizes = ->
    $scope.preferences.sassResizable = {width: null, height: null}
    $scope.preferences.cssResizable = {width: null, height: null}
    $scope.preferences.sandboxResizable = {width: null, height: null}

  $scope.editorOrientation = () ->
    if $scope.preferences.orientation == 'vertical' then 'bottom' else 'right'

  $scope.sandboxOrientation = () ->
    if $scope.preferences.orientation == 'vertical' then 'left' else 'top'

  onResizableResize = (e, info) ->
    if e.name == 'angular-resizable.resizeEnd'
     $scope.preferences[info.id] =
       width: info.width
       height: info.height

    if info.id == 'sandboxResizable'
      mask = document.getElementById 'resizable-mask'
      mask.hidden = ! mask.hidden

  $scope.$on 'angular-resizable.resizeStart', onResizableResize
  $scope.$on 'angular-resizable.resizeEnd', onResizableResize

  $scope.notify = (gistId, messageText) ->
    ngToast.create
      className: 'success'
      dismissButton: true
      dismissOnClick : true
      dismissButtonHtml : '&times;'
      dismissOnTimeout: true
      content: $sce.trustAsHtml('<a href="https://gist.github.com/' + gistId + '" target="_blank">Your Gist</a> ' + messageText + '.')

  $scope.tabView = false

  windowResize = ->
    if document.documentElement.clientWidth <= 768
      $scope.tabView = $scope.tabView || 'sass'
      $rootScope.orientation = 'single-column'

    else
      $scope.tabView = false
      $rootScope.orientation = $scope.preferences.orientation

    $scope.$applyAsync()
    $rootScope.$applyAsync()

  do windowResize

  $window.onresize = windowResize

  $scope.setTab = (tab) ->
    $scope.tabView = tab

