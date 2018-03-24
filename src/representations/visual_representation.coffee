###
#
# Visual Representation.
#
# Adapted by Bryce Summers on 10.26.2017
#
# Handles the management of a visual representation.
#
#
# Usage: Configure, Build, {Convert, Render, Mutate}.
###

class BSS.Visual_Representation

    constructor: () ->

        # Permanant root node of this rerpesentations's THREE object tree.
        @_obj3D = new THREE.Object3D() # Private.
        @_children = new Set() # Used to clear all child visuals if necessary.

    ###

    Configure

    ###

    addVisual: (visual) ->
        @_obj3D.add(visual)
        @_children.add(visual)

    removeVisual: (visual) ->
        @_obj3D.remove(visual)
        @_children.delete(visual)

    getVisual: () ->
        return @_obj3D

    clearVisuals: () ->
        @_children.forEach (visual) =>
            @_obj3D.remove(visual)
        @_children = new Set()

    # Updates the camera model that will be used to 
    # clip the visuals that are constructed.
    # BSS.Camera_Model --> ()
    setCameraobj3D: (obj3D) ->

    setPosition: (position) ->
        z = @_obj3D.position.z
        @_obj3D.position.copy(position.clone())
        @_obj3D.position.z = z

    getPosition: () ->
        return @_obj3D.position.clone()
    
    setRotation: (rotation_z) ->
        @_obj3D.rotation.z = rotation_z

    getRotation: () ->
        return @_obj3D.rotation.z

    # Sets the rotation to the given up direction.
    setUpDirection: (up) ->
        up = up.normalize()
        angle = Math.atan2(up.y, up.x) + Math.PI/2
        @setRotation(angle)

    setScale: (scale) ->
        @_obj3D.scale.copy(scale.clone())

    getScale: () ->
        return @_obj3D.scale.clone()


    ###

    Conversion to other forms.

    ###


    # Returns a new visual that is freshly constructed based on the given obj3Dport.
    # some classes, such as road networks will provide a function to reconstruct the visual, optimized for a particular obj3Dport.
    # toVisual: (obj3Dport) ->
    # Returns a THREE.Object3D for this visual Representation, taking into account the given BSS.Camera_Model 'obj3D'
    # BSS.Camera_Model -> THREE.Object3D
    build: () ->


    # Converts this visual representation into areas that can be passed to a collision representation.

    # Methods to convert this element's THREE.JS object directly into Collision detection geometry.
    # Directly copies this element's triangle representation, doesn't do any bounding box optimizations.
    # Each individual element may wish to override this with more efficient or coarse methods.
    # converts a THREE.Object3D into a list of Triangle objects with pointers to their mesh objects.
    # () -> BDS.Polyline()
    # Optional: appends lines to an input list.
    # Note: Polylines are interpreted to be areas when closed.
    toCollisionAreas: (output) ->

        obj = @_obj3D
        mesh_list     = @_to_mesh_list(obj)
        polyline_list = []

        if output != undefined
            polyline_list = output

        for mesh in mesh_list
            geometry = mesh.geometry
            vertices = geometry.vertices
            faces    = geometry.faces

            # Matrix Transform from local mesh position coordinates to world position coordinates.
            localToWorld = mesh.matrixWorld

            for face in faces
                a = vertices[face.a].clone()
                b = vertices[face.b].clone()
                c = vertices[face.c].clone()

                a.applyMatrix4(localToWorld)
                b.applyMatrix4(localToWorld)
                c.applyMatrix4(localToWorld)

                a = @_vector_to_point(a)
                b = @_vector_to_point(b)
                c = @_vector_to_point(c)

                polyline = new BDS.Polyline(true, [a, b, c])

                # Associate this polyline with this Game element.
                polyline.setAssociatedData(@)

                polyline_list.push(polyline)

        return polyline_list

    # Converts a THREE.JS Vector to a BDS.Point.
    _vector_to_point: (vec) ->
        return new BDS.Point(vec.x, vec.y, vec.z);

    # Converts this object's obj3D into a list of three.js objects.
    # THREE.Object3D -> THREE.Mesh[]
    _to_mesh_list: (obj) ->

        output = []

        add_output =
            (o) -> if o.geometry then output.push(o)

        obj.traverse(add_output)

        return output


