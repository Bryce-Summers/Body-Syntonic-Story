###
    Written by Bryce Summers on 10.23.2017
###

class BSS.Operator_Model extends BSS.Model

    constructor: () ->

        # (Object_model) -> enacts a mutation.
        @_mutation_function = null

    buildModel: () ->