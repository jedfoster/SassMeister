'use strict'

require 'angular'

template = require './_control-panel.jade'

angular.module('SassMeister.controlPanel', [])

.directive('controlPanel', ->
  restrict: 'E'
  template: template
)

