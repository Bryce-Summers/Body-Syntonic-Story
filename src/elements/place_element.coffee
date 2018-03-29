#
# Place Elements handle the organization of all place content.
# Place elements only need pointers to those elements that they will change.
#

class BSS.Place_Element extends BSS.Element

    constructor: (@scene) -> #scene is useful.

        super(new BSS.Place_Model)

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
        @_visual_agents     = new THREE.Object3D()

        # An agent's visual representation can be realized within a place right?

        @_story_map = null
        

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

    getScene: () ->
        return @scene

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

    # Sets the storymap for this place,
    # which is used to generate elements and agents.
    setStoryMap: (map) ->
        @_story_map = map

        # Delete other elements?

        # Initialize start of story.
        name = "start"

        @loadStoryBlock(name, null, new BDS.Point(200, 0), new BDS.Point(1, 0))
        return

    loadStoryBlock: (storyName, last_path, position, up_direction) ->

        storyGenerator = @_story_map[storyName]

        # Generate Elements.
        elements = storyGenerator.generateElements(last_path, position, up_direction)

        # Store the list, so they can be deleted when necessary.
        # I guess I can store the list in the deletion operator events.

        # Add the elements to this place.
        for elem in elements
            if elem instanceof BSS.Path_Element
                @addPath(elem)
            else if elem instanceof BSS.Place_Element
                @addPlace(elem)
            else if elem instanceof BSS.Junction_Element
                @addJunction(elem)
            else if elem instanceof BSS.Condition_Element
                @addCondition(elem)
            else if elem instanceof BSS.Agent_Element
                @addAgent(elem)
                # Set Element as focus if it is the protagonist.
                agent_model = elem.getModel()
                if agent_model.isProtagonist()
                    @scene.setFocusAgent(elem)
                    @scene.setFocusPlace(@)
            else if elem instanceof BSS.Operator_Element
                @addOperator(elem)

                # Set load or destroy functions for marked operators
                operator = elem
                model = operator.getModel()
                if model.getType() == "story_load"

                    story_name = model.getState("story_name")
                    last_path  = model.getState("path")
                    [position, up] = last_path.getLocation(1.0)
                    place = @

                    func = (story_name, pathy, position, up) -> ((agent_model) ->
                        place.loadStoryBlock(story_name, pathy, position, up)
                        )

                    model.setFunction(func(story_name, last_path, position, up))

            # FIXME: Add the rest of the types.
        return




    ### Inputs ###
    time: (dt) ->
        # Updates each path to move the agents along them.
        @_paths.forEach (path) =>
          path.time(dt)

        # FIXME: Should I update agents that are not on a path independantly?