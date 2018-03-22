###

UI Input Controller.

Written by Bryce Summers on May.4.2017

Purpose: 
 - Manages a bunch of UI elements and triggering their actions.
 - Handles the coloring and visual display logic for UI elements.

Notes:
 - This class has been adapted from BDS.Controller_UI.
   the only difference is our use of three.js, instead of canvas drawing.
   I think that we could abstract the canvas drawing into a scene graph 
   and then these paradigms will be more aligned.

###


class EX.UI_Controller

    # TSAG.E_Overlays
    constructor: (@scene, @camera) ->


        # Records whether the mouse is currently in a depressed state.
        @_mouse_pressed = false

        # Stores the element that the mouse is curently on top of.
        # ASSUMPTION: UI Components should not be located on top of each other.
        #             Perhaps I can change this to allow for overlayed venn-diagram like buttons in the future.
        @_hover_element   = null

        # The last element that the user has clicked on.
        # This gets sent back to null when the user is not in the middle of a UI action.
        @_clicked_element = null

        # Hexadecimal color integers.
        # 70 is the alpha value. aarrggbb
        @_c_resting       = new THREE.Color(0xe6dada)
        @_c_hover_nopress = new THREE.Color(0xfaf8f8)
        @_c_hover_pressed = new THREE.Color(0xa0a0a0)
        @_c_nohover_press = new THREE.Color(0xc7acac)

        @_active = true


    setActive: (isActive) -> @_active = isActive
    isActive: () -> return this._active
    

    # Converts the current hover element to a clicked element.
    mouse_down: (event) ->
    
        # Only trigger once.
        if @_mouse_pressed
            return
        
        @_mouse_pressed = true
        
        # If we are hovering over an element, then we sent is to the pressed state.
        if @_hover_element != null        
            @_clicked_element = @_hover_element
            @_clicked_element.material.color = @_c_hover_pressed

    # Updates the current hover element.
    # Manages colorations for UI elements.
    mouse_move: (event) ->
    
        pt = new BDS.Point(event.x, event.y)

        # Note: We could have used .query_point_all() to retrieve all points at that location.
        # Query the state stored in an e_UI object.
        polyline = @scene.getUI().query_point(pt)
        element  = null

        if polyline != null
            element = polyline.getAssociatedData()

        # First decolor the previous hovered component. We'll recolor it soon after if it is special.
        if @_hover_element != null
            @_hover_element.color = @_c_resting

        # Change the hover element.
        # It might be null.
        @_hover_element = element

        if @_hover_element != null
            @_hover_element.material.color   = @_c_hover_nopress

        # Now upgrade components to pressed colors.
        if @_clicked_element != null
        
            if @_clicked_element == @_hover_element
                @_clicked_element.material.color = @_c_hover_pressed
            else
                @_clicked_element.material.color = @_c_hover_nopress

    # Triggers the UI element if the hover element is still equal to the clicked on element.
    # Resets the controller to a resting state.
    mouse_up: (event) ->


        if not @_mouse_pressed
            return

        if @_clicked_element == null
            # Revert back to the resting state.
            @finish()
            return

        if @_hover_element == @_clicked_element

            @_hover_element.click()
            @_hover_element.material.color = @_c_hover_nopress
        

        # Revert back to the resting state.
        @finish()


    # Manages User signals such as flashes.
    # Draws all of the elements to the screen.
    # dt is the difference in time from the previous call.
    time: (dt) ->

    # TODO: Not yet implemented.
    window_resize: (event) ->
    
        # ??? Resize or relayout the User interface???
        # Form rows if the screen becomes too tight.

    # This function may be used to revert this controller to its resting state.
    finish: () ->

        @_mouse_pressed   = false

        # We have finished our click.
        @_clicked_element = null
