#
# Keyboard Input Manager
#
# Adapted by Bryce Summers on Mar.21.2018
#

class EX.I_Keyboard_Interface

    # Input: THREE.js Scene. Used to add GUI elements to the screen and modify the persistent state.
    # THREE.js
    constructor: (@scene, @camera) ->

    key_down:(event) ->
    key_up: (event)  ->

    # Key pressed events should be handled in time with if checks.
    time: (dt) ->

    # Returns true iff this controller is in a resting state and may easily be finished and switched for a different controller.
    isIdle: () ->

    # Completes all actions, such that it is safe to switch controllers.
    finish: () ->

