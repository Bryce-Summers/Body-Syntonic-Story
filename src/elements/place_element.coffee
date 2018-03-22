#
# Place Elements handle the organization of all place content.
# Place elements only need pointers to those elements that they will change.
#

class BSS.Place_Element extends BSS.Element

    constructor: (model) -> # Why do we pass a model?

        super(model)

        @init()

    init: () ->

        # Specifies the features in a place.
        @_places = new Set() # Pointers to other place Elements.

        # Default is at 0,0 and pointing 0, -1
        @_camera_model = new BSS.Camera_Model()

        # Other elements.
        @_junctions  = new Set()
        @_conditions = new Set()
        @_paths      = new Set()
        @_operators  = new Set()
        @_agents     = new Set()

        @_visual_places     = new THREE.Object3D()
        @_visual_junctions  = new THREE.Object3D()
        @_visual_paths      = new THREE.Object3D()
        @_visual_operators  = new THREE.Object3D()
        @_visual_conditions = new THREE.Object3D()
        @_visual_agents = new THREE.Object3D()

        # An agent's visual representation can be realized within a place right?

        

    # Sets the visual representation of this place.
    # This is used to represent this place in larger places.
    setVisualRepresentation: (visual) ->
        obj = @getVisualRepresentation()
        obj.add(visual)

    # Changes the view to show 
    populateViewLevels: (levels, N) ->

        # Back of screen.
        levels[1].add(@_visual_places)
        levels[1].add(@_visual_junctions)
        levels[2].add(@_visual_paths)
        levels[2].add(@_visual_agents)

        levels[3].add(@_visual_operators)
        levels[3].add(@_visual_conditions)
        # Front of screen.

        ###
        @_places.forEach (element) =>
            levels[1].add(element.getVisualRepresentation())

        @_junctions.forEach (element) =>
            levels[1].add(element.getVisualRepresentation())

        @_paths.forEach (element) =>
            levels[2].add(element.getVisualRepresentation())

        @_operators.forEach (element) =>
            levels[3].add(element.getVisualRepresentation())
        @_conditions.forEach (element) =>
            levels[3].add(element.getVisualRepresentation())
        ###

    # Add and remove elements from this place element.
    addPlace:     (element) ->
        @_places.add(element)
        @_visual_places.add(element.getVisualRepresentation().getVisual())

    addJunction:  (element) ->
        @_junction.add(element)
        @_visual_junctions.add(element.getVisualRepresentation().getVisual())

    addCondition: (element) ->
        @_conditions.add(element)
        @_visual_conditions.add(element.getVisualRepresentation().getVisual())

    addPath:      (element) ->
        @_paths.add(element)
        @_visual_paths.add(element.getVisualRepresentation().getVisual())

    addAgent:     (element) ->
        @_agents.add(element)
        @_visual_agents.add(element.getVisualRepresentation().getVisual())

    addOperator:  (element) ->
        @_operators.add(element)
        @_visual_operators.add(element.getVisualRepresentation().getVisual())


    removePlace:     (element) ->
        @_places.delete(element)
        @_visual_places.remove(element.getVisualRepresentation().getVisual())

    removeJunction:  (element) ->
        @_junction.delete(element)
        @_visual_junctions.remove(element.getVisualRepresentation().getVisual())

    removeCondition: (element) ->
        @_conditions.delete(element)
        @_visual_conditions.remove(element.getVisualRepresentation().getVisual())

    removePath:      (element) ->
        @_paths.delete(element)
        @_visual_paths.remove(element.getVisualRepresentation().getVisual())

    removeAgent:      (element) ->
        @_agents.delete(element)
        @_visual_agents.remove(element.getVisualRepresentation().getVisual())

    removeOperator:  (element) ->
        @_operators.delete(element)
        @_visual_operators.remove(element.getVisualRepresentation().getVisual())


    ### Inputs ###
    time: (dt) ->
        # Updates each path to move the agents along them.
        @_paths.forEach (path) =>
          path.time(dt)

        # FIXME: Should I update agents that are not on a path independantly?