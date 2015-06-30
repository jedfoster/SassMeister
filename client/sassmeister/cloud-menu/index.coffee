'use strict'

require 'angular'

template = require './_cloud-menu.jade'

angular.module 'SassMeister.cloudMenu', []

.directive 'cloudMenu', ->
  restrict: 'E'
  template: template
  controller: ($scope) ->
    $scope.showUpdateGist = ->
      $scope.loggedIn() and $scope.gist and $scope.canEditGist()

    $scope.showSaveGist = ->
      $scope.loggedIn() and !$scope.gist

    $scope.showForkGist = ->
      $scope.loggedIn() and $scope.gist

    $scope.showLoginToSaveGists = $scope.loggedOut

    $scope.showViewOnGitHub = ->
      !!$scope.gist

