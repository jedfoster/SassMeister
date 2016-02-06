module.exports =
  storageDefaults: ->
    return {
      app:
        sass: ''
        css: ''
        html: ''
        outputStyle: 'expanded'
        compiler: '3.4'
        syntax: 'scss'
        originalSyntax: 'scss'
        htmlSyntax: 'html'
        dependencies: {}

      preferences:
        theme: 'tomorrow'
        emmet: false
        vim: false
        scrollPastEnd: true
        autoprefixer: false
        autoprefixerBrowsers: '> 1%, last 2 versions'
        orientation: 'horizontal'
        sassResizable: null
        cssResizable: null
        sandboxResizable: null
        cssVisible: true
        htmlVisible: false
    }

  _themes: [
    'dawn'
    'github'
    'kuroir'
    'solarized_light'
    'tomorrow'
    'merbivore_soft'
    'monokai'
    'solarized_dark'
    'tomorrow_night_eighties'
  ]

  themes: ->
    themes = {}
    for theme in @_themes
      themes[theme] = theme.replace(/_/g, ' ').split(' ').map( (i) ->
        i[0].toUpperCase() + i.substring(1)
      ).join ' '
    themes

  outputStyles: [
    'expanded'
    'nested'
    'compact'
    'compressed'
  ]

  sandbox: 'http://sandbox.sassmeister.dev'

