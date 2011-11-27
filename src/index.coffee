vows = require "vows"
_ = require "underscore"

Feature = (description) ->
  suite = vows.describe(description)
  suite.scenario = (description) ->
    new Scenario(description, suite)
  suite.finish = (module) -> 
    suite.export module
  return suite

class Scenario 


  _reduceArray: (args) ->
    if args.length == 1 and Array.isArray(args)
      description = args[0][0]
      callback = args[0][1]
      args = [args[0][0], args[0][1]]
    return args

  _lastChild: (parent) ->
    for child in _.values parent
      if typeof child == "object"
        return @_lastChild child 
    return parent

  _hasTests: (vow) ->
    return _.any (_.keys vow), (key) ->
      (_.include ["topic","teardown"],key) == false

  _addToVows: (description, newVow) ->
    if @vows
      vow = @_lastChild @vows 
    else
      vow = @vows = {}
    vow[description] = newVow

  _createContext: (description,callback) ->
    @currentVow =  
      topic: ->
        callback.apply this, arguments
        return
    @_addToVows description, @currentVow

  _needsAnd: () ->
    @vows and (_.first(_.keys @vows).match(/,/) != null)

  constructor: (description, suite) ->
    @description = "#{description}:"
    @suite = suite
    @currentVow = {}
    @batch = {}

  given: (args...) ->
    [description, callback] = @_reduceArray(args)
    if description.length > 0 then description = "#{description}, "
    @_createContext "Given #{description}",callback
    return this 

  when: (args...) ->
    [description, callback] = @_reduceArray(args)
    @_createContext "When #{description}, ",callback
    return this

  then: (args...) ->
    [description, callback] = @_reduceArray(args)
    @currentVow["Then #{description}"] = callback
    return this

  and: (args...) ->
    [description, callback] = @_reduceArray(args)
    if @_hasTests @currentVow
      @then "#{description}", callback
    else
      if @_needsAnd() then description = "and #{description}"
      @_createContext "#{description}, ", callback
    return this

  complete: (teardown) ->
    if teardown then @currentVow["teardown"] = teardown
    @batch[@description] = @vows
    @suite.addBatch @batch
    return @suite

exports.Feature = Feature
