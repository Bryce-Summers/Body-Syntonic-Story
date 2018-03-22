###
Written by Bryce Summers on Mar.21.2018
Sends time update commands to all of the places.
###
class EX.TimeTool_SceneTimer extends EX.I_Tool_Controller

    # Input: THREE.js Scene.
    # THREE.js
    constructor: (@scene, @camera) ->

    time: (dt) ->

        # Convert from milliseconds to seconds.
        dt = dt/1000

        # Pipes time to the scene.
        @scene.time(dt)

    # Returns true iff this controller is in a resting state and may easily be finished and switched for a different controller.
    isIdle: () ->
        return true


    # Completes all actions, such that it is safe to switch controllers.
    finish: () ->