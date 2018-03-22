#
# Main Mouse Input Controller.
#
# Written by Bryce Summers on 12 - 18 - 2016.
#
# This is the top level mouse input controller that receives all input related to mouse input.
# It then pipes the input to the user's currently selected tool, such as a road building controller.
# FIXME: Abstract all of this functionality into EX.Input_Controller.

class EX.I_Mouse_Main extends BDS.Controller_Group

    # Input: THREE.js Scene. Used to add GUI elements to the screen and modify the persistent state.
    # THREE.js
    constructor: (@scene, @camera) ->

        super()

        #@_create_cursor()

        # Represents all of the buttons.
        ###
        @ui_controller = new EX.UI_Controller(@scene, @camera)
        @add_mouse_input_controller(@ui_controller)
        ###

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

    _create_cursor: () ->

        # We create a red circular overlay to show us where the mouse currently is, especially for debugging purposes.

        mesh_factory = new EX.Unit_Meshes() #EX.style.unit_meshes
        params = {color: EX.style.cursor_circle_color}

        # THREE.js Mesh
        mesh = mesh_factory.newCircle(params)

        scale = EX.style.cursor_circle_radius
        mesh.position.z = EX.style.cursor_circle_z

        w = scale
        h = scale

        scale = mesh.scale
        scale.x = w
        scale.y = h

        overlays = @scene.getOverlays()
        overlays.addPermanentVisual(mesh)
        @pointer = mesh

    mouse_move: (event) ->

        super(event)

        pos = @pointer.position;
        pos.x = event.x
        pos.y = event.y