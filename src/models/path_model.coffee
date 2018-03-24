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

        # sorted list of operators that agents will run through.
        # {operator:, percentage:}
        @operators = []

    moveAgents: (dt) ->

        # Iterate through all agents and move them.
        # We go back to front so that agents all respond to their 
        # image of the agent in front of them.
        agent = @last_agent
        percentages_per_meter = 1.0 / @_distance

        # Go through all agents residing along this path, the oldest agent may have a memory of an agent that has since left the path.
        while agent != null and agent.getNavigation().getCurrentLocation() == @

            # remember the percentage that the agent starts at.
            per_start = agent.getPercentage()

            agent.moveAlongPath(dt, percentages_per_meter) # moves agent in percentage space with conversion factor.

            # Now check to see if the agent has moved past an operator event.
            # If so, proccess all operators.
            oper_index = @getNextOperatorIndex(per_start) # {operator:, percentage:}
            if oper_index != null
                oper = @operators[oper_index]
                per_operator = oper.percentage
                per_end = agent.getPercentage()

                # If we've moved past an operation, then perform all operations between its start and end percentage.
                while oper_index < @operators.length and oper.percentage <= per_end
                    agent.operate(oper.operator)
                    oper_index += 1
                    # Next oper.
                    oper = @operators[oper_index]


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
        @last_agent = agent_model

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