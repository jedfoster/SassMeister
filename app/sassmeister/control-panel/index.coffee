'use strict'

require 'angular'
require 'angular-ui-router'

template = require './control-panel.jade'

angular.module('SassMeister.controlPanel', [
  'ui.router'
])

.directive('controlPanel', ->
  restrict: 'E'
  template: template
)

# .controller 'ControlPanelController', ($scope) ->
#   debugger
