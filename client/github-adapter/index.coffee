'use strict'

require 'angular'
require 'angular-cookies'

Github = require 'github-api'


buildFrontmatter = (dependencies) ->
  return '' if Object.keys(dependencies).length == 0

  frontmatter = [ '// ----' ]

  if dependencies.libsass
    frontmatter.push "// libsass (v#{dependencies.libsass})"

  else
    frontmatter.push "// Sass (v#{dependencies.Sass})"
    frontmatter.push "// Compass (v#{dependencies.Compass})"

  for name, version of dependencies
    frontmatter.push "// #{name} (v#{version})" unless name.match /(libsass|Sass|Compass)/

  frontmatter.push '// ----'

  "#{frontmatter.join "\n"}\n\n"


angular.module 'github-adapter', [
  'ng'
  'ngCookies'
]

.factory '$githubUser', [
  '$q'
  '$rootScope'
  ($q, $rootScope) ->
    (user) ->
      userPromiseAdapter =
        notifications: ->
          deferred = $q.defer()
          user.notifications (err, data) ->
            $rootScope.$apply ->
              if err
                deferred.reject err
              else
                deferred.resolve data
              return
            return
          deferred.promise
        gists: ->
          deferred = $q.defer()
          user.gists (err, data) ->
            $rootScope.$apply ->
              if err
                deferred.reject err
              else
                deferred.resolve data
              return
            return
          deferred.promise
        orgRepos: (name) ->
          deferred = $q.defer()
          user.orgRepos name, (err, data) ->
            $rootScope.$apply ->
              if err
                deferred.reject err
              else
                deferred.resolve data
              return
            return
          deferred.promise
        orgs: ->
          deferred = $q.defer()
          user.orgs (err, data) ->
            $rootScope.$apply ->
              if err
                deferred.reject err
              else
                deferred.resolve data
              return
            return
          deferred.promise
        repos: ->
          deferred = $q.defer()
          user.repos (err, data) ->
            $rootScope.$apply ->
              if err
                deferred.reject err
              else
                deferred.resolve data
              return
            return
          deferred.promise
        show: (username) ->
          deferred = $q.defer()
          user.show username, (err, data) ->
            $rootScope.$apply ->
              if err
                deferred.reject err
              else
                deferred.resolve data
              return
            return
          deferred.promise
        userGists: (username) ->
          deferred = $q.defer()
          user.userGists username, (err, data) ->
            $rootScope.$apply ->
              if err
                deferred.reject err
              else
                deferred.resolve data
              return
            return
          deferred.promise
        userRepos: (username) ->
          deferred = $q.defer()
          user.userRepos username, (err, data) ->
            $rootScope.$apply ->
              if err
                deferred.reject err
              else
                deferred.resolve data
              return
            return
          deferred.promise
      userPromiseAdapter
]

.factory '$githubGist', [
  '$q'
  '$cookies'
  ($q, $cookies) ->
    (gistId) ->
      github = new Github
        token: $cookies.get 'gh'
        auth: 'oauth'

      gist = github.getGist(gistId)

      gistPromiseAdapter =
        create: (options) ->
          deferred = $q.defer()
          gist.create options, (err, res) ->
            if err
              deferred.reject err
            else
              deferred.resolve res
            return
          deferred.promise
        delete: ->
          deferred = $q.defer()
          gist.delete (err, res) ->
            if err
              deferred.reject err
            else
              deferred.resolve res
            return
          deferred.promise
        fork: ->
          deferred = $q.defer()
          gist.fork (err, gist) ->
            if err
              deferred.reject err
            else
              deferred.resolve gist
            return
          deferred.promise
        read: ->
          deferred = $q.defer()
          gist.read (err, gist) ->
            if err
              deferred.reject err
            else
              deferred.resolve gist
            return
          deferred.promise
        update: (options) ->
          deferred = $q.defer()
          gist.update options, (err, gist) ->
            if err
              deferred.reject err
            else
              deferred.resolve gist
            return
          deferred.promise
      # $q.when()
      gistPromiseAdapter
]


.factory '$sassMeisterGist', [
  '$q'
  '$cookies'
  '$githubGist'
  ($q, $cookies, $githubGist) ->
    create: (scope, cb) ->
      files = {}
      sass = scope.app.sass

      # Remove old frontmatter
      sass = sass.replace(/(^\/\/ [\-]{3,4}\n(?:\/\/ .+\n)*\/\/ [\-]{3,4}\s*)*/, '')

      # Build and prepend frontmatter
      sass = "#{buildFrontmatter scope.app.dependencies}#{sass}"

      files["SassMeister-input.#{scope.app.syntax}"] =
        content: sass

      unless scope.app.css.length == 0
        files['SassMeister-output.css'] =
          content: scope.app.css

      if $scope.app.html
        files["SassMeister-input-HTML.#{$scope.app.htmlSyntax}"] =
          content: $scope.app.html

        files['SassMeister-rendered.html'] =
          content: $scope.app.renderedHTML

      content =
        description: 'Generated by SassMeister.com.'
        files: files

      $githubGist().create(content).then cb

    update: (id, scope, cb) ->
      files = {}
      sass = scope.app.sass

      # Remove old frontmatter
      sass = sass.replace(/(^\/\/ [\-]{3,4}\n(?:\/\/ .+\n)*\/\/ [\-]{3,4}\s*)*/, '')

      # Build and prepend new frontmatter
      sass = "#{buildFrontmatter scope.app.dependencies}#{sass}"

      unless scope.sassFileName.substr(-4, 4) == scope.app.syntax
        # Sass syntax has changed, so need to "rename" the file

        # First, delete contents of old file
        files[scope.sassFileName] =
          content: null

        # Set name of new file, contents will be set later
        scope.sassFileName = "#{scope.sassFileName.substr 0, scope.sassFileName.length - 4}#{scope.app.syntax}"

      # Set contents of Sass and CSS files
      files[scope.sassFileName] =
        content: sass

      files[scope.cssFileName] =
        content: scope.app.css

      if scope.app.html
        if !scope.htmlFileName
          scope.htmlFileName = "SassMeister-input-HTML.#{scope.app.htmlSyntax}"

        else
          filename = scope.htmlFileName.split '.'
          ext = filename.pop()

          if ext != scope.app.htmlSyntax
            # HTML syntax has changed, so need to "rename" the file

            # First, delete contents of old file
            files[scope.htmlFileName] =
              content: null

            # Set name of new file, contents will be set later
            scope.htmlFileName = "#{filename.join '.'}.#{scope.app.htmlSyntax}"

        files[scope.htmlFileName] =
          content: scope.app.html

        files[scope.renderedHtmlFileName] =
          content: scope.app.renderedHTML

      content =
        files: files

      $githubGist(id).update(content).then cb

    fork: (id, cb) ->
      $githubGist(id).fork().then cb
]

