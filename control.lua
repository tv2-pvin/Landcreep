script.on_init(function()
	global.landcreepers_has_run = false
end)

local function readSetting(key, defaultValue)
	if settings.global[key] ~= nil then
		return settings.global[key].value
	end
	return defaultValue
end

local function addToSet(set, key)
    set[key] = true
end

local function setContains(set, key)
    return set[key] ~= nil
end


local function initWaterTiles()
	global.landcreepers_water_tiles = {}
	--- vanilla
	if not setContains(global.landcreepers_water_tiles, "water") then
		addToSet(global.landcreepers_water_tiles, "water")
	end
	if not setContains(global.landcreepers_water_tiles, "water-green") then
		addToSet(global.landcreepers_water_tiles, "water-green")
	end
	if not setContains(global.landcreepers_water_tiles, "water-mud") then
		addToSet(global.landcreepers_water_tiles, "water-mud")
	end
	if not setContains(global.landcreepers_water_tiles, "water-shallow") then
		addToSet(global.landcreepers_water_tiles, "water-shallow")
	end
	if not setContains(global.landcreepers_water_tiles, "deepwater") then
		addToSet(global.landcreepers_water_tiles, "deepwater")
	end
	if not setContains(global.landcreepers_water_tiles, "deepwater-green") then
		addToSet(global.landcreepers_water_tiles, "deepwater-green")
	end
	--- spaceblock
	for i=1, 8, 1 do
		if not setContains(global.landcreepers_water_tiles, "space-tile-"..i) then
			addToSet(global.landcreepers_water_tiles, "space-tile-"..i)
		end
	end
end

local function placeLandfill(roboport, tile)
	local tile_name = readSetting("landcreep_tile_override", "landfill")
	if roboport.surface.can_place_entity{name="tile-ghost", position={tile.position.x, tile.position.y}, inner_name=tile_name, force=roboport.force} then
		roboport.surface.create_entity{name="tile-ghost", position={tile.position.x, tile.position.y}, inner_name=tile_name, force=roboport.force, expires=false}
		return 1
	end
	return 0
end

local function hasValidLogisticsNetwork(roboport)
	return roboport.logistic_network and roboport.logistic_network.valid
end

local function hasItem(roboport)
	return hasValidLogisticsNetwork(roboport) and roboport.logistic_network.get_item_count(readSetting("landcreep_tile_override", "landfill")) > 0
end

local function hasRobots(roboport)
	return hasValidLogisticsNetwork(roboport) and roboport.logistic_network.available_construction_robots > 0
end

local function landcreep(roboport)
	if roboport and roboport.valid and roboport.logistic_cell and roboport.logistic_cell.valid and roboport.logistic_cell.construction_radius > 0 then
		local radius = roboport.logistic_cell.construction_radius
		local xStart = -radius
		local xStop = radius-1
		local x = 0
		if readSetting("landcreepers_iterate_less_than_one_roboport", true) then
			xStart = global.landcreepers_roboport_index_x or xStart
			xStop = math.min(xStart + readSetting("landcreepers_iterate_less_than_one_roboport_number_of_columns", 5), radius-1)
		end
		local only_tile_avail = readSetting("landcreepers_only_place_if_landfill_available", true)
		local only_robots_avail = readSetting("landcreepers_only_place_if_robots_available", true)
		for xx = xStart, xStop, 1 do
			for yy = -radius, radius-1, 1 do
				local tile = roboport.surface.get_tile(roboport.position.x + xx, roboport.position.y + yy)
				if only_tile_avail then
					if only_robots_avail then
						if hasItem(roboport) and hasRobots(roboport) then
							placeLandfill(roboport, tile)
						end
					else
						if hasItem(roboport) then
							placeLandfill(roboport, tile)
						end
					end
				else
					if only_robots_avail then
						if hasRobots(roboport) then
							placeLandfill(roboport, tile)
						end
					else
						placeLandfill(roboport, tile)
					end
				end
			end
			x = xx
		end
		if x == radius-1 then
			global.landcreepers_roboport_index = global.landcreepers_roboport_index + 1
			global.landcreepers_roboport_index_x = nil
		else
			global.landcreepers_roboport_index_x = x
		end
		return
	else
		table.remove(global.landcreepers_roboports, global.landcreepers_roboport_index)
		return
	end
end

script.on_nth_tick(600, function()
	if global.landcreepers_roboports == nil then
		global.landcreepers_has_run = false
	end

	if not global.landcreepers_has_run then
		global.landcreepers_roboports = {}
		for _, surface in pairs(game.surfaces) do
			for _, roboport in pairs(surface.find_entities_filtered{type="roboport"}) do
				table.insert(global.landcreepers_roboports, roboport)
			end
		end
		initWaterTiles()
		global.landcreepers_roboport_index = 1
		global.landcreepers_has_run = true
	end

	if (global.landcreepers_roboport_index > #global.landcreepers_roboports) then
		global.landcreepers_roboport_index = 1
	end

	landcreep(global.landcreepers_roboports[global.landcreepers_roboport_index])
end)

local function handleEntityBuiltEvent(event)
	if event.created_entity and event.created_entity.valid and event.created_entity.type == "roboport" then
		table.insert(global.landcreepers_roboports, event.created_entity)
	end
end

script.on_event(defines.events.on_built_entity, function(event)
	handleEntityBuiltEvent(event)
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
	handleEntityBuiltEvent(event)
end)