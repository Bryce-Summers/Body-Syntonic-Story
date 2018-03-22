#
# Path elements are polylines on screen.
#

class BSS.Path_Element extends BSS.Element

    # BSS.Path_Model, BDS.Polyline
    constructor: (mid_line) ->

        super(new BSS.Path_Model())

        @mid_line = mid_line

        # cumulative percentages and tangents, can be used to compute percentage based locations and tangents.
        @partial_distances = @mid_line.computeCumulativeLengths()
        @getModel().setTransversalLength(@partial_distances[@partial_distances.length - 1])
        @tangent_angles = @mid_line.computeTangentAngles()

        # Copy the last value. # FIXME: Think about the specifics of how we discretize the tangent metric.
        @tangent_angles.push(@tangent_angles[@tangent_angles.length - 1])

        @buildFromConfiguration()

    ### Representation building from path mathmatics. ###
    buildFromConfiguration: () ->
        container = @_visualRep

        # Remove all previous sub visual elements from the visual representation.
        container.clearVisuals()

        path_visual = EX.Visual_Factory.newPath(@mid_line, EX.style.radius_path_default, EX.style.c_road_fill, true)
        container.addVisual(path_visual)
        return

        # FIXME: 

    ### Element Interface. ###

    # Returns a BDS.Point representing the location a given percentage of the way along the path.
    # Also returns a tangent direction to specify the orientation of the object along the path.
    # float -> [BDS.Point, BDS.Point]
    getLocation: (percentage) ->
        partial_distance = percentage*@getModel().getTransversalLength()
        highest_le_index = BDS.Arrays.binarySearch(@partial_distances, partial_distance, (a, b) -> a <= b)

        len = @mid_line.size() # number of control points.

        # Determine the two indices that we will interpolated between.
        i0 = highest_le_index
        i0 = len - 2 if i0 == len - 1
        i1 = i0 + 1
         
        # partial_distances.
        pd0 = @partial_distances[i0]
        pd1 = @partial_distances[i1]

        # local percentage between interpolators.
        per = (partial_distance - pd0)/(pd1 - pd0)

        pt0 = @mid_line.getPoint(i0) ## FIXME
        pt1 = @mid_line.getPoint(i1)

        # tangent angles.
        ang0 = @tangent_angles[i0]
        ang1 = @tangent_angles[i1]

        # Linearly interpolate final tangent and location.
        #BDS.Math.lerp = (from, to, percentage) ->
        tangent_angle = BDS.Math.lerp(ang0, ang1, per)
        location = pt0.multScalar(1.0 - per).add(pt1.multScalar(per))

        tx = Math.cos(tangent_angle)
        ty = Math.sin(tangent_angle)
        tangent = new BDS.Point(tx, ty)

        return [location, tangent]

    # Adds an agent to the beginning of this path.
    addAgent: (agent) ->
        path_model = @getModel()
        path_model.enqueueAgent(agent.getModel())

    addOperator: (operator, percentage) ->
        path_model = @getModel()
        path_model.addOperator(operator, percentage)


    ### Inputs ###
    time: (dt) ->

        @getModel().moveAgents(dt)
