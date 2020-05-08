
local function search(master, target)
    for k,v in next, master do
        if type(v)=="table" and v[target] then return true end
	end
	return false
end

local function isWaterTile(tile)
	if search(tile, "draw_in_water_layer") then
		return tile.draw_in_water_layer.value
	else
		return false
	end
end

local function landfill()
	local constructionFactor = settings.global["landcreep_construction_factor"].value
	local amount = 1
	local numberOfBotsSent = 1

	for _, surface in pairs(game.surfaces) do
		for _, roboport in pairs(surface.find_entities_filtered{type="roboport"}) do
			amount = math.max(math.floor(roboport.logistic_network.available_construction_robots / constructionFactor), 1)
			if roboport.logistic_network and roboport.logistic_network.valid then
				for xx = -1, 1, 1 do
					for yy = -1, 1, 1 do
						game.print("amount " .. tostring(amount) .. " numberOfBotsSent " .. tostring(numberOfBotsSent))
						if numberOfBotsSent < amount then 
							local tile = roboport.surface.get_tile(roboport.position.x + xx, roboport.position.y + yy)
							local ghost = tile
							if not tile.hidden_tile or (not string.find(tile.name, "landfill") and isWaterTile(tile)) then
								if roboport.surface.can_place_entity{name="tile-ghost", position={tile.position.x, tile.position.y}, inner_name="landfill", force=roboport.force} then
									roboport.surface.create_entity{name="tile-ghost", position={tile.position.x, tile.position.y}, inner_name="landfill", force=roboport.force, expires=false}
									numberOfBotsSent = numberOfBotsSent + 1
									for i, tree in pairs(roboport.surface.find_entities_filtered{type = "tree", area=area}) do
										tree.order_deconstruction(roboport.force)
									end
									for i, rock in pairs(roboport.surface.find_entities_filtered{type = "simple-entity", area=area}) do
										rock.order_deconstruction(roboport.force)
									end
									for i, cliff in pairs(roboport.surface.find_entities_filtered{type = "cliff", limit=1, area=area}) do
										if roboport.logistic_network.get_item_count("cliff-explosives") > 0 then
											cliff.destroy()
											roboport.logistic_network.remove_item({name="cliff-explosives", 1})
										end
									end
								end	
							end
						end
					end
				end

				return true
			else 
				return false
			end
		end
	end
	return true
end

script.on_nth_tick(600, function(event)
	local retries = 0
	while (not landfill()) and retries < 10 do
		game.print("landfill running again")
		retries = retries + 1
	end	
end)