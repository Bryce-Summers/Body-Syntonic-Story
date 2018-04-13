###
This is a test place, it initializes the MVP story to test functionality, before the writing of the compiler.
###

class BSS.Test_Place extends BSS.Place_Element

    # Builds a test place.
    constructor: (scene) ->

        super(scene)

        # Asynchrounously load the story back into this place element.
        storyLoader = new BSS.Story_Loader(@)
        #story_map = storyLoader.load_story('assets/stories/00_mvp.txt')
        #story_map = storyLoader.load_story('assets/stories/001_curve.txt')
        #story_map = storyLoader.load_story('assets/stories/002_conditional.txt')
        #story_map = storyLoader.load_story('assets/stories/004_friends.txt')
        #story_map = storyLoader.load_story('assets/stories/005_simple_friends.txt')
        story_map = storyLoader.load_story('assets/stories/006_operators.txt')

        #@init_place()
        @init_scene_ui()

    init_place: () ->

        # Build a path.
        pts = []
        x = 0
        y = 0

        # Create 10 segments.
        first_path = null
        for i in [0 ... 1]
            x = 0
            y0 = i*50
            y1 = y0 + 300

            pt0 = new BDS.Point(x, y0)
            pt1 = new BDS.Point(x, y1)
            
            path_pline = new BDS.Polyline(false, [pt0, pt1])
            path_element = new BSS.Path_Element(path_pline)
            first_path = path_element if first_path == null

            # At the end of each segment put an operator.
            #operator = new BSS.Operator_Element()
            #path_element.addOperator(operator, .9) # adds an operator at .9 percentage down the path.

            @addPath(path_element)

        for i in [1 .. 9]
            # food increasing operators.
            operator = new BSS.Operator_Element()
            operator.setFunction((agent_model) ->
                food = agent_model.statistics.getFood()
                agent_model.statistics.setFood(food + 1)
                )

            path_element.addOperator(operator, i*1.0/10) # adds an operator at 10's of the way down the path.
            @addOperator(operator)

        # Add a narrative event near the beginning of the path.
        operator = new BSS.Operator_Element()
        operator.setFunction((agent_model) ->
            agent_model.statistics.setNarrative("The body is an accumulation of food.")
            )

        path_element.addOperator(operator, .001) # adds an operator at .001 percentage down the path.
        @addOperator(operator)


        player_character = new BSS.Agent_Element()
        first_path.addAgent(player_character) # paths and places contain and act on agents, agents themselves don't act on the world.
        @addAgent(player_character) # allows the character to be rendered to the screen.

        @scene.setFocusAgent(player_character)
        @scene.setFocusPlace(@) # This test scene will provide the camera movement model.


    init_scene_ui: () ->

        # UI manages all of the ui functionality and querying.
        # ui_elements is a {dictionary} of specific elements.
        [ui, ui_elements] = @scene.getUI()

        # Construct a label on the bottom of the screen that will perform narration.
        ###
        w = 1200
        h = 800
        label_h = 50
        p0 = new BDS.Point(w/4,   h - label_h)
        p1 = new BDS.Point(w*3/4, h - label_h)
        p2 = new BDS.Point(w*3/4, h)
        p3 = new BDS.Point(w/4, h)
        pLine = new BDS.Polyline(false, [p0, p1, p2, p3])
        textbox_params = {fill:EX.style.c_building_fill, area:pLine, textx:w/4, texty:h, str:"Food becomes the body."}
        ui_elements.textbox = ui.createLabel(textbox_params)

        # Construct a label for the food resource.
        p0 = new BDS.Point(0,   h - label_h)
        p1 = new BDS.Point(w/4, h - label_h)
        p2 = new BDS.Point(w/4, h)
        p3 = new BDS.Point(0, h)
        pLine = new BDS.Polyline(false, [p0, p1, p2, p3])
        textbox_params = {fill:EX.style.c_building_fill, area:pLine, textx:p3.x, texty:p3.y, str:EX.style.resource_name_food + "0"}
        ui_elements.foodbox = ui.createLabel(textbox_params)
        ###