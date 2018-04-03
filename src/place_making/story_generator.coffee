###

Story Generator.
Written by Bryce Summers on Mar.27.2018.
Purpose: Encodes all of the information necessary to generate a story block.

The content cooresponds to story NAME blocks in a story file.

Allows for new story block elements to be instantiated. Generates instances, but leaves management to other 

# FIXME: Change last_path to last_element. (Path, conditional)

###

class BSS.Story_Generator

    # [[tokens1], [tokens2], [tokens2]]
    # Takes the tokens that constitute a block and stores the information in order to generate Element instances on demand within a place.
    constructor: (@tokens) ->


    # State.
    # When parrallel paths are used, an ordered list of states is maintained. All operations are applied to each state.
    # Each state thinks of itself as a single lane, but they are weaved together to form parrallel streams.
    # Each variable contains relevant local information to the particular stream.
    newState: (last_path, position, rotation_angle) ->
        state = {}
        state.path = last_path # Current Element. The mainline path, which may have extra lanes attached to either side.
        state.normalized_path_length = 0
        state.position = position
        state.rotation_angle = rotation_angle
        state.output = []
        state.forked_state = null # The state to revert to on a fork command.
        state.conditional_function = null # The current function that should be used as a key in a conditional.

        # The latest character that has been introduced that should be instantiated within this state stream.
        state.character = null

        state.index = 0 # [-inf, -2, left lanes, 0 (mid_lane), right lanes, 2, 3, inf]
        return state

    #(state{}) -> copy of state object.
    copyState: (state_in) ->
        out = {}
        out.path                    = state_in.path # Current Element.
        out.normalized_path_length  = state_in.normalized_path_length
        out.position                = state_in.position.clone() # Deep copy.
        out.rotation_angle          = state_in.rotation_angle
        out.output                  = state_in.output # Shallow copy, so output array is maintained.
        out.forked_state            = state_in.forked_state
        out.conditional_function    = state_in.conditional_function
        out.index                   = state_in.index

        out.character = null

        # 'middle' --> Add character to mainline path.
        # 'left'   --> Add character to a newly generated left lane.
        # 'right'  --> Add character to a newly generated right lane.
        out.character_location = state_in.character_location
        return out


    #() -> [elements] Produces a list of elements that are all consistently linked up. Produces them relative the given position and rotation.
    ###
    story MVP
    up 100
    narrate 1 The body is an accumulation of food.
    food 10
    food 20
    food 30
    food 40
    food 50
    food 60
    food 70
    food 80
    food 90
    the end
    ###
    # Given a BSS.Path_Element
    generateElements: (last_path, position, up_direction) ->

        rotation_angle = Math.atan2(up_direction.y, up_direction.x)
        
        # Using a state machine, generates all of the elements.
        state = @newState(last_path, position, rotation_angle)

        states = [state]

        for i in [0...@tokens.length]
            token_list = @tokens[i]

            # Character Introductions.
            if token_list[0] == "introduce"
                @generateAgent(token_list, states)
                continue

            # Perform the sequential operations for all of the parrallel states.
            # Then link up parrallel paths.
            for state_index in [0...states.length]
                state = states[state_index]
                state.token_list = token_list
                state.type = token_list[0]
                if state.type == "up" or state.type == "arc"
                    @generatePath(state)
                ###
                if state.type == "introduce"
                    @generateAgent(state)
                ###
                if state.type == "narrate"
                    @generateNarration(state)
                if state.type == "food"
                    @generateOperator(state)
                if state.type == "fork"

                    # Generate a fork revert state if necessary.
                    if state.forked_state == null

                        # We will generate a conditional at this location and tack it onto the end of the last path.
                        @generateConditional(state)

                        # We then set this state as the fork.
                        state.forked_state = @copyState(state)
                    else
                        # Revert to forked state.
                        forked_state = state.forked_state
                        state = @copyState(forked_state)
                        state.forked_state = forked_state
                        states[state_index] = state # Set back to array.

                    # ASSUMPTION: state is now at the root of the fork.

                    # We need to create the agent predicate function that 
                    # will coorespond to the next path that will be generated.
                    state.conditional_function = @generateAgentConditionalFunction(token_list[1..])

                # Follow up story
                if state.type == "tell"
                    @generateTellOperator(state)

            # Link up states and add characters.
            ###
            @update

            @linkPathsAndAddCharacters
            for i in [0...states.length - 1]
                state1 = states[i]
                state2 = states[i + 1]
                path_model1 = state1.path.getModel()
                path_model2 = state2.path.getModel()

                # Bidirectional link!
                path_model1.setRightLane(path_model2)
            ###

        return state.output

    # Generates paths continuing from the previous path and geometric location.
    # Continues every lane of the last path.
    generatePath: (state) ->

        # ENSURES path_element is set to midline.
        if state.type == "up"

            dx = Math.cos(state.rotation_angle)
            dy = Math.sin(state.rotation_angle)

            # Normalized length.
            length = state.token_list[1] * EX.style.file_to_screen_distance_factor
            state.normalized_path_length = state.token_list[1]

            pt0 = state.position.clone()
            dir = new BDS.Point(dx, dy)
            pt1 = pt0.add(dir.multScalar(length))
            
            path_pline = new BDS.Polyline(false, [pt0, pt1])
            path_element = new BSS.Path_Element(path_pline)

            state.position = pt1
            state.output.push(path_element)

        # Form circular arcs. FIXME: Put in arc in BDS.js
        # arc left/right angles in degree.
        else if state.type == "arc"

            factor = 1
            if state.token_list[1] == "right"# or state.token_list[1]
                factor = -1

            # Perpendicular direction.
            dx = Math.cos(state.rotation_angle - factor*Math.PI/2)
            dy = Math.sin(state.rotation_angle - factor*Math.PI/2)

            # 1.0 / curvature of path.
            radius_of_path = EX.style.path_curvature_inverse

            # Center position.
            cx = state.position.x + dx*radius_of_path
            cy = state.position.y + dy*radius_of_path
            
            pts = []
            len = 100 # Resolution of the curve's segments.
            radians_turned = factor*state.token_list[2]*Math.PI/180
            state.normalized_path_length = state.token_list[2] # degree's length.
            for i in [0..len] by 1
                # Rotation angle starts at the anti perpendicular, becuase it is relevant
                angle = state.rotation_angle + factor*Math.PI/2 - i*1.0/(len) * radians_turned
                px = cx + Math.cos(angle)*radius_of_path
                py = cy + Math.sin(angle)*radius_of_path
                pt = new BDS.Point(px, py)
                pts.push(pt)

            # Instantiate path
            path_pline = new BDS.Polyline(false, pts)
            path_element = new BSS.Path_Element(path_pline)
            state.output.push(path_element)

            state.position = pts[pts.length - 1]
            state.rotation_angle -= radians_turned

        # Add a new character on this state if necessary.
        # New character gets put upon path.
        if state.character != null
            path_element.addAgent(state.character) # Add the agent to the last path.

        # Connect the path_element to the previous element.

        # CASE 1: This is the first path off of a conditional fork.
        if state.conditional_function
            conditional = state.path
            func = state.conditional_function
            conditional.getModel().associateCondition(func, path_element.getModel())
            state.conditional_function = null
        # Case 2: This is a continuation of non forking path.
        else if state.path != null
            state.path.getModel().setDestination(path_element.getModel())
        state.path = path_element

        return

    # Agents are generated first, then placed onto the next segment of generated path in an appropraite lane.
    generateAgent: (token_list, states) ->

        token_index = 1

        # Optional left/right designation.
        # Create a new state or extract an old state.
        if token_list[token_index] == "left"
            state = @constructLeftState(states[0])
            states = [state].concat(states)
            token_index += 1
        else if token_list[token_index] == "right"
            state = @constructLeftState(states[states.length - 1])
            states.push(state)
            token_index += 1
        else
            # Character added to an existing path.
            for s in states
                # Only add this character to the midline.
                if s.index == 0
                    state = s
                    break

        # ASSUMPTION: state is the state that this character will be added to upon the next path construction.

        focus_agent = false

        # Protagonist, infant, toddler, adult, etc.
        if token_list[token_index] == "protagonist"
            focus_agent = true
            token_index += 1

        # Create an agent that will be placed on the next generated path.
        agent = new BSS.Agent_Element()
        agent_model = agent.getModel()
        agent_model.setCharacterType(token_list[token_index], focus_agent)

        # Global output push.
        state.output.push(agent)
        state.character = agent
        return

    # FIXME: should we copy the state instead? How does forking work in the presence of branching states?
    # Do we revert to the old state list?
    constructLeftState: (state) ->
        path = state.path

        [loc, up] = path.getLocation(1.0)

        # (1, 0) --> (0, 1)
        left = new BDS.Point(-up.y, up.x)

        offset = path.getCrossSectionRadius()
        lane_pos = loc.add(left.multScalar())

        out = @newState(null, lane_pos, state.rotation_angle)
        out.index = state.index - 1
        out.output = state.output
        return out

    constructRightState: (state) ->


    # FIXME: Abstract the operator generation functionality.
    generateNarration: (state) ->

        # Compute percentage of operator location.
        normalized_dist = state.token_list[1]
        percentage = normalized_dist / state.normalized_path_length

        # Rejoin narrative sentance from tokens.
        message = ""
        for i in [2...state.token_list.length] by 1
            str = state.token_list[i]
            message = message + " " + str

        console.log(message)

        operator = new BSS.Operator_Element()
        operator.setFunction((agent_model) ->
            agent_model.statistics.setNarrative(message)
            )

        state.path.addOperator(operator, percentage)
        state.output.push(operator)
        return

    generateOperator: (state) ->

        # Compute percentage of operator location.
        normalized_dist = state.token_list[1]
        percentage = normalized_dist / state.normalized_path_length

        if state.token_list[0] == "food"
            operator = new BSS.Operator_Element()
            operator.setFunction((agent_model) ->
                food = agent_model.statistics.getFood()
                agent_model.statistics.setFood(food + 1)
                )

            state.path.addOperator(operator, percentage)
            state.output.push(operator)
        return

    # Generates a load operator for new story.
    generateTellOperator: (state) ->
        percentage = .99
        operator = new BSS.Operator_Element()
        model = operator.getModel()
        model.setType("story_load")
        model.setState("story_name", state.token_list[1]) # tell NAME
        model.setState("path", state.path)
        state.path.addOperator(operator, percentage)
        state.output.push(operator)


    generateConditional: (state) ->
        conditional = new BSS.Condition_Element()
        state.path.getModel().setDestination(conditional.getModel())

        # Set conditional's location if necessary.

        state.path = conditional
        state.output.push(conditional)

    # Takes a token list and parses it into a conditional function on agents.
    # return (agent_model) -> (left, right)
    # Mar.29.2018, parses simple:  key == state  token lists.
    # FUTURE: (a < 5 or g == "left")
    generateAgentConditionalFunction: (token_list) ->
        return (agent_model) ->
            val1 = agent_model.lookupKey(token_list[0])
            val2 = token_list[2]
            return val1 == val2