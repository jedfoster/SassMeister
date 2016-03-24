'use strict'

config = require './config'

require 'angular'
require 'angular-ui-router'
require 'angular-cookies'
require 'ngstorage'
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

.config ['$stateProvider', '$urlRouterProvider', '$locationProvider', '$sceDelegateProvider', 'hotkeysProvider', ($stateProvider, $urlRouterProvider, $locationProvider, $sceDelegateProvider, hotkeysProvider) ->
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
        data: ['$localStorage', ($localStorage) ->
          _data = $localStorage.$default config.storageDefaults()

          # ngStorage's `$default` doesn't do a deep merge, so we need to apply the merge manually.
          # This ensures that new props added to the defaults are available to the app.
          # But... Turns out that `angular.merge` will over write existing keys, so `merge(data, defaults)` would erase any user values.
          # And, `merge(defaults, data)`—while it respects keys—breaks the automagic localStorage linkage.

          # So. Brute-force it with `extend`. Blech.
          _data.preferences = angular.extend config.storageDefaults().preferences, _data.preferences

          _data
        ]

    .state 'application.logout',
      url: 'logout'

  hotkeysProvider.includeCheatSheet = false
]

.controller 'ApplicationController', ['$scope', '$rootScope', '$state', '$localStorage', '$sce', '$cookies', '$window', 'data', 'Compiler', 'angularLoad', 'Sandbox', 'ngToast', 'hotkeys', ($scope, $rootScope, $state, $localStorage, $sce, $cookies, $window, data, Compiler, angularLoad, Sandbox, ngToast, hotkeys) ->
  $rootScope.$state = $state
  $rootScope._canEditGist = false
  $rootScope.isEmbedded = !!window.SassMeister.isEmbedded

  $scope.app = config.storageDefaults().app
  $scope.preferences = data.preferences
  $rootScope.orientation = $scope.preferences.orientation
  $scope.themes = config.themes()
  $scope.editors = {}
  $scope.sandbox =  config.sandbox
  $scope.githubId = $cookies.get 'github_id'
  $scope.avatarUrl = $cookies.get 'avatar_url'
  $scope.showCompiling = false
  $scope.compileTime = false
  $scope.hasTouch = false

  setHasTouch = () ->
    $scope.hasTouch = true
    $window.removeEventListener('touchstart', setHasTouch)

  $window.addEventListener('touchstart', setHasTouch, false)

  # Set default values for commonly evaluated values
  $scope.gist = false
  $scope.canEditGist = ->
    $rootScope._canEditGist

  $scope.autoprefixerBrowsers = ->
    browsers = $scope.preferences.autoprefixerBrowsers

    browsers = browsers.split(',').map (x) ->
      x.trim()

    if browsers.length > 0
      return browsers

    return ['> 1%', 'last 2 versions']

  $scope.compile = (app)->
    return if $state.includes('application.404') or $state.includes('application.about') or $state.includes('application.embedded') or $rootScope.isEmbedded

    $scope.compileTime = false
    $scope.showCompiling = true

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

      $scope.showCompiling = false
      $scope.compileTime = data.time

      setTimeout( ->
        $scope.compileTime = false
      , 10750)

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
      $window.ga('send', 'event', 'UI', 'SassExtensions', _import)

    $scope.editors.sass.insert collection.join ''

    app.sass = $scope.editors.sass.getValue()

    do $scope.compile

  $scope.renderHtml = (app) ->
    Sandbox.render app

  $scope.$watch 'preferences.emmet', (value) ->
    $window.ga('send', 'event', 'UI', 'Emmet', "#{value}")

    if value and not $window.emmet
      angularLoad.loadScript 'http://nightwing.github.io/emmet-core/emmet.js'
        .then ->
          $scope.emmet = value

    else
      $scope.emmet = value

  $scope.$watch 'preferences.autoprefixer', (value) ->
    $scope.autoprefixer = value

    $window.ga('send', 'event', 'UI', 'SetAutoprefixer', "#{value}")

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
    do windowResize

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

  $scope.commandS = (event) ->
    if event and event.preventDefault
      event.preventDefault()

    $scope.$broadcast 'command-s' if $scope.canEditGist()

  $scope.shiftCommandS = (event) ->
    if event and event.preventDefault
      event.preventDefault()

    $scope.$broadcast 'shift-command-s'

  hotkeys.add
    combo: 'mod+s'
    callback: $scope.commandS

  hotkeys.add
    combo: 'shift+mod+s'
    callback: $scope.shiftCommandS

  $scope.showSiteHeader = not window.SassMeister.isEmbedded

  $scope.logoUrl = ->
    $window.location.pathname

  $scope.$watch 'app.compiler', (n, o) ->
    $window.ga('send', 'event', 'UI', 'SassVersion', "v#{n}") unless n == o

  $scope.$watch 'preferences.orientation', (n, o) ->
    $window.ga('send', 'event', 'UI', 'Orientation', n) unless n == o

  $scope.$watch 'app.syntax', (n, o) ->
    $window.ga('send', 'event', 'UI', 'SassSyntax', n) unless n == o

  $scope.$watch 'app.outputStyle', (n, o) ->
    $window.ga('send', 'event', 'UI', 'CSSOutput', n) unless n == o

  $scope.$watch 'app.htmlSyntax', (n, o) ->
    $window.ga('send', 'event', 'UI', 'HTMLSyntax', n) unless n == o

  $scope.$watch 'preferences.cssVisible', (n, o) ->
    $window.ga('send', 'event', 'UI', 'ToggleCSS', n) unless n == o

  $scope.$watch 'preferences.htmlVisible', (n, o) ->
    $window.ga('send', 'event', 'UI', 'ToggleHTML', n) unless n == o

  $scope.$watch 'preferences.theme', (n, o) ->
    $window.ga('send', 'event', 'UI', 'SetTheme', n) unless n == o

  $scope.$watch 'preferences.emmet', (n, o) ->
    $window.ga('send', 'event', 'UI', 'SetEmmet', "#{n}") unless n == o

  $scope.$watch 'preferences.vim', (n, o) ->
    $window.ga('send', 'event', 'UI', 'SetVim', "#{n}") unless n == o

  $scope.$watch 'preferences.scrollPastEnd', (n, o) ->
    $window.ga('send', 'event', 'UI', 'SetScrollPastEnd', "#{n}") unless n == o

  $scope.$watch 'preferences.autoprefixerBrowsers', (n, o) ->
    $window.ga('send', 'event', 'UI', 'SetAutoprefixerBrowsers', "#{n}") unless n == o
]

.run ['$rootScope', '$location', '$window', ($rootScope, $location, $window) ->
  $window.ga('create', 'UA-35407426-1', 'auto')

  # track pageview on state change
  $rootScope.$on '$stateChangeSuccess', (event) ->
    $window.ga 'send', 'pageview', $location.path()
]

