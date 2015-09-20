'use strict'

config = require '../config'

require 'angular'
require 'angular-resource'
require 'angular-load'

angular.module 'SassMeister.sandbox', [
  'ngResource'
  'angularLoad'
]

.factory 'sandboxServer', ($resource) ->
    $resource config.sandbox, {}

.factory 'Sandbox', [
  'sandboxServer'
  'angularLoad'
  (sandboxServer, angularLoad) ->

    updateIframe = (css, html, reset) ->
      if reset?
        newContent = reset: true

      else
        newContent =
          css: css
          html: html

      document.getElementById('rendered-html')
        .contentWindow
        .postMessage(JSON.stringify(newContent), '*')

    html: (app) ->
      updateIframe app.css, app.html

    haml: (app) ->
      sandboxServer.save {
        input: app.html
        syntax: 'haml'
      }
      .$promise.then (data) ->
        updateIframe app.css, data.html

    markdown: (app) ->
      sandboxServer.save {
        input: app.html
        syntax: 'markdown'
      }
      .$promise.then (data) ->
        updateIframe app.css, data.html

    textile: (app) ->
      sandboxServer.save {
        input: app.html
        syntax: 'textile'
      }
      .$promise.then (data) ->
        updateIframe app.css, data.html

    jade: (app) ->
      renderJade = ->
        html = window.jade.render(app.html, {pretty: true})
        updateIframe app.css, html

      unless window.jade
        angularLoad.loadScript 'https://cdn.rawgit.com/jadejs/jade/1.11.0/jade.js'
          .then ->
            do renderJade

      else
        do renderJade

    render: (app) ->
      @[app.htmlSyntax] app

    reset: ->
      updateIframe null, null, true
]

