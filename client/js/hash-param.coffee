getHashParam = (parameter) ->
  query = window.location.hash.substring 1
  params = query.split ','

  for param in params
    [key, value] = param.split '='

    return value if key == parameter

  return false

module.exports = getHashParam

