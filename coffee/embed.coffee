# Polyfill for getElementsByClassName for IE7+8
document.getElementsByClassName or (document.getElementsByClassName = (e) ->
  doc = document
  _results = []
  return doc.querySelectorAll("." + e)  if doc.querySelectorAll
  if doc.evaluate
    regex = ".//*[contains(concat(' ', @class, ' '), ' " + e + " ')]"
    elements = doc.evaluate(regex, doc, null, 0, null)

    _results.push i while i = elements.iterateNext()
  else
    elements = doc.getElementsByTagName("*")
    regex = new RegExp("(^|\\s)" + e + "(\\s|$)")

    i = 0
    while i < elements.length
      regex.test(elements[i].className) and _results.push(elements[i])
      i++
  _results
)

SmGistEmbed =
  init: ->
    elements = document.getElementsByClassName('sassmeister')
    t = elements.length - 1

    until t is -1
      data = @extractData(elements[t])
      if data['gist-id']
        url = "http://embed.sassmeister.com/gist/#{data["gist-id"]}#"
        url = "#{url}theme=#{data['theme']}," if data['theme']
        url = "#{url}font-size=#{data['font-size']}," if data['font-size']
        iframe = "<iframe src=\"#{url}\" class=\"sassmeister-gist\" id=\"sm-gist-#{data['gist-id']}\" scrolling=\"no\" frameborder=\"0\" allowTransparency=\"true\" height=\"#{data['height']}\" style=\"width: 100%; overflow: hidden;\"></iframe>"
        @insertIframe(elements[t], iframe)
      t--

  extractData: (element) ->
    attrs = element.attributes
    attrCount = attrs.length
    iteration = 0
    collection = {}

    while iteration < attrCount
      if attr = attrs[iteration].name.match(/data-([\w-]+)/)
        collection[attr[1]] = attrs[iteration].value
      iteration++

    if not collection['height'] or collection['height'] is 'auto'
      collection['height'] = 300

    collection

  insertIframe: (element, iframe) ->
    if element.parentNode
      frameContainer = document.createElement("div")
      frameContainer.innerHTML = iframe
      element.parentNode.replaceChild(frameContainer, element)
    else
      element.innerHTML = iframe

SmGistEmbed.init()
