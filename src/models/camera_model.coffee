###
    Written by Bryce Summers on 10.23.2017

    A Model for a current camera view of a place.
    These are preserved between visits to places.

    This is used to determine the movement properties.
###

class BSS.Camera_Model extends BSS.Model

    constructor: () ->
        @center = new BDS.Point(0, 0)
        @up     = new BDS.Point(0, -1)
        @angle  = 0;

        @interpolationFactor = .1

    buildModel: () ->

    # Centers this camera on the given pt.
    setCenter: (pt) ->
        @center = pt.clone()

    getCenter: () ->
        return @center

    # sets the given direction as the up direction on screen.
    # This determines a camera's orientation.
    # BDS.Point
    setUpDirection: (dir) ->
        
        @up = dir.normalize()
        @angle = Math.atan2(@up.y, @up.x) + Math.PI/2 # aligned to right, not up.
        
        


    getUpDirection: () ->
        return @up

    # the rate (0 - 1) that a camera should be moved towards the center and alignment.
    setInterpolationFactor: (per) ->
        @interpolationFactor = per

    getInterpolationFactor: () ->
        return @interpolationFactor

    # Applies this camera model to the given THREE.Camera object.
    applyToCamera: (camera) ->
        pos_old = camera.position
        camera.position.x = (1.0 - @interpolationFactor)*pos_old.x + @interpolationFactor*@center.x
        camera.position.y = (1.0 - @interpolationFactor)*pos_old.y + @interpolationFactor*@center.y

        current_angle = camera.rotation.z

        # Normmalize the target angle to something close that we can shoot for
        # This prevents mod 2PI directional errors and paradoxes.
        while @angle > current_angle + Math.PI
            @angle -= Math.PI*2
        while @angle < current_angle - Math.PI
            @angle += Math.PI*2

        # Rotate within the xy plane on screen.
        camera.rotation.z = (1.0 - @interpolationFactor)*camera.rotation.z + @interpolationFactor*@angle

    # Applies this camera model inversly to the given THREE.Object3D with regards to the given camera.
    # all values are inverted.
    applyInverseToObj: (obj, camera) ->
        pos_old = obj.position
        obj.position.x = (1.0 - @interpolationFactor)*pos_old.x + @interpolationFactor*(camera.position.x - @center.x)
        obj.position.y = (1.0 - @interpolationFactor)*pos_old.y + @interpolationFactor*(camera.position.y + @center.y) # + because camera is inverted in y?

        current_angle = obj.rotation.z
        angle = (camera.rotation.z - @angle)

        # Normmalize the target angle to something close that we can shoot for
        # This prevents mod 2PI directional errors and paradoxes.
        while angle > current_angle + Math.PI
            angle -= Math.PI*2
        while angle < current_angle - Math.PI
            angle += Math.PI*2

        # Rotate within the xy plane on screen.
        obj.rotation.z = (1.0 - @interpolationFactor)*obj.rotation.z + @interpolationFactor*angle
