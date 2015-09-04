'use strict'

require 'angular'
require 'angular-ui-router'
require 'underscore'
require '../../github-adapter'

angular.module 'SassMeister.gist', [
  'ui.router'
  'github-adapter'
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
        data: ($githubGist, $stateParams, $q) ->
          if $stateParams.gist
            return $stateParams.gist

          else
            return $githubGist($stateParams.id).read()

.controller 'GistController', ($scope, $sassMeisterGist, $githubGist, $state, $stateParams, data) ->
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

  $scope.canEditGist = ->
    $scope.gist.owner.login == $scope.githubId

  sassRegEx = /.+\.(scss|sass)/i
  cssRegEx = /.+-output\.css/i
  htmlRegEx = /.+\.(haml|textile|markdown|md|html)/i
  frontmatterRegEx = /^\/\/ ([\w\s]+?) \(v([A-z0-9\.]+?)\)\s*$/mgi

  files = Object.keys data.files

  files.forEach (fileName) ->
    # For now, we only return the first .sass or .scss file we find.
    if fileName.match sassRegEx
      $scope.app.sass = data.files[fileName].content
      $scope.app.syntax = data.files[fileName].language.toLowerCase()
      $scope.app.originalSyntax = $scope.app.syntax
      $scope.sassFileName = fileName

    if fileName.match cssRegEx
      $scope.app.css = data.files[fileName].content
      $scope.cssFileName = fileName

    if fileName.match htmlRegEx
      $scope.app.html = data.files[fileName].content
      $scope.app.htmlSyntax = data.files[fileName].language.toLowerCase()
      $scope.htmlFileName = fileName

  if !$scope.app.sass
    $scope.app.sass = "// Sorry, I couldn't find any valid Sass in that Gist."

  while frontmatter = frontmatterRegEx.exec $scope.app.sass
    [x, name, version] = frontmatter
    $scope.app.dependencies[name] = version

  if $scope.app.dependencies.libsass
    $scope.app.compiler = 'lib'
  else if $scope.app.dependencies.Sass
    $scope.app.compiler = $scope.app.dependencies.Sass.substr(0, 3)


  $scope.updateGist = ->
    console.log 'updating gist...'

    $sassMeisterGist.update $stateParams.id, $scope, (gist) ->
      console.log gist


  $scope.forkGist = ->
    if $scope.canEditGist()
      $sassMeisterGist.create $scope, (gist) ->
        $state.go '^.gist',
          id: gist.id
          gist: gist

    else
      $sassMeisterGist.fork $stateParams.id, (gist) ->
        # The GH /fork API does not return content, so we need to the Sass, CSS
        # and HTML content manually. This prevents the app from making another
        # request to the API.
        gist.files[$scope.sassFileName].content = $scope.app.sass
        gist.files[$scope.cssFileName].content = $scope.app.css
        gist.files[$scope.htmlFileName].content = $scope.app.html

        $state.go '^.gist',
          id: gist.id
          gist: gist

