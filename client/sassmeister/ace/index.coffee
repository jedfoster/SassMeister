config = require '../config'

ace = require 'brace'

require 'brace/mode/css'
require 'brace/mode/sass'
require 'brace/mode/scss'
require 'brace/mode/html'
require 'brace/mode/haml'
require 'brace/mode/jade'
require 'brace/mode/markdown'
require 'brace/mode/textile'
require 'brace/ext/emmet'
require 'brace/keybinding/vim'
require 'brace/theme/dawn'
require 'brace/theme/github'
require 'brace/theme/kuroir'
require 'brace/theme/solarized_light'
require 'brace/theme/tomorrow'
require 'brace/theme/merbivore_soft'
require 'brace/theme/monokai'
require 'brace/theme/solarized_dark'
require 'brace/theme/tomorrow_night_eighties'

require 'angular-ui-ace/src/ui-ace'

require 'angular-load'

aceLoaded = (editor, scope) ->
  session = editor.getSession()

  # Events
  # editor.on 'changeSession', ->
    # no-op

  # session.on 'change', ->
    # no-op

  editor.$blockScrolling = Infinity

  session.setTabSize 2
  session.setUseSoftTabs true

  scope.$watch 'preferences.theme', (value) ->
    editor.setTheme "ace/theme/#{value}"

  scope.$watch 'preferences.vim', (value) ->
    if value
      editor.setKeyboardHandler 'ace/keyboard/vim'
    else
      editor.setKeyboardHandler null

  scope.$watch 'preferences.scrollPastEnd', (value) ->
    editor.setOption 'scrollPastEnd', value

angular.module 'SassMeister.ace', [
  'ui.ace'
  'angularLoad'
]

.controller 'AceSassController', [ '$scope', 'angularLoad', ($scope, angularLoad) ->
  $scope.aceLoaded = (editor) ->
    aceLoaded editor, $scope
    $scope.editor = $scope.editors.sass = editor

  $scope.$watch 'preferences.emmet', (value) ->
    setEmmet = (value) ->
      $scope.editor.setOption 'enableEmmet', value

    if value and not window.emmet
      angularLoad.loadScript 'http://nightwing.github.io/emmet-core/emmet.js'
        .then ->
          setEmmet value

    else
      setEmmet value

    return

  $scope.$watch 'app.syntax', (value) ->
    $scope.editor.getSession().setMode "ace/mode/#{value}"
]

.controller 'AceCssController', [ '$scope', 'angularLoad', ($scope, angularLoad) ->
  $scope.aceLoaded = (editor) ->
    aceLoaded editor, $scope
    $scope.editor = editor
]

