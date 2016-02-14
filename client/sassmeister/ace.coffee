config = require './config'

ace = require 'brace'

require 'brace/mode/css'
require 'brace/mode/sass'
require 'brace/mode/scss'
require 'brace/mode/html'
require 'brace/mode/haml'
require 'brace/mode/jade'
require 'brace/mode/markdown'
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

themeParam = require('../js/hash-param')('theme')

aceLoaded = (editor, scope) ->
  session = editor.getSession()

  # Events
  # editor.on 'changeSession', ->
    # no-op

  # session.on 'change', ->
    # no-op

  editor.$blockScrolling = Infinity
  editor.commands.bindKeys({"Command-S": scope.commandS})
  editor.commands.bindKeys({"Shift-Command-S": scope.shiftCommandS})

  session.setTabSize 2
  session.setUseSoftTabs true

  if themeParam
    editor.setTheme "ace/theme/#{themeParam}"

  else
    scope.$watch 'preferences.theme', (value) ->
      editor.setTheme "ace/theme/#{value}"

  scope.$watch 'preferences.vim', (value) ->
    if value
      editor.setKeyboardHandler 'ace/keyboard/vim'
    else
      editor.setKeyboardHandler null

  scope.$watch 'preferences.scrollPastEnd', (value) ->
    editor.setOption 'scrollPastEnd', value

  scope.$watch 'tabView', ->
    editor.resize true


loadEmmet = (scope) ->
  scope.$watch 'emmet', (value) ->
    scope.editor.setOption 'enableEmmet', value

    return


angular.module 'SassMeister.ace', [
  'ui.ace'
]

.controller 'AceSassController', [ '$scope', ($scope) ->
  $scope.aceLoaded = (editor) ->
    aceLoaded editor, $scope
    $scope.editor = $scope.editors.sass = editor

  loadEmmet $scope

  $scope.$watch 'app.syntax', (value) ->
    $scope.editor.getSession().setMode "ace/mode/#{value}" if value
]

.controller 'AceCssController', [ '$scope', ($scope) ->
  $scope.aceLoaded = (editor) ->
    aceLoaded editor, $scope
    $scope.editor = editor

    # Disable prefix validation
    # http://stackoverflow.com/questions/12886857/how-can-i-disable-the-syntax-checker-in-ace-editor
    $scope.editor.getSession().setUseWorker(false)
]

.controller 'AceHtmlController', [ '$scope', ($scope) ->
  $scope.aceLoaded = (editor) ->
    aceLoaded editor, $scope
    $scope.editor = $scope.editors.html = editor

    # Disable DOCTYPE validation
    # http://stackoverflow.com/questions/12886857/how-can-i-disable-the-syntax-checker-in-ace-editor
    $scope.editor.getSession().setUseWorker(false)

  loadEmmet $scope

  $scope.$watch 'app.htmlSyntax', (value) ->
    $scope.editor.getSession().setMode "ace/mode/#{value}" if value
]
