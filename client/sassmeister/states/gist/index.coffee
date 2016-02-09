'use strict'

require 'angular'
require 'angular-ui-router'

require '../../../github-adapter'
require '../../sandbox'

angular.module 'SassMeister.gist', [
  'ui.router'
  'github-adapter'
  'SassMeister.sandbox'
]

.config ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $locationProvider.html5Mode true

  template = require '../_application.jade'

  $stateProvider
    .state 'application.gist',
      url: '^/gist/:id'
      params:
        gist: false
      template: template
      controller: 'GistController'
      resolve:
        data: ($githubGist, $stateParams, $q, $state) ->
          if $stateParams.gist
            return $stateParams.gist

          else
            fail = ->
              $state.go 'application.404.gist', { id: $stateParams.id }, { location: false }

            $githubGist($stateParams.id).read().then null, fail


.controller 'GistController', ($scope, $rootScope, $sassMeisterGist, $githubGist, $state, $stateParams, Sandbox, data, ngToast, $sce) ->
  $scope.app =
    dependencies: {}
  $scope.app.outputStyle = 'expanded'

  $scope.gist =
    created_at: data.created_at
    description: data.description
    files: data.files
    html_url: data.html_url
    id: data.id
    updated_at: data.updated_at
    owner:
      avatar_url: data.owner.avatar_url
      id: data.owner.id
      login: data.owner.login
      html_url: data.owner.html_url

  $rootScope._canEditGist = $scope.gist.owner.login == $scope.githubId

  sassRegEx = /.+\.(scss|sass)/i
  cssRegEx = /.+-output\.css/i
  htmlRegEx = /.+\.(haml|textile|markdown|md|html)/i
  renderedHTMLRegEx = /.+-rendered\.html/i
  frontmatterRegEx = /^\/\/ ([\w\s]+?) \(v([A-z0-9\.]+?)\)\s*$/mgi

  files = Object.keys data.files

  files.forEach (fileName) ->
    # For now, we only return the first .sass or .scss file we find.
    if fileName.match(sassRegEx) and not $scope.sassFileName
      $scope.app.sass = data.files[fileName].content
      $scope.app.syntax = data.files[fileName].language.toLowerCase()
      $scope.app.originalSyntax = $scope.app.syntax
      $scope.sassFileName = fileName

    if fileName.match(cssRegEx) and not $scope.cssFileName
      $scope.app.css = data.files[fileName].content
      $scope.cssFileName = fileName

    if fileName.match(htmlRegEx) and not $scope.htmlFileName
      $scope.app.html = data.files[fileName].content
      $scope.app.htmlSyntax = data.files[fileName].language.toLowerCase()
      $scope.htmlFileName = fileName

    if fileName.match(renderedHTMLRegEx) and not $scope.renderedHTMLFileName
      $scope.app.renderedHTML = data.files[fileName].content
      $scope.renderedHTMLFileName = fileName

    if fileName == 'browserslist'
      $scope.preferences.autoprefixer = true
      $scope.preferences.autoprefixerBrowsers = data.files[fileName].content.split("\n").join(', ')

  if !$scope.app.sass
    $scope.app.sass = "// Sorry, I couldn't find any valid Sass in that Gist."

  while frontmatter = frontmatterRegEx.exec $scope.app.sass
    [x, name, version] = frontmatter
    $scope.app.dependencies[name] = version

  if $scope.app.dependencies.libsass
    $scope.app.compiler = 'lib'
  else if $scope.app.dependencies.Sass
    $scope.app.compiler = $scope.app.dependencies.Sass.substr(0, 3)

  Sandbox.onReady $scope.app

  $scope.updateGist = (event) ->
    if event and event.preventDefault
      event.preventDefault()

    $sassMeisterGist.update $stateParams.id, $scope, (gist) ->
      $scope.notify gist.id, 'has been updated'

  $scope.forkGist = (event) ->
    if event and event.preventDefault
      event.preventDefault()

    if $scope.canEditGist()
      $sassMeisterGist.create $scope, (gist) ->
        $scope.notify gist.id, 'has been forked'

        $state.go '^.gist',
          id: gist.id
          gist: gist

    else
      $sassMeisterGist.fork $stateParams.id, (gist) ->
        # The GH /fork API does not return content, so we need to copy the
        # Sass, CSS and HTML content manually. This prevents the app from
        # making another request to the API.
        gist.files[$scope.sassFileName].content = $scope.app.sass if gist.files[$scope.sassFileName]
        gist.files[$scope.cssFileName].content = $scope.app.css if gist.files[$scope.cssFileName]
        gist.files[$scope.htmlFileName].content = $scope.app.html if gist.files[$scope.htmlFileName]
        gist.files[$scope.renderedHTMLFileName].content = $scope.app.renderedHTML if gist.files[$scope.renderedHTMLFileName]
        
        if gist.files['browserslist'] $scope.preferences.autoprefixer and $scope.preferences.autoprefixerBrowsers
          gist.files['browserslist'].content = $scope.preferences.autoprefixerBrowsers.split(', ').join("\n")

        $scope.notify gist.id, 'has been forked'

        $state.go '^.gist',
          id: gist.id
          gist: gist

  $scope.$on 'command-s', $scope.updateGist
  $scope.$on 'shift-command-s', $scope.forkGist

  $scope.embedCode = ->
    "<p class=\"sassmeister\" data-gist-id=\"#{$scope.gist.id}\" data-height=\"480\" data-theme=\"#{$scope.preferences.theme}\"><a href=\"http://#{document.domain}/gist/#{$scope.gist.id}\">Play with this gist on SassMeister.</a></p><script src=\"http://cdn.#{document.domain}/js/embed.js\" async></script>"

