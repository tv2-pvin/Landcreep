local function addRoboport(roboport, checked)
	if global.roboports then
		global.roboports[tostring(roboport.position.x) .. tostring(roboport.position.y)] = {port=roboport, x=roboport.position.x, y=roboport.position.y, radius=roboport.logistic_cell.construction_radius * settings.global["landcreep_range"].value / 100, checked=checked}
	else
		global.roboports = {}
		global.roboports[tostring(roboport.position.x) .. tostring(roboport.position.y)] = {port=roboport, x=roboport.position.x, y=roboport.position.y, radius=roboport.logistic_cell.construction_radius * settings.global["landcreep_range"].value / 100, checked=checked}
	end
end

local function removeRoboport(roboport)
	if global.roboports then
		global.roboports[tostring(roboport.position.x) .. tostring(roboport.position.y)] = nil
	else
		global.roboports = {}
	end
end

local function init()
	global.roboports = global.roboports or {}
	for _, surface in pairs(game.surfaces) do
		for _, roboport in pairs(surface.find_entities_filtered{type="roboport"}) do
			addRoboport(roboport, false)
		end
	end
end

local function search(master, target)
    for _,v in next, master do
        if type(v)=="table" and v[target] then return true end
	end
	return false
end

local function isWaterTile(tile)
	if search(tile, "available_water") then -- repalces concrete and stone etc. atm
		return tile.available_water
	else
		return false
	end
end

local function checkRoboports()
	for _, roboport in pairs(global.roboports) do
		if roboport and roboport.port and roboport.port.valid then
			if roboport.port.logistic_cell.construction_radius == 0 then
				removeRoboport(roboport.port)
			end
		else
			removeRoboport(roboport.port)
		end
	end

	if not global.roboports or #global.roboports < 1 then
		init()
	end
end

local function landfill()
	init()
	checkRoboports()
	local constructionFactor = settings.global["landcreep_construction_factor"].value
	for _, roboport in pairs(global.roboports) do
		local port = roboport.port
		if not roboport.checked and port.logistic_network and port.logistic_network.valid and port.logistic_cell and port.logistic_cell.valid and port.logistic_network.get_item_count("landfill") > 0 then
			local amount = math.max(math.floor(port.logistic_network.available_construction_robots / constructionFactor), 1)
			local numberOfBotsSent = 0
			local radius = roboport.radius
			for xx = -radius, radius-1, 1 do
				for yy = -radius, radius-1, 1 do
					if numberOfBotsSent < amount then
						local tile = port.surface.get_tile(roboport.x + xx, roboport.y + yy)
						if not isWaterTile(tile) then
							if port.surface.can_place_entity{name="tile-ghost", position={tile.position.x, tile.position.y}, inner_name="landfill", force=port.force} then
								port.surface.create_entity{name="tile-ghost", position={tile.position.x, tile.position.y}, inner_name="landfill", force=port.force, expires=false}
								numberOfBotsSent = numberOfBotsSent + 1
								local area = {{roboport.x + xx-0.2, roboport.y + yy-0.2},{roboport.x + xx+0.8, roboport.y + yy + 0.8}}
								for _, tree in pairs(port.surface.find_entities_filtered{type = "tree", area=area}) do
									tree.order_deconstruction(port.force)
								end
								for _, rock in pairs(port.surface.find_entities_filtered{type = "simple-entity", area=area}) do
									rock.order_deconstruction(port.force)
								end
								for _, cliff in pairs(port.surface.find_entities_filtered{type = "cliff", limit=1, area=area}) do
									if port.logistic_network.get_item_count("cliff-explosives") > 0 then
										cliff.destroy()
										port.logistic_network.remove_item({name="cliff-explosives", 1})
									end
								end
							end
						end
					end
				end
			end
			if numberOfBotsSent < amount then
				removeRoboport(port)
				addRoboport(port, true)
			end
		else
			removeRoboport(port)
		end
	end
	return true
end

script.on_nth_tick(600, function()
	landfill()
end)