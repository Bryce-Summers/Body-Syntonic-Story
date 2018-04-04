###
    Written by Bryce Summers on 10.23.2017

    Objects are agents that try to do stuff. They carry along data, then sleep.

    Objects are responsible for determining when statistics ought to be logged,
    when plans should be created, and for following the rules.

    Objects do not actively update themselves, 
    but rather they passively receive updates from classes such as paths that manage their behavior.

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
        #   "follow" indicates that the agent should not actively move itself, but should be synchronized with a companion.
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

        # The agent ahead of this one on the path.
        @next_agent = null

        # Companions follow this agent along adjacent lanes.
        # The adjacent lanes should be indicated inside this agent's path model.
        # companions will have psychologies set to "follow"
        @companion_left = null
        @companion_right = null

        @leader = null

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

        @state["psychology"] = "stopped"

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

    # Moves this agent along the path, the path is responsible for propogating changes to companions.
    # Does the path perform legality checks or does the agent perform legality checks?
    # Responsibility for path switching will be given to the path.
    # Especially since the agent might have moved past operators while going to the end of the path.
    moveAlongPath: (dt, percentages_per_meter) ->

        psychology = @state["psychology"]
        dPercentage = 0

        # Only move along path if the character is currently thinking about going in a direction.
        if psychology == "up" or psychology == "left" or psychology == "right" # or psychology == "down"
            # Agents operate in meters (pixel) space, but also in percentage space along paths.
            dPercentage = dt*@speed*@speed_multiple*percentages_per_meter # s * (m/s) * (%/m)
        else
            return # no movement --> stayed on path.
        
        @percentage += dPercentage

        # repositions representation on screen.
        @getElement().reposition()

        # Returns true if percentage exceeds percentage path bounds.
        # Caller should handle this.
        return

    # Not guranteed to be safe or maintain distance from next agent.
    setPercentage: (per) ->
        @percentage = per
        @getElement().reposition()

    # Have the scene pass update commands to this object model.
    # FIXME: Do these currently have any effects.
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
    # responsibility for utilizing this pointer is externalized to classes such as the path model.
    getNextAgent: (agent) ->
        return @next_agent

    setNextAgent: (agent) ->
        @next_agent = agent
        return

    # agent_model or null.
    # Set and get pointers to the companions of this agent.
    # There may be a chain of companions if the left companion also has a left companion and so on.
    # The responsibility of maintaining non looping behavior is externalize to the classes that use this link.
    setLeftCompanion: (agent) ->
        @companion_left = agent
        agent.leader = @
        agent.setKey("psychology", "follow")
        return

    setRightCompanion: (agent) ->
        @companion_right = agent
        agent.leader = @
        agent.setKey("psychology", "follow")
        return

    getLeftCompanion: () ->
        return @companion_left

    getRightCompanion: () ->
        return @companion_right

    # Creates and returns a list of all companions.
    getAllCompanions: () ->
        left  = @companion_left
        right = @companion_right

        out = []

        # Output all left companions.
        # ASSUMPTION: left and right chains do not create loops.
        while left != null
            out.push(left)
            left = left.getLeftCompanion()

        while right != null
            out.push(right)
            right = right.getRightCompanion()

        return out


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