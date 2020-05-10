local function addToSet(set, key)
    set[key] = true
end

local function setContains(set, key)
    return set[key] ~= nil
end

local function addRoboport(roboport, opRadius, checked, timeout, timesChecked)
	table.insert(
		global.landcreepers,
		{
			port=roboport,
			x=roboport.position.x,
			y=roboport.position.y,
			op_radius=opRadius,
			radius=roboport.logistic_cell.construction_radius * settings.global["landcreep_range"].value / 100,
			checked=checked,
			timeout=timeout,
			timesChecked=timesChecked
		}
	)
end

local function updateRoboport(index, roboport, opRadius, checked, timeout, timesChecked)
	table.remove(global.landcreepers, index)
	addRoboport(roboport, opRadius, checked, timeout, timesChecked)
end



local function initWaterTiles()
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

local function init()
	global.landcreepers_loaded=false
	global.landcreepers = {}
	global.landcreepers_water_tiles = {}
	global.landcreepers_tile = settings.global['landcreep_landfill_tile_override'].value
	if global.landcreepers_tile ~= nil then
		global.landcreepers_tile = "landfill"
	end
	initWaterTiles()
	for _, surface in pairs(game.surfaces) do
		for _, roboport in pairs(surface.find_entities_filtered{type="roboport"}) do
			addRoboport(roboport, 1, false, 0, 0)
		end
	end
	global.landcreepers_loaded=true
end



local function isWaterTile(tile)
	return setContains(global.landcreepers_water_tiles, tile.name)
end

local function placeLandfill(roboport, numberOfBotsSent, amount, tile)
	if isWaterTile(tile) and roboport.logistic_network.get_item_count(global.landcreepers_tile) > 0 and numberOfBotsSent < amount then
		if roboport.surface.can_place_entity{name="tile-ghost", position={tile.position.x, tile.position.y}, inner_name=global.landcreepers_tile, force=roboport.force} then
			roboport.surface.create_entity{name="tile-ghost", position={tile.position.x, tile.position.y}, inner_name=global.landcreepers_tile, force=roboport.force, expires=false}
			numberOfBotsSent = numberOfBotsSent + 1
		end
	end
	return numberOfBotsSent
end

local function iter(index, roboport, amount, opRadius, radius, timeout, timesChecked)
	local numberOfBotsSent = 0
	for xx = -opRadius, opRadius-1, 1 do
		for yy = -opRadius, opRadius-1, 1 do
			if xx <= -opRadius+1 or xx >= opRadius-2 or yy <= -opRadius+1 or yy >= opRadius-2 then --Check only the outer ring, width 2.
				local tile = roboport.surface.get_tile(roboport.position.x + xx, roboport.position.y + yy)
				if numberOfBotsSent < amount and isWaterTile(tile) then
					numberOfBotsSent = placeLandfill(roboport, numberOfBotsSent, amount, tile)
				end
			end
		end
	end
	updateRoboport(index, roboport, opRadius+1, radius == opRadius+1, timeout, timesChecked)
end

local function getAmountOfRobotsToSend(roboport)
	local constructionFactor = settings.global["landcreep_construction_factor"].value
	local maxSetting = settings.global['landcreep_maximum_number_of_orders'].value
	if maxSetting == 0 then
		return math.min(math.max(math.floor(roboport.logistic_network.available_construction_robots / constructionFactor), 1), roboport.logistic_network.get_item_count(global.landcreepers_tile))
	else
		return math.min(maxSetting, math.min(math.max(math.floor(port.logistic_network.available_construction_robots / constructionFactor), 1), port.logistic_network.get_item_count(global.landcreepers_tile)))
	end
end

local function landfill(index)
	local roboport = global.landcreepers[index]
	local port = roboport.port
	if roboport and not roboport.checked then
		if port.valid and port.logistic_network and port.logistic_network.valid and port.logistic_cell and port.logistic_cell.valid then
			if port.logistic_network.get_item_count(global.landcreepers_tile) > 0 then
				local amount = getAmountOfRobotsToSend(port)
				iter(index, port, amount, roboport.op_radius, roboport.radius, roboport.timeout, roboport.timesChecked)
			end
		else
			table.remove(global.landcreepers, index)
		end
	else
		if roboport.timeout >= 1000 then
			if roboport.timesChecked >= 5 then
				table.remove(global.landcreepers, index)
			else
				updateRoboport(index, roboport.port, 1, false, 0, roboport.timesChecked+1)
			end
		else
			updateRoboport(index, roboport.port, roboport.op_radius, roboport.checked, roboport.timeout+1, roboport.timesChecked)
		end
	end
end

script.on_init(function()
	local status, err = pcall(function()
		init()
		global.landcreepers_loaded = true
	end)
	if not status then
		log(err)
		global.landcreepers_loaded = false
	end
end)

script.on_configuration_changed(function()
	local status, err = pcall(function()
		init()
		global.landcreepers_loaded = true
	end)
	if not status then
		log(err)
		global.landcreepers_loaded = false
	end
end)

script.on_nth_tick(settings.global["landcreep_tick_interval"].value, function()
	local status, err = pcall(function()
		if not global.landcreepers_loaded then
			init()
		end
		for i=1, #global.landcreepers, 1 do
			landfill(i)
		end
	end)
	if not status then
		log(err)
		global.landcreepers_loaded = false
	end
end)

script.on_nth_tick(10000*settings.global['landcreep_tick_interval'].value, function()
	global.landcreepers_loaded = false
end)

local function handleEntityBuiltEvent(event)
	if event.created_entity and event.created_entity.valid and event.created_entity.type == "roboport" then
		addRoboport(event.created_entity, 1, false)
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