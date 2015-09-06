'use strict'

require 'angular'

template = require './_cloud-menu.jade'

angular.module 'SassMeister.cloudMenu', []

.directive 'cloudMenu', ->
  restrict: 'E'
  template: template
  controller: ($scope, $state) ->
    $scope.showUpdateGist = ->
      $scope.loggedIn() and $scope.gist and $scope.canEditGist()

    $scope.showSaveGist = ->
      $scope.loggedIn() and !$scope.gist

    $scope.showForkGist = ->
      $scope.loggedIn() and $scope.gist

    $scope.showLoginToSaveGists = $scope.loggedOut

    $scope.showViewOnGitHub = ->
      !!$scope.gist

    $scope.reset = ->
      $state.go 'application.index',
        reset: true
      ,
        # Force a "reload" of state (does NOT perform a browser reload)
        reload: true

