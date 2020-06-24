local function placeTile(surface, tile, roboport, tile_name)
	if surface.can_place_entity{name="tile-ghost", position=tile.position, inner_name=tile_name, force=roboport.force, build_check_type=defines.build_check_type.ghost_place, forced=true} then
		surface.create_entity{name="tile-ghost", position=tile.position, inner_name=tile_name, force=roboport.force}
	end
end

local function landcreep(item)
	local roboport = item.roboport
	local surface = item.surface
	local tile_name = settings.global["landcreep_tile_override"].value or "landfill"

	if roboport and roboport.valid and roboport.logistic_cell and roboport.logistic_cell.valid and roboport.logistic_cell.construction_radius > 0 then

		local radius = roboport.logistic_cell.construction_radius
		local tileCandidates

		if settings.global["landcreepers_circular_creep"].value == true then
			tileCandidates = surface.find_tiles_filtered{position=roboport.position, radius=radius, collision_mask="water-tile"}
		else
			local xx = roboport.position.x
			local yy = roboport.position.y
			local area = {{xx-radius, yy-radius}, {xx+radius, yy+radius}}
			tileCandidates = surface.find_tiles_filtered{area=area, collision_mask="water-tile"}
		end

		for _, tile in pairs(tileCandidates) do
			placeTile(surface, tile, roboport, tile_name)
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
				local rb = {surface=surfaceItem, roboport=roboportItem}
				table.insert(global.landcreepers.roboports, rb)
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