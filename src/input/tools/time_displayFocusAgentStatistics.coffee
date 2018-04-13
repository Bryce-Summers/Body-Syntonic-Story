###
Written by Bryce Summers on Mar.21.2018
Updates the scene's ui based on the statistics of the focus agent.
###
class EX.TimeTool_DisplayFocusAgentStatistics extends EX.I_Tool_Controller

    # Input: THREE.js Scene.
    # THREE.js
    constructor: (@scene, @camera) ->

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

            @storyEvent(type, message, agent_model)

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
    storyEvent: (type, message, agent_model) ->

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
        narration_box = new EX.Visual_Factory.newSprite(box_sprite, {x: -677/2, y:47, w:677, h:61})
        connection    = new EX.Visual_Factory.newSprite(connection_sprite, {x:0, y:0, w:64, h:63})

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