'use strict'

require 'angular'

template = require './_site-header.jade'

angular.module 'SassMeister.siteHeader', []

.directive 'siteHeader', ->
  restrict: 'E'
  template: template
  controller: ($scope, $window) ->
    $scope.loggedOut = ->
      !$scope.githubId
    
    $scope.loggedIn = ->
      !!$scope.githubId

    $scope.login = ->
      $window.location.href = '/authorize'

    $scope.logout = ->
      $window.location.href = '/logout'

    
