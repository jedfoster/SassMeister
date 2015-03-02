ace = require 'brace'
# require 'brace/mode/css'
# require 'brace/mode/sass'
# require 'brace/mode/scss'
require 'brace/mode/html'
# require 'brace/mode/haml'
# require 'brace/mode/jade'
require 'brace/mode/markdown'
# require 'brace/mode/textile'
# require 'brace/ext/emmet'
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


aceLoaded = (_editor) ->
  # Editor part
  _session = _editor.getSession()
  # _renderer = _editor.renderer

  # Options
  # _editor.setReadOnly true
  
  _editor.setKeyboardHandler 'ace/keyboard/vim'
  
  # Events
  _editor.on 'changeSession', ->
    # no-op
    
  _session.on 'change', ->
    # no-op

theme = () ->
  themes = [
    # 'dawn'
    # 'github'
    # 'kuroir'
    # 'solarized_light'
    'tomorrow'
    # 'merbivore_soft'
    # 'monokai'
    # 'solarized_dark'
    # 'tomorrow_night_eighties'
  ]
 
  themes[Math.floor(Math.random() * themes.length)]


angular.module('SassMeister.ace', [
  'ui.ace'
])

.constant('uiAceConfig',
  ace:
    onLoad: aceLoaded
    onChange: ->
      # no-op
    theme: theme()
)

