###
    Written by Bryce Summers on 10.23.2017

    A model for the statistics of an object.

    This is specific the agents within a particular game.
###

class BSS.Statistics_Model extends BSS.Model

    constructor: () ->

        # FUTURE: add statistics logging.

        @_food = 0
        @_foodChanged = true

        @experiences = 0
        #@thinking = 0

        @_narrative = "Press Up Key to begin journey!"
        @_narrativeChanged = true

    buildModel: () ->

    ###
    Food.
    ###

    # Returns true iff the food value has changed.
    foodChanged: () ->
        if @_foodChanged
            @_foodChanged = false
            return true
        return false

    getFood: () ->
        return @_food

    setFood: (val) ->
        @_food = val
        @_foodChanged = true

    ###
    Narration. Controls the text that represent's this agent's current inner narrative.
    ###
    # Returns true iff the food value has changed.
    narrativeChanged: () ->
        if @_narrativeChanged
            @_narrativeChanged = false
            return true
        return false

    getNarrative: () ->
        return @_narrative

    setNarrative: (val) ->
        @_narrative = val
        @_narrativeChanged = true