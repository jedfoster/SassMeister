'use strict'

require 'angular'
require 'angular-resource'

angular.module 'SassMeister.compiler', [
  'ngResource'
]

.factory 'Compiler', ($resource) ->
  $resource '/app/:compiler/:action', {
      compiler: '@compiler'
    },
    'compile':
      method: 'POST'
      params:
        action: 'compile'
    'convert':
      method: 'POST'
      params:
        action: 'convert'
    'extensions':
      method: 'GET'
      params:
        action: 'extensions'
    'compilers':
      method: 'GET'
      params:
        action: 'compilers'

