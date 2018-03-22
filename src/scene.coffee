###
    SimUrban Scene Object.
    Rewritten by Bryce Summers on 10.23.2017
    
    purpose: Organizes my algorithm authoring document system.
             This is the root node of all game initialization, storage, and references.

    NOTE: Objects and places are indistinguishable, except that objects are meant to be temporary,
        whereas places are meant to be eternal.
        Places may spawn objects.
###

class BSS.Scene

    constructor: () ->

        # instantiate the root view of the scene graph.
        @view = new THREE.Scene()

        # Define the overall fields used in the game.
        

        @_view_levels = null

        @_io_root = null # root of input output tool tree.


        # Instantiate Fields, for now using the default process.
        # Also, links up all of the sub models' views to this one.
        @init()

    

    # Instantiates a complete model of the game state.
    init: () ->

        
        # The scene stores all of the element necessary for composing the visible and active modelled part of the game world.
        # individual model components are stores in the places and given direct links to the objects when needed.

        @_objects = new Set() # The set of all objects, both dormant and active.
        @_active_objects = new Set() # Active agents that move according to their desires and rules through the game.

        # The Set of defined places, objects are actually places as well.
        @_places = new Set()
        @_active_places = new Set()

        # Create a set of view levels to handle each of the layers.
        @_view_levels = []
        for i in [1...10]
            level = new THREE.Object3D()
            view.position.z = 1.0 / 10 * i
            @_view_levels.push(view)
            @view.add(level)

    # Changes the game view to the given place.
    # IN: BSS.Place_Element
    setViewToPlace: (place) ->

        # Remove all representations from the view levels.
        for level in @_view_levels
            level.clear()

        place.populateViewLevels(@_view_levels, 10)


    # Here the scene is informed of the root of all of the controllers.
    # It can also extract lots of relevant one's and store them for later.
    setInputRoot: (io_root) ->
        @_io_root = io_root
        @_io_mouse_main = @_io_root.getMouseController()

        # We defer the initialization of the UI until after
        # we have stable pointers to io controllers.
        view = @getVisual()
        @_ui = new BSS.E_UI_Game(@)
        view.add(@_ui.getVisual())


    # Handle Active Object management.

    # Passes an update command to all of the object models.
    update: (dt) ->

        @_active_objects.forEach (obj_model) =>
          obj_model.update(dt)
        return

    activateObject: (obj_model) ->
        @_active_objects.add(obj_model)
        return

    deactivateObject: (obj_model) ->
        @_active_objects.delete(obj_model)
        return

    newObject: (obj_model) ->
        @_objects.add(obj_model)
        return

    destroyObject: (obj_model) ->
        @_objects.delete(obj_model)
        return

    # Places.
    activatePlace: (model) ->
        @_active_places.add(model)

    deactivatePlace: (model) ->
        @_active_places.delete(model)

    addPlace: (model) ->
        @_places.add(model)

    deletePlace: (model) ->
        @_places.delete(model)