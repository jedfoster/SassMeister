SmGistEmbed =
  init: ->
    elements = document.getElementsByClassName('sassmeister')
    t = elements.length - 1

    until t is -1
      data = @extractData(elements[t])
      if data['gist-id']
        url = "{%& embed_domain %}/gist/#{data["gist-id"]}#"
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
