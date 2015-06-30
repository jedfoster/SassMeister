'use strict'

require 'angular'
require 'angular-ui-router'
require 'angular-cookies'
require 'underscore'
require '../../github-adapter'

Github = require 'github-api'

angular.module 'SassMeister.gist', [
  'ui.router'
  'ngCookies'
  'github-adapter'
]

.config ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $locationProvider.html5Mode true

  template = require '../_application.jade'

  $stateProvider
    .state 'application.gist',
      url: '^/gist/:id'
      template: template
      controller: 'GistController'
      resolve:
        data: ($githubGist, $githubUser, $stateParams, $cookies, $q) ->
          # This shows how you could include resolved data from the parent state.
          # Meh. Not sure how I feel about this. Or even how useful this is.
          # _data = data

          github = new Github
            token: $cookies.get 'gh'
            auth: 'oauth'

          getUser = ->
            $q.when($githubUser(github.getUser()))

          getGist = (id) ->
            $q.when($githubGist(github.getGist(id)))

          getGist($stateParams.id)
            .then (gist) ->
              gist.read()
            
.controller 'GistController', ($scope, data) ->
  sassRegEx = /.+\.(scss|sass)/i
  cssRegEx = /.+-output\.css/i
  htmlRegEx = /.+\.(haml|textile|markdown|md|html)/i
  frontmatterRegEx = /^\/\/ ([\w\s]+?) \(v([A-z0-9\.]+?)\)\s*$/mgi

  files = Object.keys data.files

  files.forEach (fileName) ->
    # For now, we only return the first .sass or .scss file we find.
    if !$scope.app.sass and fileName.match sassRegEx
      $scope.app.sass = data.files[fileName].content
      $scope.app.syntax = data.files[fileName].language.toLowerCase()
      $scope.app.originalSyntax = $scope.app.syntax

    if !$scope.app.css and fileName.match cssRegEx
      $scope.app.css = data.files[fileName].content

    if !$scope.app.html and fileName.match htmlRegEx
      $scope.app.html = data.files[fileName].content
      $scope.app.htmlSyntax = data.files[fileName].language.toLowerCase()

  if !$scope.app.sass
    $scope.app.sass = "// Sorry, I couldn't find any valid Sass in that Gist."

  while frontmatter = frontmatterRegEx.exec $scope.app.sass
    [x,name, version] = frontmatter
    $scope.app.dependencies[name] = version

  if $scope.app.dependencies.libsass
    $scope.app.compiler = 'lib'
  else if $scope.app.dependencies.Sass
    $scope.app.compiler = $scope.app.dependencies.Sass.substr(0, 3)
  

