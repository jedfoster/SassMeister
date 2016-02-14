getHashParam = (parameter) ->
  query = window.location.hash.substring 1
  params = query.split ','

  for param in params
    [key, value] = param.split '='
    
    return value if key == parameter

  return false


module.exports = getHashParam
# function getHashParam(param) {
#   var query = window.location.hash.substring(1);
#   var vars = query.split(",");
#   for (var i=0;i<vars.length;i++) {
#     var pair = vars[i].split("=");
#     if(pair[0] == param){
#       return pair[1];
#     }
#   }
#   return(false);
# }
