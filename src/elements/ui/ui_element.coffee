###
    User Interface Layer class. Represents a single layer of user interface elements.
    Written by Bryce on May.4.2017
    Adapted by Bryce Summers on Mar.22.2018
    
    Purpose: This class provide general functions for the operation of UI's.
        - static visual generation.
        - creation and deletion of buttons.

    This class also handles the text based display of information to the users.

    This class internally manages the visualization, querying, and management of label objects.
    It returns reference objects that can be used to instruct this class to perform modifications.

###

class EX.UI extends BSS.Element

    # z_depth 3 or lower, where 3 is near camera, -inf is away from camera.
    # z_depth should be a multiple of .1 to allow for space in between.
    constructor: (z_depth) ->

        super(new BSS.Model()) # these guys don't really need a model, yet...

        # This stores the state of the UI_buttons.
        @_bvh = new BDS.BVH2D([])
        @_elements = new Set()

        # FIXME: Get this from teh UI controller.
        @_c_resting = new THREE.Color(0xe6dada)

        @z_depth = z_depth
    
    ###
    Labels: They sit on screen with a text visual object underneath.
    ###

    # THREE.Color, BDS.Polyline, float, float, String
    # {fill:, area:, textx:, texty:, str:}
    # Area coordinates are in screen space.
    # Returns reference pointer to object, that can be passed back into this object for modification and deletion.
    createLabel: (params) ->

        container_visual = new THREE.Object3D()
        background_visual = EX.Visual_Factory.newPolygon(params.area, params.fill)

        container_visual.add(background_visual)

        text_visual = EX.Visual_Factory.new_label(params.str)
        text_visual.position.x = params.textx
        text_visual.position.y = params.texty

        container_visual.add(text_visual)


        element =   {area:params.area
                    ,visual:container_visual
                    ,text_visual:text_visual
                    ,background_visual: background_visual
                    ,str: params.str
                    ,fill:params.fill
                    ,textx:params.textx
                    ,texty:params.texty
                    }

        # Add label to internal data structurs for querying.
        element.area.setAssociatedData(element)
        @_bvh.add(element.area)
        @_elements.add(element)

        # Add visual to on screen visual representation of this UI layer.
        @getVisualRepresentation().addVisual(container_visual)

        return element

    # Input is the output of .createLabel()
    # Supported updates:
    # params: {update_str:bool}
    updateLabel: (element, params) ->

        #!! Couldn't all creation be thought of as a fully modified empty object!
        # I don't think I really need the separate creation functions.

        # String update.
        if params.update_str
            container = element.visual
            container.remove(element.text_visual)

            text_visual = @_newTextVisual(element)
            container.add(text_visual)
            element.text_visual = text_visual

    _newTextVisual: (params) ->
        text_visual = EX.Visual_Factory.new_label(params.str)
        text_visual.position.x = params.textx
        text_visual.position.y = params.texty
        text_visual.position.z = @z_depth + .01
        return text_visual


    # Create a button displayed at the given area: BDS.Polyline.
    # visually represented by the given material,
    # and which should call the given function when clicked.
    createButton: (area, material, click_function) ->
    
        ###
         * An element is an associative object of the following form:
         * {click:    () -> what happens when the user clicks on this element.
         *  polyline: A polyline representing the collision detection region for the object.
         *  material: a pointer to the material object responsible for filling the actual
         *  object on the screen, such as with an associated image base texture map.
        ###

        # Start the material off in the resting state.
        material.color = @_c_resting

        element =   {click: click_function
                    ,polyline:area
                    ,material: material}

        element.polyline.setAssociatedData(element)
        @_bvh.add(element.polyline)
        @_elements.add(element)

        return element

    # Remove the given button from the elements and bvh structures.
    removeButton: (b) ->
        a = @_elements.delete(b)
        b = @_bvh.remove(b.polyline)

        # Return true if the button was removed from all data structures.
        return a and b

    # Query function used to retrieve the UI element at the given point.
    # Used as the primary interface to UI mouse controllers.
    query_point: (pt) ->
        return @_bvh.query_point(pt)

    ###

    Internal Helper functions.

    ###

    # {fill:, x:, y:, w:, h:, depth}
    # x and y of top left corner.
    _createRectangle: (params) ->
        rect = TSAG.style.unit_meshes.newSquare({color: new THREE.Color(params.fill)})
        rect.scale.x = params.w
        rect.scale.y = params.h
        rect.position.x = params.x + params.w/2
        rect.position.y = params.y + params.h/2
        rect.position.z = params.depth

        return rect



















        ###
        mesh.scale.x = 200
        mesh.scale.y = 200
        

        view.add(mesh)

        window.mesh = mesh
        ###


        # -- Tools Controllers extracted from input tree.
        ###
        @controller_build_road = 
        @controller_build_road.setActive(false)
        @controller_demolish_road = 
        @controller_demolish_road.setActive(false)
        ###


        ###
        # -- Tools UI Buttons.
        b1 = new BDS.Box(new BDS.Point(0,   0),
                         new BDS.Point(64, 64));

        b2 = new BDS.Box(new BDS.Point(64,   0),
                         new BDS.Point(128, 64));

        b3 = new BDS.Box(new BDS.Point(128,  0),
                         new BDS.Point(192, 64));

        p1 = b1.toPolyline()
        p2 = b2.toPolyline()

        # Modification functions.
        func_build_road_local     = () ->
            mode = TSAG.I_Mouse_Build_Road.mode_local
            @controller_build_road.setMode(mode)

        func_build_road_collector = () ->
            mode = TSAG.I_Mouse_Build_Road.mode_collector
            @controller_build_road.setMode(mode)

        func_build_road_artery    = () ->
            mode = TSAG.I_Mouse_Build_Road.mode_artery
            @controller_build_road.setMode(mode)

        img_build_road_local     = null # Load Local road building image.
        img_build_road_collector = null # Load Collector road building image.
        img_build_road_artery    = null # Load Arterial road building image.

        @controller_ui.createButton(p1, func_build_road_local,     img_build_road_local)
        @controller_ui.createButton(p2, func_build_road_collector, img_build_road_collector)
        @controller_ui.createButton(p2, func_build_road_artery,    img_build_road_artery)
        ###