'use strict'

require 'angular'
require 'angular-resource'

angular.module('SassMeister.compiler', [
  'ngResource'
])

.factory 'Compiler', ($resource) ->
  $resource 'app/3.4/compile', null,
    'compile':
      method: 'POST'

