'use strict'

require 'angular'

angular.module 'SassMeister.carbonAd', []

.directive 'carbonAd', ->
  restrict: 'E'
  link: (scope, element, attrs, controller) ->
    return if document.documentElement.clientWidth < 480

    src = '//cdn.carbonads.com/carbon.js?zoneid=1673&serve=C6AILKT&placement=sassmeister'

    s = document.createElement 'script'
    s.setAttribute 'src', src
    s.id = '_carbonads_js'

    element.append s

