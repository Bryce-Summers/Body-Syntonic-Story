#
# Operators events along paths that perform a mutation within an agent.
# Written by Bryce Summers on Mar.22.2018
# 
# Elements consist of a simple visual depiction.
# Models contain the mutation mathmatics.
#

class BSS.Operator_Element extends BSS.Element

    @variable_names = new Set()
    @variable_icons = {} # Map from names to values.

    # Define a new variable value that will be found in the story.
    @mapVariable: (name, directory) ->
        BSS.Operator_Element.variable_names.add(name)
        BSS.Operator_Element.variable_icons[name] = directory

    @hasVariable: (name) ->
        return BSS.Operator_Element.variable_names.has(name)

    # All agents have to be located on a path.
    constructor: () ->

        super(new BSS.Operator_Model())

        @_path = null
        @_percentage = null

        # Default configuration.
        @buildFromConfiguration()

    setFunction: (func) ->
        @getModel().setFunction(func)

    ### Representation building from path mathmatics. ###
    buildFromConfiguration: () ->
        container = @getVisualRepresentation()

        # Remove all previous sub visual elements from the visual representation.
        container.clearVisuals()

        # Operators have a visual depiction. For now we will just use a circle as default and icons for others.
        model = @getModel()
        type = model.getType()

        size = EX.style.size_operator_icon
        dim = {x:-size/2, y:-size/2, w:size, h:size}
        directory = "assets/images/"
        sprite = directory + "default_operator_icon.png" # Default.

        if type == "narrate"
            sprite = directory + "Narration.png"
        else if type == "say"
            sprite = directory + "expression.png"
        else if type == "think"
            sprite = directory + "mind.png"
        else if type == "good"
            sprite = directory + "happy_face.png"
        else if type == "bad"
            sprite = directory + "sad_face.png"
        else if BSS.Operator_Element.variable_names.has(type)
            sprite = BSS.Operator_Element.variable_icons[type]

        operator_visual = EX.Visual_Factory.newSprite(sprite, dim)
        container.addVisual(operator_visual)

        ###
        number = EX.Visual_Factory.new_label("1")
        number.position.x = -1
        container.addVisual(number)
        ###

        # Brake down character visual into body and legs.
        return

    # Reposition's this operator's representation based on its model.
    # Uses model's location, orientation, and percentage.
    reposition: () ->
        [loc, up] = @getCurrentLocationAndHeading()

        visual = @getVisualRepresentation()
        visual.setPosition(loc)
        visual.setUpDirection(up) # Rotate within the view plane.
        return

    # Provides this operator with a pointer to a path element that it is attached to, if any.
    setPath: (path, percentage) ->
        @_path = path
        @_percentage = percentage

    getCurrentLocationAndHeading: () ->
        return @_path.getLocation(@_percentage)

    # Constructs location and orientation from current representation.
    getRepresentationLocationAndHeading: () ->
        visual = @getVisualRepresentation()
        pos = visual.getPosition()
        loc = new BDS.Point(pos.x, pos.y)
        angle = visual.getRotation()
        dx = Math.cos(angle)
        dy = Math.sin(angle)
        tan = new BDS.Point(dx, dy)

        return [loc, tan]

    ### Element Interface. ###