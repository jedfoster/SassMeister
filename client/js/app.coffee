'use strict'

fontSize = require('./hash-param')('font-size')

if fontSize? and fontSize = fontSize * 100
  document.body.style.fontSize = "#{fontSize}%"

require '../sassmeister'

