Math.guid = ->
  s4 = -> Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1)
  "#{s4()}#{s4()}-#{s4()}-#{s4()}-#{s4()}-#{s4()}#{s4()}#{s4()}"

require 'ngStorage'


# class SessionService

#   setStorage:(key, value) ->
#     json =  if value is undefined then null else JSON.stringify value
#     sessionStorage.setItem key, json

#   getStorage:(key)->
#     JSON.parse sessionStorage.getItem key

#   clear: ->
#     @setStorage(key, null) for key of sessionStorage

#   stateHistory:(value=null) ->
#     @accessor 'stateHistory', value

#   # other properties goes here

#   accessor:(name, value)->
#     return @getStorage name unless value?
#     @setStorage name, value

# angular
# .module 'SassMeister'
# .service 'sessionService', SessionService


class StateHistoryService
  @$inject:['$sessionStorage']
  constructor:(@sessionStorage) ->

  set:(key, state)->
    history = @sessionStorage.stateHistory ? {}
    history[key] = state
    @sessionStorage.stateHistory = history

  get:(key)->
    @sessionStorage.stateHistory?[key]

# angular.module 'SassMeister'
# .service 'stateHistoryService', StateHistoryService



class StateLocationService
  preventCall:[]
  @$inject:['$location','$state', 'stateHistoryService']
  constructor:(@location, @state, @stateHistoryService) ->

  locationChange: ->
    return if @preventCall.pop('locationChange')?
    entry = @stateHistoryService.get @location.url()
    return unless entry?
    @preventCall.push 'stateChange'
    @state.go entry.name, entry.params, {location:false}

  stateChange: ->
    return if @preventCall.pop('stateChange')?
    entry = {name: @state.current.name, params: @state.params}
    #generate your site specific, unique url here
    url = "/#{@state.params.url}/#{Math.guid().substr(0,8)}"
    @stateHistoryService.set url, entry
    @preventCall.push 'locationChange'
    console.log @state.url
    @location.url url

# angular.module 'SassMeister'
# .service 'stateLocationService', StateLocationService

window.StateHistoryService = StateHistoryService
window.StateLocationService = StateLocationService
