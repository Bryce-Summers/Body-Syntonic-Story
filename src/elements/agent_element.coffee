#
# Agent Elements are animated characters on screen.
# Written by Bryce Summers on Mar.21.2018
#

class BSS.Agent_Element extends BSS.Element

    # All agents have to be located on a path.
    constructor: () ->

        super(new BSS.Agent_Model())

        # Default configuration.

        @buildFromConfiguration()

    ### Representation building from path mathmatics. ###
    buildFromConfiguration: () ->
        container = @getVisualRepresentation()

        # Remove all previous sub visual elements from the visual representation.
        container.clearVisuals()

        model = @getModel()

        [loc, up] = model.getCurrentLocationAndHeading()

        # FIXME: Points are not working properly.
        character_visual = EX.Visual_Factory.newPoint(loc, EX.style.c_car_fill, EX.style.radius_agent_default)
        container.addVisual(character_visual)

        # Brake down character visual into body and legs.
        return

    # Reposition's this agent's representation based on its model.
    # Uses model's location, orientation, and percentage.
    reposition: () ->
        [loc, up] = @getModel().getCurrentLocationAndHeading()

        visual = @getVisualRepresentation()
        visual.setPosition(loc)
        visual.setUpDirection(up) # Rotate within the view plane.
        return

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

    