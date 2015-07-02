'use strict'

require 'angular'
require 'angular-ui-router'
require 'underscore'
require '../../github-adapter'


buildFrontmatter = (dependencies) ->
  frontmatter = [ '// ----' ]

  if dependencies.libsass
    frontmatter.push "// libsass (v#{dependencies.libsass})"

  else
    frontmatter.push "// Sass (v#{dependencies.Sass})"
    frontmatter.push "// Compass (v#{dependencies.Compass})"

  for name, version of dependencies
    frontmatter.push "// #{name} (v#{version})" unless name.match /(libsass|Sass|Compass)/

  frontmatter.push '// ----'

  frontmatter.join "\n"


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
      template: template
      controller: 'GistController'
      resolve:
        data: ($githubGist, $stateParams, $q) ->
          $githubGist($stateParams.id).then (gist) ->
            gist.read()

.controller 'GistController', ($scope, $githubGist, $stateParams, data) ->
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
    if !$scope.app.sass and fileName.match sassRegEx
      $scope.app.sass = data.files[fileName].content
      $scope.app.syntax = data.files[fileName].language.toLowerCase()
      $scope.app.originalSyntax = $scope.app.syntax
      $scope.sassFileName = fileName

    if !$scope.app.css and fileName.match cssRegEx
      $scope.app.css = data.files[fileName].content
      $scope.cssFileName = fileName

    if !$scope.app.html and fileName.match htmlRegEx
      $scope.app.html = data.files[fileName].content
      $scope.app.htmlSyntax = data.files[fileName].language.toLowerCase()
      $scope.htmlFileName = fileName

  if !$scope.app.sass
    $scope.app.sass = "// Sorry, I couldn't find any valid Sass in that Gist."

  while frontmatter = frontmatterRegEx.exec $scope.app.sass
    [x,name, version] = frontmatter
    $scope.app.dependencies[name] = version

  if $scope.app.dependencies.libsass
    $scope.app.compiler = 'lib'
  else if $scope.app.dependencies.Sass
    $scope.app.compiler = $scope.app.dependencies.Sass.substr(0, 3)

  $scope.updateGist = ->
    content = $scope.gist
    files = {}
    sass = $scope.app.sass

    # Remove old frontmatter
    sass = sass.replace(/(^\/\/ [\-]{3,4}\n(?:\/\/ .+\n)*\/\/ [\-]{3,4}\s*)*/, '')

    # Build and prepend new frontmatter
    $scope.app.sass = "#{buildFrontmatter $scope.app.dependencies}\n\n#{sass}"

    unless $scope.sassFileName.substr(-4, 4) == $scope.app.syntax
      # Sass syntax has changed, so need to "rename" the file

      # First, delete contents of old file
      files[$scope.sassFileName] =
        content: null

      # Set name of new file, contents will be set later
      $scope.sassFileName = "#{$scope.sassFileName.substr 0, $scope.sassFileName.length - 4}#{$scope.app.syntax}"

    # Set contents of Sass and CSS files
    files[$scope.sassFileName] =
      content: $scope.app.sass

    files[$scope.cssFileName] =
      content: $scope.app.css

    # if $scope.app.html
    #   if !$scope.htmlFileName
    #     $scope.htmlFileName = "SassMeister-input-HTML.#{$scope.app.htmlSyntax}"

    #   else
    #     filename = $scope.htmlFileName.split '.'
    #     ext = filename.pop()

    #     if ext != $scope.app.htmlSyntax
    #       # HTML syntax has changed, so need to "rename" the file

    #       # First, delete contents of old file
    #       files[$scope.htmlFileName] =
    #         content: null

    #       # Set name of new file, contents will be set later
    #       $scope.htmlFileName = "#{filename.join '.'}.#{$scope.app.htmlSyntax}"

    #   files[$scope.htmlFileName] =
    #     content: $scope.app.html

    #   files[$scope.renderedHtmlFileName] =
    #     content: $scope.app.renderedHtml

    content =
      files: files

    $githubGist($stateParams.id)
      .then (gist) ->
        gist.update content

  $scope.forkGist = ->
    $githubGist($stateParams.id)
      .then (gist) ->
        gist.fork()

