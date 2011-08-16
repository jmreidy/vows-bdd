Vows-bdd
======
Testing with [Vows](http://vowsjs.org) is wonderful. Async-style, full-stack integration tests with
vows is not wonderful. Vows-bdd aims to make long Vows integration tests more 
readable with a given-when-then, fluent syntax. 

If you're interested in a more generalied fluent interface for Vows, checkout
[prenup](https://github.com/jadell/prenup).

Examples
---
Here's a slightly-contrived example of a Vows integration test(written in CoffeeScript):

    vows.describe("Creating a User")
      .addBatch
        "To create a user":

          "Given the server has started":
            topic:
              server.ready, @callback

            "and the DB is populated":
              topic:
                setupFixtures @callback

              "and another setup function is required":
                topic: ->
                  anotherSetup @callback

                "When visiting the form at /user/new":
                  topic: ->
                    ctx = this
                    server.ready ->
                      zombie.visit "http://localhost:#{port}/user/new", ctx.callback
                    return

                  "then should allow entry of a username": (err,browser,status) ->
                    assert.ok browser.querySelector ":input[name=username]"

                  "should allow entry of first and last name": (err,b,s) ->
                    assert.ok b.querySelector ":input[name=firstName]"
                    assert.ok b.querySelector ":input[name=lastName]"

                  "should allow entry of a password": (err,b,s) ->
                    assert.ok b.querySelector ":input[name=password]"

                  "should allow confirmation of a password": (err,b,s) ->
                    assert.ok b.querySelector ":input[name=passwordConfirm]"

                  "and submitting the form":
                    topic: (browser,status) ->
                      browser.fill("username", "test")
                             .fill("firstName", "Justin")
                             .fill("lastName", "Reidy")
                             .fill("password", "foobar")
                             .fill("password", "foobar")
                             .pressButton "Sign Up!", @callback

                    "should create a new User": (err,browser,status) ->
                      assert.ok findNewUser()

            .export module

Here's the same integration test, with vows-bdd:

    Feature("Creating a User")
      .scenario("Create a User via Form")

      .given "the server is running", ->
        server.ready @callback

      .and "the DB is popuplated", ->
        setupFixtures @callback

      .and "another setup function is called", ->
        anotherSetup @callback

      .when "I visit the form at user/new", ->
        zombie.visit "http://localhost:#{port}/user/new", @callback

      .then "I should see a username field", (err,browser,status) ->
        assert.ok browser.querySelector ":input[name=username]"

      .and "I should see entries for first and last name", (err,browser,status) ->
        assert.ok browser.querySelector ":input[name=firstName]"
        assert.ok browser.querySelector ":input[name=lastName]"

      .and "I should see a password entry", (err,browser,status) ->
        assert.ok browser.querySelector, ":input[name=password]"

      .and "I should see a password confirmation", (err,browser,status) ->
        assert.ok browser.querySelector, ":input[name=passwordConfirm]"

      .when "I submit the form", (browser,status) ->
        browser.fill("username", "test")
               .fill("firstName", "Justin")
               .fill("lastName", "Reidy")
               .fill("password", "foobar")
               .fill("password", "foobar")
               .pressButton "Sign Up!", @callback

      .then "a new User should be created", (err,browser,status) ->
        assert.ok findNewUser()

      .complete()
      .finish(module)

API
-------

vows-bdd works by simply constructing the vows' nested object structure
for you:

    Feature(name)
Creates and returns a Vows suite

Calling `scenario(batchName)` on the returned Vows suite provides access
to a Scenario object, which wraps a Vows batch.

    given(string,callback) 
Creates a topic object

    when(string,callback)
Also creates a topic object. It's expected that the values returned from
this callback function will be the ones used for tests, although it's not 
necessary.

    then(string,callback)
Adds Vows tests to the current topic object

    and(string,callback)
Adds either a new topic object (after `given` or `when` calls) or a new test
(after a `then` call).

    complete(teardown)
Closes the current batch and supplies an optional teardown function

    finish(module)
Exports the test suite
