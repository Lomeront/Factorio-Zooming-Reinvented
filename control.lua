local player_memory = require("player_memory")
local zoom_calculator = require("zoom_calculator")

script.on_event("ZoomingReinvented_alt-zoom-in", function(event)
    local player = game.players[event.player_index]

    if player.render_mode == defines.render_mode.game or player.render_mode == defines.render_mode.chart_zoomed_in then
        player.zoom = zoom_calculator.calculate_zoomed_in_level(player)
    else
        zoom_calculator.update_current_zoom_by_user_zooming_in_on_the_map(player)
    end
end)

script.on_event("ZoomingReinvented_alt-zoom-out", function(event)
    local player = game.players[event.player_index]

    local should_switch_back_to_map = zoom_calculator.should_switch_back_to_map(player)

    if should_switch_back_to_map then
        local map_zoom_level = zoom_calculator.calculate_zoom_out_back_to_map_view(player)
        player.open_map(player_memory.get_last_known_map_position(player), map_zoom_level)
        return
    end

    local zoom_level = zoom_calculator.calculate_zoomed_out_level(player)

    if player.render_mode == defines.render_mode.chart then
        player.open_map(player_memory.get_last_known_map_position(player), zoom_level)
    else
        player.zoom = zoom_level
    end
end)

script.on_event("ZoomingReinvented_toggle-map", function(event)
    local player = game.players[event.player_index]

    if player.render_mode == defines.render_mode.game then
        local zoom_level = zoom_calculator.calculate_open_map_zoom_level(player)
        player.open_map(player.position, zoom_level)
        player_memory.set_last_known_map_position(player, player.position)
    else
        player.close_map()
        player.zoom = 1
        player_memory.set_current_zoom_level(player, 1)
    end
end)

script.on_event(defines.events.on_selected_entity_changed, function(event)
    local player = game.players[event.player_index]
    if player.render_mode == defines.render_mode.chart_zoomed_in and player.selected then
        player_memory.set_last_known_map_position(player, player.selected.position)
    end
end)
