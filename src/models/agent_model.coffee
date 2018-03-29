###
    Written by Bryce Summers on 10.23.2017

    Objects are agents that try to do stuff. They carry along data, then sleep.

    Objects are responsible for determining when statistics ought to be logged,
    when plans should be created, and for following the rules.

    IDEA: Look up behavior trees.
###


class BSS.Agent_Model extends BSS.Model

    constructor: (@scene) ->

        # Is the object model currently driving a process.
        @active = null

        # A mapping of variable names to values.
        @state = {}
        #state['key'] = val.
        #psychology --> "up, left, right, down." # Characters only think about one thing at a time.
        #speed_multiple --> 0, negative or positive number scaling the default speed.
        #
        @speed = 60 # 1 pixel per second.

        # Controls forwards, stopped, backwards movement and multiples.
        # 1, 0, -1, x2,3,4...
        @speed_multiple = 1
        @age = "adult"
        @protagonist = false

        # Larger processes.
        @statistics = null

        @navigation = null

        # The percentage of the current model that has been transversed.
        @percentage = 0

        @next_agent = null

        @representation = null

        @buildModel()



    buildModel: () ->

        @statistics     = new BSS.Statistics_Model()
        @navigation     = new BSS.Navigation_Model()
        
        # I'm not sure what I was going with here.
        #@representation = new BSS.Representation(@)

        @percentage = 0
        @state = {}
        @active = false

    getNavigation: () ->
        return @navigation

    getStatistics: () ->
        return @statistics

    getPercentage: () ->
        return @percentage

    # returns [BDS.Point, BDS.Point] aka [location, direction of forwards orientation.]
    getCurrentLocationAndHeading: () ->

        # If Our navigation model is locked onto a path, we infer information from them.
        path_model = @navigation.getCurrentLocation()
        if path_model != null and path_model instanceof BSS.Path_Model
            path_element = path_model.getElement()
            return path_element.getLocation(@percentage)

        # Otherwise we just return the current information stored in the element's visual representation.
        return @getElement().getRepresentationLocationAndHeading()

    # FIXME: If the agent overshoots, whose responsibility is it for the transition?
    # The agent model or the path model?
    moveAlongPath: (dt, percentages_per_meter) ->

        psychology = @state["psychology"]
        dPercentage = 0

        # Only move along path if the character is currently thinking about going in a direction.
        if psychology == "up" or psychology == "left" or psychology == "right" # or psychology == "down"
            # Agents operate in meters (pixel) space, but also in percentage space along paths.
            dPercentage = dt*@speed*@speed_multiple*percentages_per_meter # s * (m/s) * (%/m)
        else
            return
        
        @percentage += dPercentage

        # FIXME: Agent should move on to next path if it gets here.
        if @percentage > 1.0
            path_model = @navigation.getCurrentLocation()
            next_path = path_model.getDestination(@)
            if next_path != null # FIXME: Handle Junctions.
                path_model.dequeueAgent(@)
                next_path.enqueueAgent(@)
                @navigation.setCurrentLocation(next_path)
                @percentage = 0.0
            else
                @percentage = 1.0

        # Navigation operates in percentage space.
        #@navigation.move(dPercentage)

        # repositions representation on screen.
        @getElement().reposition()
        return


    #update: (dt) ->        

    # Have the scene pass update commands to this object model.
    activate: () ->
        @scene.activateObject(@)
        @active = true

    deactivate: () ->
        @scene.deactivateObject(@)
        @active = false

    lookupKey: (key) ->
        return @state[key]

    setKey: (key, val) ->
        @state[key] = val
        return

    # The agent that this agent is following.
    # Various checks can be performed based on our memory of that agent.
    getNextAgent: (agent) ->
        return @next_agent

    setNextAgent: (agent) ->
        @next_agent = agent

    # returns model of current location.
    getCurrentLocationModel: () ->
        return @navigation.getCurrentLocation()

    # Mutates this agent based on the operations dictated by the given operator model.
    operate: (operator) ->

        # (Object Model) -> enacts a mutation.
        func = operator.getFunction()
        func(@)
        return

    # Given an integer, sets this agent's speed multiple.
    setSpeed: (speed) ->
        @speed_multiple = speed

    # "infant", "toddler", "adult"    true/false.
    setCharacterType: (age, protagonist) ->
        @age = age
        if protagonist
            @protagonist = true
        else
            @protagonist = false

    isProtagonist: () ->
        return @protagonist