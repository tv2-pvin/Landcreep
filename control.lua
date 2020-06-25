local function placeTile(surface, tile, roboport, tileName)
	if surface.can_place_entity{name="tile-ghost", position=tile.position, inner_name=tileName, force=roboport.force, build_check_type=defines.build_check_type.ghost_place, forced=true} then
		surface.create_entity{name="tile-ghost", position=tile.position, inner_name=tileName, force=roboport.force}
		return 1
	end
	return 0
end

local function landcreep(roboport)
	local surface = roboport.surface
	local tileName = settings.global["landcreep_tile_override"].value or "landfill"
	local circular = settings.global["landcreepers_circular_creep"].value or true
	local maxTiles = settings.global["landcreepers_max_tiles_per_iteration"].value or 100

	if roboport and roboport.valid and roboport.logistic_network and roboport.logistic_network.valid and roboport.logistic_cell and roboport.logistic_cell.valid and roboport.logistic_cell.construction_radius > 0 and maxTiles > 0 then

		maxTiles = math.min(
			maxTiles,
			roboport.logistic_network.available_construction_robots,
			roboport.logistic_network.get_item_count(tileName)
		)
		if 0 >= maxTiles then
			return -- break early
		end

		local radius = roboport.logistic_cell.construction_radius
		local tileCandidates

		if circular then
			tileCandidates = surface.find_tiles_filtered{position=roboport.position, radius=radius, collision_mask="water-tile"}
		else
			local xx = roboport.position.x
			local yy = roboport.position.y
			local area = {{xx-radius, yy-radius}, {xx+radius, yy+radius}}
			tileCandidates = surface.find_tiles_filtered{area=area, collision_mask="water-tile"}
		end

		local tilesPlaced = 0
		for _, tile in pairs(tileCandidates) do
			tilesPlaced = tilesPlaced + placeTile(surface, tile, roboport, tileName)
			if tilesPlaced >= maxTiles then
				return
			end
		end

		global.landcreepers.index = global.landcreepers.index + 1
	else
		table.remove(global.landcreepers.roboports, global.landcreepers.roboport_index)
	end

end

script.on_init(function()
	global.landcreepers = {}
end)

script.on_nth_tick(60, function()
	if global.landcreepers == nil then
		global.landcreepers = {}
	end

	if global.landcreepers.roboports == nil then
		global.landcreepers.roboports = {}
	end

	if #global.landcreepers.roboports == 0 then
		for _, surfaceItem in pairs(game.surfaces) do
			for _, roboportItem in pairs(surfaceItem.find_entities_filtered{type="roboport"}) do
				table.insert(global.landcreepers.roboports, roboportItem)
			end
		end
		global.landcreepers.index = 1
	end

	if (global.landcreepers.index >= #global.landcreepers.roboports) then
		global.landcreepers.index = 1
	end

	landcreep(global.landcreepers.roboports[global.landcreepers.index])
end)

local function handleEntityBuiltEvent(event)
	if event.created_entity and event.created_entity.valid and event.created_entity.type == "roboport" then
		table.insert(global.landcreepers.roboports, event.created_entity)
	end
end

script.on_event(defines.events.on_built_entity, function(event)
	handleEntityBuiltEvent(event)
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
	handleEntityBuiltEvent(event)
end)