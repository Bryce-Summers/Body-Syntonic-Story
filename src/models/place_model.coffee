###
    Place Class.
    Defines a place model.
    Written by Bryce Summers on 10.23.2017
        
    The User is always viewing a visual representation of a place model.
    There are also a set of active places currently in the model hiearchy handled by the scene object.
###

class BSS.Place_Model extends BSS.Model

    constructor: () ->

        @_object_spawners = null
        @_camera_model = new BSS.Camera_Model()

    getCamera: () ->
        return @_camera_model

    # Can be used to move the camera on a specific entity if necessary.
    setCamera: (model) ->
        @_camera_model = model