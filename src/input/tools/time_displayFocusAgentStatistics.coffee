###
Written by Bryce Summers on Mar.21.2018
Updates the scene's ui based on the statistics of the focus agent.
###
class EX.TimeTool_DisplayFocusAgentStatistics extends EX.I_Tool_Controller

    # Input: THREE.js Scene.
    # THREE.js
    constructor: (@scene, @camera) ->

    time: (dt) ->


        focus_agent = @scene.getFocusAgent()
        return if focus_agent == null

        [ui, ui_elements] = @scene.getUI()
        statistics = focus_agent.getModel().getStatistics()

        # Apply update to food label.
        if statistics.foodChanged()
            foodbox = ui_elements.foodbox
            foodbox.str = EX.style.resource_name_food + statistics.getFood() # standardized label comes from style.
            ui.updateLabel(foodbox, {update_str:true})

        # Apply update to narrative box.
        if statistics.narrativeChanged()
            textbox = ui_elements.textbox
            textbox.str = EX.style.resource_name_food + statistics.getNarrative() # standardized label comes from style.
            ui.updateLabel(textbox, {update_str:true})


    # Returns true iff this controller is in a resting state and may easily be finished and switched for a different controller.
    isIdle: () ->
        return true


    # Completes all actions, such that it is safe to switch controllers.
    finish: () ->