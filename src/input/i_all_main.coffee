#
# All input Controller.
#
# Written by Bryce Summers on 12 - 19 - 2016.
#
# Purpose: This class is the root of my input system, it collects simple input events and passes them to the relevant controllers by type.
#
# The idea of developing appications using this system is that their input logics can be formally specified as a tree within this folder.
# input groups can be further divided if necessary.
# I_All_Main
# - I_Mouse_Main
#   - mouse tool.
#   - mouse tool.
#   - mouse tool.
#   - ...
# - I_Keyboard_Main
#   - keyboard tool.
#   - keyboard tool.
#   - keyboard tool.
#   - ...
# - I_Time_Main
#   - time tool.
#   - time tool.
#   - time tool.
#   - ...
#

class EX.I_All_Main extends BDS.Controller_Group
    
    # Input: THREE.js Scene. Used to add GUI elements to the screen and modify the persistent state.
    # THREE.js
    constructor: (@scene, @camera) ->

        super()

        # Mouse Input.
        #@_mouse_input = new EX.I_Mouse_Main(@scene, @camera)
        #@add_mouse_input_controller(@_mouse_input)

        # Keyboard Input.
        @_keyboard_input = new EX.I_Keyboard_Main(@scene, @camera)
        @add_keyboard_input_controller(@_keyboard_input) # Only keyboard commands are piped to children.

        # Time Input.
        @_time_input = new EX.I_Time_Main(@scene, @camera)
        @add_time_input_controller(@_time_input) # Only time commands are piped to children.
        
    getMouseController: () ->
        return @_mouse_input