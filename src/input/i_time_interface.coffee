#
# Mouse Input Manager
#
# Written by Bryce Summers on Mar.21.2018
#

class EX.I_Time_Interface

    # Input: THREE.js Scene. Used to add GUI elements to the screen and modify the persistent state.
    # THREE.js
    constructor: (@scene, @camera) ->

    time: (dt) ->

    # Returns true iff this controller is in a resting state and may easily be finished and switched for a different controller.
    isIdle: () ->

    # Completes all actions, such that it is safe to switch controllers.
    finish: () ->
