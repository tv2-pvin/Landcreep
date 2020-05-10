script.on_init(function()
	global.landcreepers_has_run = false
end)

script.on_configuration_changed(function()
	global.landcreepers_has_run = false
end)

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


local function landcreep(roboport)
	if roboport and roboport.valid and roboport.logistic_cell and roboport.logistic_cell.valid and roboport.logistic_cell.construction_radius > 0 then
		local radius = roboport.logistic_cell.construction_radius
		for xx = -radius, radius, 1 do
			for yy = -radius, radius, 1 do
				local tile = roboport.surface.get_tile(roboport.position.x + xx, roboport.position.y + yy)
				if roboport.surface.can_place_entity{name="tile-ghost", position={tile.position.x, tile.position.y}, inner_name=global.landcreepers_tile, force=roboport.force} then
					roboport.surface.create_entity{name="tile-ghost", position={tile.position.x, tile.position.y}, inner_name=global.landcreepers_tile, force=roboport.force, expires=false}
				end
			end
		end
	end
end

script.on_nth_tick(60, function()
	if not global.landcreepers_has_run then
		initWaterTiles()
		for _, surface in pairs(game.surfaces) do
			for _, roboport in pairs(surface.find_entities_filtered{type="roboport"}) do
				landcreep(roboport)
			end
		end
		global.landcreepers_has_run = true
	end
end)

local function handleEntityBuiltEvent(event)
	if event.created_entity and event.created_entity.valid and event.created_entity.type == "roboport" then
		landcreep(event.created_entity)
	end
end

script.on_event(defines.events.on_built_entity, function(event)
	local status, err = pcall(function()
		handleEntityBuiltEvent(event)
	end)
	if not status then
		log(err)
		global.landcreepers_loaded = false
	end
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
	local status, err = pcall(function()
		handleEntityBuiltEvent(event)
	end)
	if not status then
		log(err)
		global.landcreepers_loaded = false
	end
end)