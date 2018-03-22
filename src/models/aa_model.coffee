###
#
# Model Interface Class.
# This specifies properties of all element objects.
#
# Written by Bryce Summers on 10.23.2017
###

class BSS.Model

    constructor: () ->

        # UI for configuring this model.
        @_ui = null

    # Returns a list of [Element, float] neighboring destinations and costs.
    listNeighbors: () ->

        console.log("Please Implement me!")

    # Element -> Float, returns a heuristic of the cost to get to the given element.
    heuristicTo: (element) ->
        console.log("Please Implement me!")

    # Returns a BDS.Point representing this element's location.
    # All three dimensions can be used to inform the representations used, such as shadows off the ground.
    getLocation: () ->
        console.log("Please Implement me!")

    # Should be called automatically by any element.
    setElement: (element) ->
        @_element = element

    getElement: () ->
        return @_element