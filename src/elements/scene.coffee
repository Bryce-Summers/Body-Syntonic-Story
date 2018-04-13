###
    SimUrban Scene Object.
    Rewritten by Bryce Summers on 10.23.2017
    
    purpose: This is the root node of all game initialization, storage, and references.

    NOTE: Agents and places are indistinguishable, except that agents are meant to be temporary,
        whereas places are meant to be eternal.
        Places may spawn agents.

    Scenes provide a global interface that handles settings, output related to the focus, and global game messages.
    
###

class BSS.Scene

    constructor: () ->

        # instantiate the root view of the scene graph.
        @root_visual = new THREE.Scene()

        @view = new THREE.Object3D()
        @view.name = "Scene view."
        @overlays = new THREE.Object3D()
        @overlays.position.z = 1.0 # Display overlays over top of all other layers. the overlays will be a non moving HUD.
        @overlays.name = "Overlays."
        
        @pivot = new THREE.Object3D() # Used so that the view can be rotated around an arbitrary center of rotation.
        @pivot.add(@view)

        @root_visual.add(@overlays)
        @root_visual.add(@pivot)
      

        # Define the overall fields used in the game.
        @_view_levels = null

        @_io_root = null # root of input output tool tree.


        # Instantiate Fields, for now using the default process.
        # Also, links up all of the sub models' views to this one.
        @init()

        @init_scene_ui()

    getVisualRepresentation: () ->
        return @root_visual

    # Translates center of view to origin.
    getView: () ->
        return @view

    # Rotates view around origin, then translates it to camera.
    getPivot: () ->
        return @pivot

    # Instantiates a complete model of the game state.
    init: () ->

        
        # The scene stores all of the element necessary for composing the visible and active modelled part of the game world.
        # individual model components are stores in the places and given direct links to the objects when needed.

        @_agents = new Set() # The set of all agents, both dormant and active.
        @_active_agents = new Set() # Active agents that move according to their desires and rules through the game.
        @_focus_agent = null # The agent used for locating the camera.

        # The Set of defined places, agents are actually places as well.
        @_places = new Set()
        @_active_places = new Set()
        @_focus_place = null # The place that defines the primary universe depicted on screen whose camera model is used.


        # Create a set of view levels to handle each of the layers.
        @_view_levels = []
        for i in [1...10]
            level = new THREE.Object3D()

            level.position.z = 1.0 / 10 * i
            @_view_levels.push(level)
            @view.add(level)

    init_scene_ui: () ->
        @_ui = new EX.UI(1.0)
        @overlays.add(@_ui.getVisualRepresentation().getVisual())

        @ui_elements = {}

    # returns [BSS.UI object, {ui_element_names}]
    # Provides external classes with full responsibility for updating UI components, and adding new ones.
    getUI: () ->
        return [@_ui, @ui_elements]

    # Changes the game view to the given place.
    # IN: BSS.Place_Element
    setViewToPlace: (place) ->

        # Remove all representations from the view levels.
        for level in @_view_levels
            while level.children.length > 0
                level.children.pop()

        place.populateViewLevels(@_view_levels, 10)


    # Here the scene is informed of the root of all of the controllers.
    # It can also extract lots of relevant one's and store them for later.
    setInputRoot: (io_root) ->
        @_io_root = io_root
        @_io_mouse_main = @_io_root.getMouseController()

        # We defer the initialization of the UI until after
        # we have stable pointers to io controllers.
        ###
        view = @getVisual()
        @_ui = new BSS.E_UI_Game(@)
        view.add(@_ui.getVisual())
        ###


    # Handle Active Object management.

    # Passes time input down to all of the sub elements.
    time: (dt) ->

        # Input commands are handled in elements, which then locally communicate to models.
        @_active_places.forEach (place) =>
          place.time(dt)
        return

    activateAgent: (agent) ->
        @_active_agents.add(agent)
        return

    deactivateAgent: (agent) ->
        @_active_objects.delete(agent)
        return

    newAgent: (agent) ->
        @_agents.add(agent)
        return

    destroyAgent: (agent) ->
        @_agents.delete(agent)
        return

    setFocusAgent: (agent) ->
        @_focus_agent = agent

    getFocusAgent: () ->
        return @_focus_agent

    setFocusPlace: (place) ->
        @_focus_place = place

    getFocusPlace: () ->
        return @_focus_place

    # Places.
    activatePlace: (element) ->
        @_active_places.add(element)

    deactivatePlace: (element) ->
        @_active_places.delete(element)

    addPlace: (element) ->
        @_places.add(element)

    deletePlace: (element) ->
        @_places.delete(element)

    addOverlay: (obj, layer_index) ->
        view = @_view_levels[layer_index]
        view.add(obj)