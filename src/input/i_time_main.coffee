###

Time Input Controller.

Written by Bryce Summmers on 1 - 31 - 2017.

###

class EX.I_Time_Main extends BDS.Controller_Group

    # Input: THREE.js Scene. Used to add GUI elements to the screen and modify the persistent state.
    # THREE.js
    constructor: (@scene, @camera) ->

        super()

        # Have the camera follow the focus agent, mainly the player's embodied agent.
        cameraFollowsAgent = new EX.TimeTool_CameraFollowsAgent(@scene, @camera)
        @add_time_input_controller(cameraFollowsAgent)
        cameraFollowsAgent.setActive(true)

        # Animate Places and Agents.
        sceneTimer = new EX.TimeTool_SceneTimer(@scene, @camera)
        @add_time_input_controller(sceneTimer)
        sceneTimer.setActive(true)

        updateUIFromFocusAgent = new EX.TimeTool_DisplayFocusAgentStatistics(@scene, @camera)
        @add_time_input_controller(updateUIFromFocusAgent)
        updateUIFromFocusAgent.setActive(true)
        