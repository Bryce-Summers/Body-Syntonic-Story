###
#
# Collision Representation Class.
#
# Written by Bryce Summers on 10.23.2017
#
# Represents a node in a collision geometry hiearchy, 
# handles the management of a BVH and cooresponding areas.
#
# Usage: Configure, Build, Query.
#
###

class BSS.Collision_Representation

    constructor: () ->
        
        # The bvh is a BDS.BVH2D object that stores geometry used for collision detection,
        # Which will allow users to query and interact with these elements.
        @_bvh = new BDS.BVH2D()       

        # The Area used to represent this collision representation in parent nodes 
        @_bounding_area = null


    ###

    Configuration.

    ###

    # BDS.Area, Assumed to be positive.
    # and these will be unioned together in BVH.
    addCollisionAreas: (areas) ->
        for anArea in areas
            @addCollisionArea(anArea)

    addCollisionArea: (area) ->
        @_bvh.add(area)

    removeCollisionAreas: (areas) ->
        for anArea in areas
            @removeCollisionArea(anArea)

    removeCollisionarea: (area) ->
        @_bvh.remove(area)



    ###

    Build

    ###


    build: () ->
        @buildBoundingArea()


    # Generates this Element's BVH from scratch with all collision data pointing to this element.
    # This may be useful for leaf node's, but should be avoided for parent nodes.

    buildBoundingArea: () ->
        @_collision_area = @_bvh.toBoundingBox().toPolyline()
        @_collision_area.setAssociatedData(@)
        return @_collision_area


    ###

    Query.

    ###

    getBoundingArea: () ->
        if @_collision_area == null
            @generateCollisionArea()

        return @_collision_area


    # Returns true if at least one of this element's collision areas
    containsPt: (pt) ->
        return @_bvh.query_point(pt) != null