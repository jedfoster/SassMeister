'use strict'

require 'angular'

template = require './_site-header.jade'

angular.module 'SassMeister.siteHeader', []

.directive 'siteHeader', ->
  restrict: 'E'
  template: template
  controller: ($scope, $state, $window) ->
    $scope.showMenuBar = ->
      not $state.includes('application.404') and not $state.includes('application.about')

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


    $scope.rightEdge = (selectors) ->
      className = ''
      elements = []

      unless typeof selector == 'object'
        selectors = [selectors]

      for selector in selectors
        el = document.querySelector selector
        el.style.visibility = 'hidden'
        el.style.display = 'block'

        elements.push el

      targetEl = elements.slice(-1)[0]

      if targetEl.getBoundingClientRect().right >= document.body.getBoundingClientRect().width - 10
        className = 'right'

      for el in elements
        el.style.visibility = null
        el.style.display = null

      className

