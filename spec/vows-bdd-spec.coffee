{Feature} = require "#{__dirname}/../lib"
assert = require "assert"
Sinon = require "sinon"
vows = require "vows"

createSpy = (spyName, error, result) ->
  ctx = this
  ctx[spyName] = stub = Sinon.stub().yields(error, result)
  process.nextTick ->
    stub ctx.callback

Feature("Vows BDD",module)
  .scenario("Testing with vows BDD")
  .given "a setup function", ->
    createSpy.call this, "setupA"
  .and "a second setup function", ->
    createSpy.call this, "setupB"
  .when "a central action is taken", ->
    createSpy.call this, "whenSpy", null, "foo" 
  .then "both 'given' and 'when' functions are called", (err) ->
    assert.isNotNull @setupA
    assert.isNotNull @setupB
    assert.isNotNull @whenSpy
  .and "the 'given' functions are called in order", ->
    assert.isTrue @setupA.calledBefore @setupB
  .and "the 'given' functions are called before the when", ->
    assert.isTrue @setupA.calledBefore @whenSpy
    assert.isTrue @setupB.calledBefore @whenSpy
  .and "the 'given' function passes its results to tests", (err,result) ->
    assert.equal result, "foo"
  .complete()

  .scenario("Vows tdd annotations")
  .given "", ->
    createSpy.call this, "givenA"
  .and "a secondary given exists", ->
    createSpy.call this, "givenB"
  .then "the first Given description should be ignored", (err) ->
    assert.match this.context.title, /Given a secondary given exists/
  .complete()

  .scenario("Scenario title formatting")
  .given "an initial given", ->
    createSpy.call this, "givenA"
  .then "the scenario title should have a colon after it", (err) ->
    assert.match this.context.title, /Scenario title formatting\:/
  .complete()

  .scenario("Given/when/then/and support arguments array")
  .given(["a given args array", -> createSpy.call this, "givenA"])
  .and(["an 'and' args array", -> createSpy.call this, "givenAnd"])
  .when(["a 'when' args array", -> createSpy.call this, "whenA"])
  .then(["a 'then' args array is test", ->
    assert.isTrue true])
  .and "given functions are called in order", (err) ->
    assert.isTrue @givenA.calledBefore @givenAnd
  .and "when functions are called", (err) ->
    assert.isTrue @whenA.calledOnce
  .and "the given title is added properly", (err) ->
    assert.match @context.title, /a given args array/
  .and "the 'and' title is added properly", (err) ->
    assert.match @context.title, /an 'and' args array/
  .and "the 'when' title is added properly", (err) ->
    assert.match @context.title, /a 'when' args array/
  .complete()
  .finish(module)

