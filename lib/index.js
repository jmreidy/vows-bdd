(function() {
  var Feature, Scenario, vows, _;
  var __slice = Array.prototype.slice;

  vows = require("vows");

  _ = require("underscore");

  Feature = function(description) {
    var suite;
    suite = vows.describe(description);
    suite.scenario = function(description) {
      return new Scenario(description, suite);
    };
    suite.finish = function(module) {
      return suite["export"](module);
    };
    return suite;
  };

  Scenario = (function() {

    Scenario.prototype._reduceArray = function(args) {
      var callback, description;
      if (args.length === 1 && Array.isArray(args)) {
        description = args[0][0];
        callback = args[0][1];
        args = [args[0][0], args[0][1]];
      }
      return args;
    };

    Scenario.prototype._lastChild = function(parent) {
      var child, _i, _len, _ref;
      _ref = _.values(parent);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        if (typeof child === "object") return this._lastChild(child);
      }
      return parent;
    };

    Scenario.prototype._hasTests = function(vow) {
      return _.any(_.keys(vow), function(key) {
        return (_.include(["topic", "teardown"], key)) === false;
      });
    };

    Scenario.prototype._addToVows = function(description, newVow) {
      var vow;
      if (this.vows) {
        vow = this._lastChild(this.vows);
      } else {
        vow = this.vows = {};
      }
      return vow[description] = newVow;
    };

    Scenario.prototype._createContext = function(description, callback) {
      this.currentVow = {
        topic: function() {
          callback.apply(this, arguments);
        }
      };
      return this._addToVows(description, this.currentVow);
    };

    Scenario.prototype._needsAnd = function() {
      return this.vows && (_.first(_.keys(this.vows)).match(/,/) !== null);
    };

    function Scenario(description, suite) {
      this.description = "" + description + ":";
      this.suite = suite;
      this.currentVow = {};
      this.batch = {};
    }

    Scenario.prototype.given = function() {
      var args, callback, description, _ref;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      _ref = this._reduceArray(args), description = _ref[0], callback = _ref[1];
      if (description.length > 0) description = "" + description + ", ";
      this._createContext("Given " + description, callback);
      return this;
    };

    Scenario.prototype.when = function() {
      var args, callback, description, _ref;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      _ref = this._reduceArray(args), description = _ref[0], callback = _ref[1];
      this._createContext("When " + description + ", ", callback);
      return this;
    };

    Scenario.prototype.then = function() {
      var args, callback, description, _ref;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      _ref = this._reduceArray(args), description = _ref[0], callback = _ref[1];
      this.currentVow["Then " + description] = callback;
      return this;
    };

    Scenario.prototype.and = function() {
      var args, callback, description, _ref;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      _ref = this._reduceArray(args), description = _ref[0], callback = _ref[1];
      if (this._hasTests(this.currentVow)) {
        this.then("" + description, callback);
      } else {
        if (this._needsAnd()) description = "and " + description;
        this._createContext("" + description + ", ", callback);
      }
      return this;
    };

    Scenario.prototype.complete = function(teardown) {
      if (teardown) this.currentVow["teardown"] = teardown;
      this.batch[this.description] = this.vows;
      this.suite.addBatch(this.batch);
      return this.suite;
    };

    return Scenario;

  })();

  exports.Feature = Feature;

}).call(this);
