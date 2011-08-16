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

  constructor: (description, suite) ->
    @description = description
    @suite = suite
    @currentVow = {}
    @batch = {}

  given: (description, callback) ->
    @_createContext "Given #{description}, ",callback
    return this 

  when: (description, callback) ->
    @_createContext "When #{description}, ",callback
    return this

  then: (description, test) ->
    @currentVow["Then #{description}"] = test
    return this

  and: (description, callback) ->
    if @_hasTests @currentVow
      @then "#{description}", callback
    else
      @_createContext "and #{description}", callback
    return this

  complete: (teardown) ->
    if teardown then @currentVow["teardown"] = teardown
    @batch[@description] = @vows
    @suite.addBatch @batch
    return @suite

exports.Feature = Feature
