###
    Written by Bryce Summers on 10.23.2017

    A model for the navigation of an object.

    This handles all of the logic for location and the creation of plans.
    Objects determine when to plan.
###

class BSS.Navigation_Model extends BSS.Model

    # BSS.Model starting point, and desired destination point.
    constructor: () ->

        # a Pointer to the model that this navigation is currently at.
        # path_model
        @current_location_model = null
        @destination = null

        # The next parts of the plan come straight off the stack.
        @plan_stack = []

        # The transversed parts of the plan go onto this stack.
        @finished_plan_stack = []

        #@buildModel()

        #@heading = 1 # 0 - left, 1 - straight, 2 - right?


    # Returns [location, direction of forwards orientation]
    getCurrentLocation: () ->
        return @current_location_model

    setCurrentLocation: (path_model) ->
        @current_location_model = path_model

    setDestination: (path_model) ->
        @destination = path_model

    # Performs an A* search to update this navigation model
    # with an efficient path from its current location to its destination.
    # If this is a conditional path, then a path made not become apparent.
    # Returns True if a complete plan has been worked out, false otherwise.
    # Objects are responsible for only planning when sensible.
    updatePlan: () ->