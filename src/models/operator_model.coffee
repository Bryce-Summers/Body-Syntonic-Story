###
    Written by Bryce Summers on 10.23.2017
    Updated on Mar.29.2018
###

class BSS.Operator_Model extends BSS.Model

    constructor: () ->

        # (Object_model) -> enacts a mutation.
        @_mutation_function = null

        # "story_Load"
        @_type = "normal"
        @_state = {}

    buildModel: () ->

    setFunction: (func) ->
        @_mutation_function = func

    getFunction: () ->
        return @_mutation_function

    setType: (type) ->
        @_type = type

    getType: () ->
        return @_type

    setState: (key, val) ->
        @_state[key] = val

    getState: (key) ->
        return @_state[key]