###
    Written by Bryce Summers on Mar.29.2018

    Conditional models allow either accept or reject a given object model depending
    this conditional model's prediated test configuration.
###

class BSS.Condition_Model extends BSS.Model

    ###
    @EQ = "="
    @LE = "<="
    @GE = ">="
    @LT = "<"
    @GT = ">"
    @NE = "!="

    @VAR = 0 # Key is a name of variable to be looked up in the object.
    @CONSTANT = 1 # key is a constant used for being compared to.
    ###

    # String or primitive, variable/constant, comparison operator, key, variable/constant.
    constructor: () ->

        # ((agent) -> true / false)  ---> path_element
        # "left", "up", "right" --> path_element
        # each function leads to a different path if it is satisfied by an agent element.
        @_conditions = []
        @_paths = []

    # Associates the given key value with the given path element.
    associateCondition: (key, val, path_element) ->
        @_conditions.push(key)
        @_paths.push(val)

    getDestination: (agent) ->
        for i in [0...@_conditions.length]
            key = @_conditions[i]
            return @_paths[i] if key(agent)

        throw new Error("No valid conditional path found.")
        return null
        

    ###
    buildModel: () ->

    evaluateObject: (obj) ->

        if @type1 == BSS.Condition_Model.VAR
            val1 = obj.lookup(@key1)
        else # Constant.
            val1 = @key1

        if @type2 == BSS.Condition_Model.VAR
            val2 = obj.lookupKey(@key2)
        else # Constant.
            val2 = @key2

        switch @operator
            when BSS.Condition_Model.EQ then return val1 == val2
            when BSS.Condition_Model.LE then return val1 <= val2
            when BSS.Condition_Model.GE then return val1 >= val2
            when BSS.Condition_Model.LT then return val1 <  val2
            when BSS.Condition_Model.GT then return val1 >  val2
            when BSS.Condition_Model.NE then return val1 != val2
            else console.log("Conditional: " + @operator + " is not defined.")
    ###