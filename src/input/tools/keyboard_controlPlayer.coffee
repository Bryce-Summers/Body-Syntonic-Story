###
Written by Bryce Summers on Mar.21.2018
Has the camera follow an agent.
###
class EX.Keyboard_ControlPlayer extends EX.I_Tool_Controller

    # Input: THREE.js Scene.
    # THREE.js
    constructor: (@scene, @camera) ->
        @up_pressed    = false
        @left_pressed  = false
        @right_pressed = false
        @down_pressed  = false

    key_down:(event) ->

        console.log(event.key)

        # Tell the player agent to set its speed such that it is moving forwards.

        # Do we tell the agent what do, or rather what command the user has expressed?

        if not @up_pressed and event.key == "ArrowUp"
            agent = @scene.getFocusAgent()
            agent_model = agent.getModel()
            agent_model.setKey("psychology", "up")

        if not @left_pressed and event.key == "ArrowLeft"
            agent = @scene.getFocusAgent()
            agent_model = agent.getModel()
            agent_model.setKey("psychology", "left")

        if not @right_pressed and event.key == "ArrowRight"
            agent = @scene.getFocusAgent()
            agent_model = agent.getModel()
            agent_model.setKey("psychology", "right")

        if not @down_pressed and event.key == "ArrowDown"
            agent = @scene.getFocusAgent()
            agent_model = agent.getModel()
            agent_model.setKey("psychology", "down")

    key_up: (event)  ->
        if event.key == "ArrowUp"
            up_pressed = false

    # Key pressed events should be handled in time with if checks.
    time: (dt) ->


    # Returns true iff this controller is in a resting state and may easily be finished and switched for a different controller.
    isIdle: () ->
        return true


    # Completes all actions, such that it is safe to switch controllers.
    finish: () ->