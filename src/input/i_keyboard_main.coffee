#
# Main Mouse Input Controller.
#
# Written by Bryce Summers on 12 - 18 - 2016.
#
# This is the top level keyboard input controller that receives all input related to keyboard input.
# It then pipes the input to the user's currently selected tool.
# FIXME: Abstract all of this functionality into EX.Input_Controller.

class EX.I_Keyboard_Main extends BDS.Controller_Group

    # Input: THREE.js Scene. Used to add GUI elements to the screen and modify the persistent state.
    # THREE.js
    constructor: (@scene, @camera) ->

        super()

        
        # Have the camera follow the focus agent, mainly the player's embodied agent.
        controlPlayer = new EX.Keyboard_ControlPlayer(@scene, @camera)
        @add_keyboard_input_controller(controlPlayer)
        controlPlayer.setActive(true)

        @state = "idle"

    ### Get Controllers. ###
    
    # deactivates all tools controllers.
    # Calls finish() on all tools controllers.
    deactivateTools: () ->

        ###
        @road_build_controller.setActive(false)
        @road_build_controller.cancel()
        @road_build_controller.finish()
        ###


    ###------------------------------------
      Internal Helper Functions.
    #--------------------------------------
    ###

    ### Override global functionality, still passes commands to subtools. ###
    ###
    key_down: (event) ->

        super(event)
    ###
