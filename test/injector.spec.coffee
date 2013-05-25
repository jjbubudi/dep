Injector = require "../src/injector"

describe "Injector test suite", ->

  injector = null

  beforeEach ->
    injector = new Injector()

  describe "Inject into classes", ->
    it "should instantiate the correct type of object", ->
      class EmptyClass
      retrievedObject = injector.instantiate EmptyClass
  
      expect(retrievedObject instanceof EmptyClass).toBe true
  
  
    it "should inject values correctly", ->
      class ValueClass
        constructor: (@someValue) ->
  
      injector.value "someValue", "12345"
      valueObject = injector.instantiate ValueClass
      
      expect(valueObject.someValue).toBe "12345"
  
  
    it "should inject services correctly", ->
      class A
      class B
        constructor: (@objectA) ->
  
      injector.service "objectA", A
      objectB = injector.instantiate B
      
      expect(objectB.objectA instanceof A).toBe true
  
  
    it "should instantiate two different instances of the same Class", ->
      class A
      first = injector.instantiate A
      second = injector.instantiate A
  
      expect(first).not.toBe second
  
  
    it "should return registered value", ->
      injector.value "myName", "myValue"
      expect(injector.get "myName").toEqual "myValue"
  
  
    it "should return registered class", ->
      class A
      injector.service "a", A
      objectA = injector.get "a"
      expect(objectA instanceof A).toBe true
  
  
    it "should return registered class even if it has dependencies", ->
      class A
      class B
      class C
        constructor: (@a, @b) ->
  
      injector.service "a", A
      injector.service "b", B
      injector.service "c", C
      objectC = injector.get "c"
  
      expect(objectC instanceof C).toBe true
      expect(objectC.a instanceof A).toBe true
      expect(objectC.b instanceof B).toBe true
  
  
    it "should return the same instance even if get() is called twice", ->
      class A
      injector.service "a", A
      a1 = injector.get "a"
      a2 = injector.get "a"
      
      expect(a1).toBe a2
    
  
  describe "Error handling", ->
    it "should throw error when dependency is not registerted", ->
      class ErrorClass
        constructor: (@someValue) ->
  
      expect(-> injector.instantiate ErrorClass).toThrow()
  
  
    it "should throw error when circular dependency is detected", ->
      class A
        constructor: (@b) ->
      class B
        constructor: (@a) ->
      
      injector.service "a", A
      injector.service "b", B
      
      expect(-> injector.get "a").toThrow("Circular dependency detected: a")
      
    
    it "should not treat normal {} as circular dependency", ->
      class A
        constructor: (@b) ->
        
      injector.service "a", A
      injector.value "b", {}
      
      expect(-> injector.get "a").not.toThrow()