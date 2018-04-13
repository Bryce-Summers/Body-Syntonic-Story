###
    Written by Bryce Summers on 10.23.2017

    A model for the statistics of an object.

    This is specific the agents within a particular game.
###

class BSS.Statistics_Model extends BSS.Model

    constructor: () ->

        # FUTURE: add statistics logging.

        # Records describing the values for every variable, including those describing normal events like
        # expressions, thinking, and narration.
        # Also contains values for custom story specific variables like food, courage, etc.
        @_records = {}


        @_narrative = "Press Up Key to begin journey!"
        @_narrativeChanged = true
        @_narrativeType = "narrate"

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

    # Get the type of narrative change. Perhaps I should retitle this 'expression'

    setNarrative: (val) ->
        @_narrative = val
        @_narrativeChanged = true

    setNarrativeType: (type) ->
        @_narrativeType = type

    getNarrativeType: () ->
        return @_narrativeType

    getValue: (name) ->

        val =  @_records[name]
        if val == undefined
            @_records[name] = 0
            val = 0

        return val

    setValue: (name, val) ->
        @_records[name] = val