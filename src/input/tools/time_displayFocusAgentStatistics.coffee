###
Written by Bryce Summers on Mar.21.2018
Updates the scene's ui based on the statistics of the focus agent.
###
class EX.TimeTool_DisplayFocusAgentStatistics extends EX.I_Tool_Controller

    # Input: THREE.js Scene.
    # THREE.js
    constructor: (@scene, @camera) ->

        @_optionAnimation = null

    time: (dt) ->


        focus_agent = @scene.getFocusAgent()
        return if focus_agent == null

        [ui, ui_elements] = @scene.getUI()
        agent_model = focus_agent.getModel()
        statistics  = agent_model.getStatistics()

        message = ""

        # Apply update to narrative box.
        if statistics.narrativeChanged()

            # Expression, thinking, narration, etc.
            type = statistics.getNarrativeType()

            message = statistics.getNarrative()
            message = @macrosubstituteStatisticsValues(message, statistics)

            

            # In the event of an optional narrative change.
            # We set a timer. Within that time we indicate that the user can trigger the narrative event.
            if statistics.hasOptionalNarrative()

                @_optionAnimation = new EX.FrameAnimation()

                # Configure all properties at once.
                # {duration:, timePerFrame:, frames:[filename, fname, fname, ...], dim:}
                # 2 second duration, .1 seconds per frame.
                # links between expression bubble and no expression bubble.
                config = {duration: 2000, timePerFrame: 100, frames: ["assets/images/speechbox.png", expression.png], dim: {x: -677/2, y:47, w:677, h:61}}
                @_optionAnimation.configure(config)

            @storyEvent(type, message, agent_model, @_optionAnimation)

    keyEvent: (key) ->


        # On space, launch non- expired optional narrative.

        # If statistics has an optional narrative and the time hasn't expired, the user can signal an event using the space key.
        # If time has not yet expired and the statistics ha
        if key == 'space' and @_optionAnimation != null

            # If it is done, we no longer need to remember it.
            if @_optionAnimation.isDone()
                @_optionAnimation = null
                return

            focus_agent = @scene.getFocusAgent()
            return if focus_agent == null

            [ui, ui_elements] = @scene.getUI()
            agent_model = focus_agent.getModel()
            statistics  = agent_model.getStatistics()

            if statistics.hasOptionalNarrative()

                message = statistics.getOptionalNarrative()
                message = @macrosubstituteStatisticsValues(message, statistics)

                @storyEvent(type, message, agent_model, null)
                @_optionAnimation.finish()


    # String, BSS.Statistics_Model -> Replaces \name with value of name in statics.
    macrosubstituteStatisticsValues: (message, statistics) ->
        
        slash_index = message.indexOf("\\")
        while slash_index > -1

            # Break the word apart at the start of the variable name.
            prefix = message.substring(0, slash_index)
            suffix = message.substring(slash_index)

            # Isolate the variable name.
            end_of_word_index = suffix.search(" ")
            end_of_word_index = suffix.length if end_of_word_index < 0

            name = suffix.substring(1, end_of_word_index)
            suffix = suffix.substring(end_of_word_index)

            val = statistics.getValue(name)
            message = prefix + val + suffix

            # Next One.
            slash_index = message.indexOf("\\")

        return message


    # Type in {say, narrate, think, good, bad}
    storyEvent: (type, message, agent_model, option_animation) ->

        console.log("Type = " + type)
        console.log("Message = " + message)

        box_sprite = null
        connection_sprite = null

        if type == "say"
            box_sprite = "assets/images/speechbox.png"
            connection_sprite = "assets/images/speech_connection.png"
        else if type == "narrate"
            box_sprite = "assets/images/narration_box.png"
            connection_sprite = "assets/images/narration_connection.png"
        else if type == "think" or type == "food"
            box_sprite = "assets/images/thinkbox.png"
            connection_sprite = "/assets/images/think_connection.png"
        else if type == "good"
            box_sprite = "assets/images/good_box.png"
            connection_sprite = "/assets/images/good_connection.png"
        else if type == "bad"
            box_sprite = "assets/images/bad_box.png"
            connection_sprite = "assets/images/bad_connection.png"
        else
            console.log("Storytelling Event: '" + type + "' is not currently supported.")

        # Create a new narrative box.
        narration_box = EX.Visual_Factory.newSprite(box_sprite, {x: -677/2, y:47, w:677, h:61})
        connection    = EX.Visual_Factory.newSprite(connection_sprite, {x:0, y:0, w:64, h:63})

        # Text message.
        str = message
        text = EX.Visual_Factory.new_label(str)
        text.position.z = .1
        text.position.y = 47 + 63
        text.position.x = -677/2 + 20

        box = new THREE.Object3D()

        box.add(narration_box)
        box.add(connection)
        box.add(text)

        # Add option animation to signal the ability to express.
        if option_animation != null
            box.add(option_animation)

        # Position in World.
        [loc, up] = agent_model.getCurrentLocationAndHeading()
        box.position.copy(loc)
        box.rotation.z = Math.atan2(up.y, up.x) + Math.PI/2
        box.position.z = 2
        @scene.addOverlay(box, 1)

        ###
        textbox = ui_elements.textbox
        textbox.str = statistics.getNarrative() # standardized label comes from style.
        ui.updateLabel(textbox, {update_str:true})
        ###

    # Returns true iff this controller is in a resting state and may easily be finished and switched for a different controller.
    isIdle: () ->
        return true


    # Completes all actions, such that it is safe to switch controllers.
    finish: () ->