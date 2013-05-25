class Injector

  INSTANTIATING = {}

  constructor: ->
    @_dependencies = {}
    @_factories = {}

  value: (name, value) ->
    @_dependencies[name] = value

  service: (name, Class) ->
    @_factories[name] = =>
      @instantiate Class

  factory: (name, factoryMethod) ->
    throw new Error "Factory method has to be a function" unless typeof factoryMethod is "function"
    @_factories[name] = =>
      @invoke factoryMethod

  instantiate: (Class) ->
    throw new Error "Only support constructor function" unless typeof Class is "function"
    dependencies = @_retrieveDependencies Class
    newTarget = ->
      Class.apply @, dependencies
    newTarget:: = Class::
    new newTarget()

  invoke: (func) ->
    func.apply func, @_retrieveDependencies func

  get: (name) ->
    @_mapDependency name

  ### private ###

  _retrieveDependencies: (func) ->
    args = @_getParameters func
    dependencies = (if (args[0] is "") then null else args.map(@_mapDependency, @))
    dependencies

  _getParameters: (Class) ->
    args = @_extractArgumentsString(Class)
    @_trimSpaces(args)

  _extractArgumentsString: (Class) ->
    functionArgumentsRegex = /^function\s*[^\(]*\(\s*([^\)]*)\)/m
    text = Class.toString()
    text.match(functionArgumentsRegex)[1].split ","

  _trimSpaces: (args) ->
    for arg, i in args
      args[i] = arg.replace(/^\s\s*/, "").replace /\s\s*$/, ""
    args

  _mapDependency: (dependencyName) ->
    factory = @_factories[dependencyName]
    dependency = @_dependencies[dependencyName]
    
    throw new Error "Circular dependency detected: #{dependencyName}" if dependency is INSTANTIATING
    
    unless dependency
      throw new Error "#{dependencyName} is not registered" unless factory      
      @_dependencies[dependencyName] = INSTANTIATING
      dependency = factory()
      @_dependencies[dependencyName] = dependency
    dependency

module.exports = Injector