require 'angular-cookies'

Github = require 'github-api'

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

