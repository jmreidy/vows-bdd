{Feature} = require "#{__dirname}/../src"
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
  .finish(module)
