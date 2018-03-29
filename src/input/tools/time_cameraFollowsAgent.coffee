###
Written by Bryce Summers on Mar.21.2018
Has the camera follow an agent.
###
class EX.TimeTool_CameraFollowsAgent extends EX.I_Tool_Controller

    # Input: THREE.js Scene.
    # THREE.js
    constructor: (@scene, @camera) ->

    time: (dt) ->

        agent = @scene.getFocusAgent()
        place = @scene.getFocusPlace()

        return if agent == null or place == null

        agent_model = agent.getModel()
        place_model = place.getModel()
        camera_model = place_model.getCamera()

        return if camera_model == null

        # Given an agent, I want to access the path element cooresponding to the given model.
        [target_loc, target_up] = agent_model.getCurrentLocationAndHeading()

        # Using the camera model, interpolate the properties of the THREE.Camera object.
        camera_model.setCenter(target_loc)
        camera_model.setUpDirection(target_up)

        #camera_model.applyToCamera(@camera) # Moves the camera to the given location.
        # Inversly moves the scene such that a standard origin aligned camera perceives it as such.
        # This allows us to keep the User interface at a standard easy to use location, we don't have to worry about moving it, 
        # and we still only need 1 camera.
        camera_model.applyInverseToObj(@scene.getPivot(), @scene.getView(), @camera)



    # Returns true iff this controller is in a resting state and may easily be finished and switched for a different controller.
    isIdle: () ->
        return true


    # Completes all actions, such that it is safe to switch controllers.
    finish: () ->