###
    Written by Bryce Summers on 10.23.2017
###

class BSS.Path_Model extends BSS.Model

    # Paths models use a polyline to determind locations and tangents over time
    # and a destination to represent where the path is going.
    # Note: This is decoupled from the path's representation, which could have ornamentation and width.
    constructor: () ->

        # Number of objects that can travel along or be enqueued along this path.
        @_capacity = 1

        # The number of objects currently on the path.
        @_occupancy = 0

        # Cost of using this path.
        @_cost = 1

        @_distance = 1

        # The Model that this path points to.
        @destination = null

        # A Pointer to the Agent model currently transversing the path, that has made the least progress.
        @last_agent = null

        # Adjacent path models. Agents can transfer between them or they can synchronize with others.
        # Unlike agents, paths maintain double linked lists, so that no path is primary.
        # For the sake of the middle lane and determining curvatures, a primary lane would have to be denoted
        # for a story block loader.
        @lane_left  = null
        @lane_right = null

        # sorted list of operators that agents will run through.
        # {operator:, percentage:}
        @operators = []

    # FIXME: Decompose this into sub functions.
    moveAgents: (dt) ->

        # Iterate through all agents and move them.
        # We go back to front so that agents all respond to their 
        # image of the agent in front of them.
        agent = @last_agent
        percentages_per_meter = 1.0 / @_distance

        # Go through all agents residing along this path, the oldest agent may have a memory of an agent that has since left the path.
        while agent != null and agent.getNavigation().getCurrentLocation() == @

            # Don't actively move an agent if it is set to follow a leader companion.
            # This also prevents abundant over updates.
            if agent.lookupKey("psychology") == "follow"
                agent = agent.getNextAgent()
                continue

            # remember the percentage that the agent starts at.
            per_start = agent.getPercentage()
            agent.moveAlongPath(dt, percentages_per_meter) # moves agent in percentage space with conversion factor.
            per_end = agent.getPercentage()

            companions = agent.getAllCompanions()

            # FIXME: This doesn't take into account agents ahead on other paths.
            # Without making any condition checks, synchronize the percentage of the other companions.
            for c in companions
                c.setPercentage(per_end)

            # Process operators for all agents.
            companions.push(agent)
            for c in companions

                # Path model cooresponding to the agent.
                lane = c.getNavigation().getCurrentLocation()

                # Now check to see if the agent has moved past an operator event.
                # If so, proccess all operators.

                oper_index = lane.getNextOperatorIndex(per_start) # {operator:, percentage:}
                if oper_index != null
                    oper = lane.operators[oper_index]
                    per_operator = oper.percentage

                    # If we've moved past an operation, then perform all operations between its start and end percentage.
                    while oper_index < lane.operators.length and oper.percentage <= per_end
                        
                        # Operate on the agent in this lane.
                        agent.operate(oper.operator)

                        # Operate on all companions.
                        #for c in companions
                        #    c.operate(oper.operator)

                        oper_index += 1
                        # Next oper.
                        oper = lane.operators[oper_index]

            # Transion every companion to the next paths.
            if per_end > 1.0

                for agent in companions

                    # If agent moved beyond limit, move it to the next path.
                    navigation = agent.getNavigation()
                    path_model = navigation.getCurrentLocation()
                    next_path  = path_model.getDestination(agent)

                    # Reverts to up psychology after conditional choice.
                    if path_model.endsAtConditional()
                        if agent.lookupKey("psychology") != "follow"
                            agent.setKey("psychology", "up")
                    if next_path != null # FIXME: Handle Junctions.
                        path_model.dequeueAgent(agent)
                        next_path.enqueueAgent(agent)
                        navigation.setCurrentLocation(next_path)

                        ###
                        Ideally we should move the agent through without a hitch, activating all operators along the way,
                        includng the ones on the next path.
                        dist = (per_end - 1.0) / percentages_per_meter
                        per = dist / next_path.length...
                        ###

                        agent.setPercentage(0.0)
                    else
                        agent.setPercentage(1.0)


            agent = agent.getNextAgent()

        return

    setCapacity: (capacity) ->
        @_capacity = capacity

    # The cost in an A* search of transversing this edge.
    setTransversalCost: (cost) ->
        @_cost = cost

    # The distance along this edge, which is used to scale the percentage movements.
    setTransversalLength: (length) ->
        @_distance = length

    # The model that this path point's to.
    # FIXME: conforms to some sort of graph theoretic interface.
    # Path or conditional.
    setDestination : (model) ->
        @destination = model

    # FIXME:
    getDestination : (agent_model) ->

        # Return the relevant path after a conditional.
        if @endsAtConditional()
            return @destination.getDestination(agent_model)

        # Return next path if a single path is coming up.
        return @destination

    endsAtConditional: () ->
        return @destination instanceof BSS.Condition_Model

    getTransversalLength: () ->
        return @_distance

    # Returns true if the path is clear of all objects.
    isClear: () ->
        return @_occupancy == 0

    enqueueAgent: (agent_model) ->

        # Updates' the agent's navigation.
        navigation_model = agent_model.getNavigation()
        navigation_model.setCurrentLocation(@)

        # Enqueues this agent along this path.
        agent_model.setNextAgent(@last_agent)
        agent_model.getElement().reposition()
        @last_agent = agent_model

    # Not actually necessary,
    # because linked list can contain broken links that are no longer on path.
    dequeueAgent: (agent_model) ->


    # returns the next {operator:, percentage:} object or null if none exists.
    getNextOperatorIndex: (percentage) ->
        oper = {operator:null, percentage:percentage}
        lower_bound = BDS.Arrays.binarySearch(@operators, oper, (a, b) -> a.percentage <= b.percentage)

        if lower_bound >= @operators.length - 1
            return null

        return lower_bound + 1

    # Assumed is given an operator model.
    addOperator: (operator, percentage) ->
        
        oper = {operator:operator, percentage:percentage}
        insert_index = BDS.Arrays.binarySearch(@operators, oper, (a, b) -> a.percentage <= b.percentage)

        # I bet there is a much more elegant slicing way of doing this.
        # we are inserting the new oper into the array.
        new_opers = []
        for i in [0..insert_index] by 1
            new_opers.push(@operators[i])

        new_opers.push(oper)

        for i in [insert_index + 1 ...@operators.length] by 1
            new_opers.push(@operators[i])

        @operators = new_opers

        return

    # Lanes are used to tie multiple paths together.
    # Updates a double link.
    setLeftLane: (path) ->
        # unlink.
        if @lane_left != null
            @lane_left.lane_right = null

        # New Link.
        @lane_left = path
        if path != null
            @lane_left.lane_right = @

        return

    # Updates a double link.
    setRightLane: (path) ->

        # unlink.
        if @lane_right != null
            @lane_right.lane_left = null

        # New Link.
        @lane_right = path
        if path != null
            @lane_right.lane_left = @

    # Path model or null
    getLeftLane: () ->
        return @lane_left

    getRightLane: () ->
        return @lane_right

    getAllLanes: () ->
        out = @getAllOtherLanes()
        out.push(@)
        return out

    getFarLeftLane: () ->
        out = @
        while out.getLeftLane() != null
            out = out.getLeftLane()
        return out

    getFarRightLane: () ->
        out = @
        while out.getRightLane() != null
            out = out.getRightLane()
        return out

    # Creates and returns a list of all Lanes, in order.
    getAllOtherLanes: () ->
        left  = @lane_left
        right = @lane_right

        out = []

        # Output all left companions.
        # ASSUMPTION: left and right chains do not create loops.
        while left != null
            out.push(left)
            left = left.getLeftLane()

        while right != null
            out.push(right)
            right = right.getRightLane()

        return out

    # Returns all lanes in order from left to right.
    getAllLanes: () ->

        out = []

        lane = @getFarLeftLane()
        while lane != null
            out.push(lane)
            lane = lane.getRightLane()

        return out