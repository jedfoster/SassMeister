'use strict'

require 'angular'
require 'angular-ui-router'
require 'angular-resource'

angular.module 'SassMeister.gist', [
  'ngResource'
  'ui.router'
]

.factory 'Gist', ($resource) ->
  $resource 'http://gist.drft.io/gists/:id.json'

.config ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $locationProvider.html5Mode true

  template = require '../_application.jade'

  $stateProvider
    .state 'application.gist',
      url: '^/gist/:id'
      template: template
      controller: 'ApplicationController'
      resolve:
        data: (Gist, $stateParams, data) ->
          # `$resource` returns a `Resource` object, not a `Promise` like `$http`does.
          # But `Resource` has an equivalent property: `$promise`

          # This shows how you could include resolved data from the parent state.
          # Meh. Not sure how I feel about this. Or even how useful this is.
          _data = data

          Gist.get { id: $stateParams.id }
            .$promise
            .then (data) ->
              sass: data.gist.sass
              css: data.gist.css
              outputStyle: _data.outputStyle

