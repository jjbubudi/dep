(function() {
  var Injector;

  Injector = (function() {
    var INSTANTIATING;

    INSTANTIATING = {};

    function Injector() {
      this._dependencies = {};
      this._factories = {};
    }

    Injector.prototype.value = function(name, value) {
      return this._dependencies[name] = value;
    };

    Injector.prototype.service = function(name, Class) {
      var _this = this;

      return this._factories[name] = function() {
        return _this.instantiate(Class);
      };
    };

    Injector.prototype.factory = function(name, factoryMethod) {
      var _this = this;

      if (typeof factoryMethod !== "function") {
        throw new Error("Factory method has to be a function");
      }
      return this._factories[name] = function() {
        return _this.invoke(factoryMethod);
      };
    };

    Injector.prototype.instantiate = function(Class) {
      var dependencies, newTarget;

      if (typeof Class !== "function") {
        throw new Error("Only support constructor function");
      }
      dependencies = this._retrieveDependencies(Class);
      newTarget = function() {
        return Class.apply(this, dependencies);
      };
      newTarget.prototype = Class.prototype;
      return new newTarget();
    };

    Injector.prototype.invoke = function(func) {
      return func.apply(func, this._retrieveDependencies(func));
    };

    Injector.prototype.get = function(name) {
      return this._mapDependency(name);
    };

    /* private
    */


    Injector.prototype._retrieveDependencies = function(func) {
      var args, dependencies;

      args = this._getParameters(func);
      dependencies = (args[0] === "" ? null : args.map(this._mapDependency, this));
      return dependencies;
    };

    Injector.prototype._getParameters = function(Class) {
      var args;

      args = this._extractArgumentsString(Class);
      return this._trimSpaces(args);
    };

    Injector.prototype._extractArgumentsString = function(Class) {
      var functionArgumentsRegex, text;

      functionArgumentsRegex = /^function\s*[^\(]*\(\s*([^\)]*)\)/m;
      text = Class.toString();
      return text.match(functionArgumentsRegex)[1].split(",");
    };

    Injector.prototype._trimSpaces = function(args) {
      var arg, i, _i, _len;

      for (i = _i = 0, _len = args.length; _i < _len; i = ++_i) {
        arg = args[i];
        args[i] = arg.replace(/^\s\s*/, "").replace(/\s\s*$/, "");
      }
      return args;
    };

    Injector.prototype._mapDependency = function(dependencyName) {
      var dependency, factory;

      factory = this._factories[dependencyName];
      dependency = this._dependencies[dependencyName];
      if (dependency === INSTANTIATING) {
        throw new Error("Circular dependency detected: " + dependencyName);
      }
      if (!dependency) {
        if (!factory) {
          throw new Error("" + dependencyName + " is not registered");
        }
        this._dependencies[dependencyName] = INSTANTIATING;
        dependency = factory();
        this._dependencies[dependencyName] = dependency;
      }
      return dependency;
    };

    return Injector;

  })();

  module.exports = Injector;

}).call(this);
