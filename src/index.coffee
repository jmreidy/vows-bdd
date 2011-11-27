# **vows-bdd** presents a set of wrappers for the core functionality of 
# [vows](http://www.vowsjs.org), allowing for a traditional `given/when/then` 
# style of writing integration tests for node.js.

vows = require "vows"
_ = require "underscore"

# ###Feature
# The interface through which one creates vows-bdd tests is the `Feature`. 
# Features are written fluently, chaining together `given/when/then` calls. 
# When the entire Feature test is complete (ie all batches have been added), 
# `finish` should be called on the feature. The result looks like the
# following:
#
#     Feature("A vows-bdd test")
#     .scenario("a test batch")
#     .given("a given condition", givenFunction)
#     .when("a when condition", whenFunction)
#     .and("a joined when condition", when2Function)
#     .then("a test assertion")
#     .complete()
#     .finish(module)
#
Feature = (description) ->
  suite = vows.describe(description)
  suite.scenario = (description) ->
    new Scenario(description, suite)
  suite.finish = (module) -> 
    suite.export module
  return suite

# ### Scenario
# Each `batch` of vows tests are encapsulated in a `Scenario`. Test topics
# are created with `given` and `when` function calls; `then` calls create test
# assertions. The meaning of `and` depends upon its placement within the
# vows-bdd scenario; `and` after `given` or `when` creates a topic, while `and`
# after `then` creates a test assertion. 
#
# `given`,`when`,`then`, and `and` have the same method signatures. The
# funcition can be called by providing a text description and the test
# function, or it can be called by provided a two-element array, with the first
# element being a text description and the second being the test function. This
# secondary method signature is useful for DRY-ing repetitive test code. For
# example, a method could be used to simplify repetitive integration steps:
#
#     I_login_as = (user_type) ->
#     ...logic
#     return ["I login as a #{user_type}", login_function]
#
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

  # Main constructor for `Scenarios` 
  constructor: (description, suite) ->
    @description = "#{description}:"
    @suite = suite
    @currentVow = {}
    @batch = {}

  # Create a topic. Called with either a description and topic function, or an
  # array with the description as the first element and the topic function as
  # the second element. The description is prefaced by "Given ".
  given: (args...) ->
    [description, callback] = @_reduceArray(args)
    if description.length > 0 then description = "#{description}, "
    @_createContext "Given #{description}",callback
    return this 

  # Create a topic (or subtopic). Called with either a description and topic function, or an
  # array with the description as the first element and the topic function as
  # the second element. The description is prefaced by "When ".
  when: (args...) ->
    [description, callback] = @_reduceArray(args)
    @_createContext "When #{description}, ",callback
    return this

  # Create a test function. Called with either a description and topic
  # function, or an array with the description as the first element and the
  # topic function as the second. The description is prefaced by "Then ".
  then: (args...) ->
    [description, callback] = @_reduceArray(args)
    @currentVow["Then #{description}"] = callback
    return this

  # Depending on context, either creates a new topic or new test. Called with
  # either a description and topic function, or an array with the description
  # as the first element and the function as the second element. `Ands` that
  # create topic functions with preface the function with "and ".
  and: (args...) ->
    [description, callback] = @_reduceArray(args)
    if @_hasTests @currentVow
      @then "#{description}", callback
    else
      if @_needsAnd() then description = "and #{description}"
      @_createContext "#{description}, ", callback
    return this

  # Close out the current `Scenario` / test batch. Takes an optional teardown
  # function.
  complete: (teardown) ->
    if teardown then @currentVow["teardown"] = teardown
    @batch[@description] = @vows
    @suite.addBatch @batch
    return @suite

exports.Feature = Feature
