###
#
# Element interface class.
#
# Written by Bryce Summers on 10.23.2017
#
# Elements tie together sets of functional models.
# - Operating model, contains the mathematics of simulation.
# - Visual Representation, specifies the display of this element on screen.
# - Collision Representation, specifies the area or volume that this element takes up on screen.
# - Audio Representation, specifies the audio that this element emits.
#
# Elements are responsible for storing the overarching configuration information and producing representations from it.
###

class BSS.Element

    # Elements need to be passed a model, 
    # because each element has a specific operating model.
    constructor: (@_model) ->

        @_model.setElement(@)

        @_visualRep    = new BSS.Visual_Representation()
        #@_collisionRep = new BSS.Collision_Representation() # We will implement this later.
        @_audioRep     = new BSS.Audio_Representation()

        # Whether a player is allowed to reconfigure this element.
        # Scnario creators can mutate everything,
        # players are constrained by the scenario creator.
        @_mutable = true

        @_configuration = {}

    ###
    Configuration.
    ###

    # Sets this element based on the given configuration.
    # config = {key1:val1, key2: val2, key3:val3, etc.} based on subclass specification.
    setConfiguration: (config) ->
        @_configuration = config

    # True or false, is this element allowed to be modified?
    allowMutations: () ->
        @_mutable = true
        

    ###
    Building.
    ###

    # Rebuilds this element's representations based on its configuration.
    # May modify visual, collision, audio, etc.
    # The idea is that the subclass can modify the internals of the representations,
    # without disturbing their inclusion in their parent's in the scene graph.
    buildFromConfiguration: () ->
        console.log("Please Implement me in subclass!")


    ###
    General Queries.
    ###

    # Returns a copy of this element's configuration values.
    getConfiguration: () ->
        return @_configuration

    # Returns the funcional / computational model of this element.
    # OUTPUT: BSS.Model
    getModel: () ->
        return @_model

    # Returns the representation of this element that will be rendered to the screen.
    # OUTPUT: BSS.Visual_Representation
    getVisualRepresentation: () ->
        return @_visualRep

    # Returns the audio representation of this element.
    # OUTPUT: 
    getAudioRepresentation: () ->
        return @_audioRep

    # Returns an area, associated with this element.
    # This area will be used for 2D plane collision detection.
    # This element may choose to split the areas, such as for long paths, to increase efficiency of 2D BVH.
    # Care must be taken to efficiently manage the hiearchy of BVH's.
    ###
    getCollisionRepresentation: () ->
        console.log("This is not necessary for keyboard input storytelling. It will be more useful for future games, like Sim Urban.")
        throw new Error("Implement me in subclass please!")
    ###


    # UI_Object: Returns a UI object allowing for the configuration of this element.
    getUIWindow: () ->
        console.log("Please Implement me!")