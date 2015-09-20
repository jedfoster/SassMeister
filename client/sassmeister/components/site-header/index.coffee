'use strict'

require 'angular'

template = require './_site-header.jade'

angular.module 'SassMeister.siteHeader', []

.directive 'siteHeader', ->
  restrict: 'E'
  template: template
  controller: ($scope, $state, $window) ->
    $scope.loggedOut = ->
      !$scope.githubId

    $scope.loggedIn = ->
      !!$scope.githubId

    $scope.login = ->
      $window.location.href = '/authorize'

    $scope.logout = ->
      $window.location.href = '/logout'

    $scope.logoHref = ->
      return 'application.about' if $state.current.name == 'application.index'
      return 'application.index'

