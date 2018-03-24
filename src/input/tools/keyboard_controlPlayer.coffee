###
Written by Bryce Summers on Mar.21.2018
Has the camera follow an agent.
###
class EX.Keyboard_ControlPlayer extends EX.I_Tool_Controller

    # Input: THREE.js Scene.
    # THREE.js
    constructor: (@scene, @camera) ->
        @up_pressed = false

    key_down:(event) ->

        # Tell the player agent to set its speed such that it is moving forwards.
        if not @up_pressed and event.key == "ArrowUp"
            agent = @scene.getFocusAgent()
            agent_model = agent.getModel()
            agent_model.setSpeed(1)

    key_up: (event)  ->

    # Key pressed events should be handled in time with if checks.
    time: (dt) ->


    # Returns true iff this controller is in a resting state and may easily be finished and switched for a different controller.
    isIdle: () ->
        return true


    # Completes all actions, such that it is safe to switch controllers.
    finish: () ->