function hud.save_hunger(player)
	local file = io.open(minetest.get_worldpath().."/hud_"..player:get_player_name().."_hunger", "w+")
	if file then
		file:write(hud.hunger[player:get_player_name()])
		file:close()
	end
end

function hud.load_hunger(player)
	local file = io.open(minetest.get_worldpath().."/hud_"..player:get_player_name().."_hunger", "r")
	if file then
		hud.hunger[player:get_player_name()] = file:read("*all")
		file:close()
		return hud.hunger[player:get_player_name()]
	else
		return
	end
	
end

local function poisenp(tick, time, time_left, player)
	time_left = time_left + tick
	if time_left < time then
		minetest.after(tick, poisenp, tick, time, time_left, player)
	end
	if player:get_hp()-1 > 0 then
		player:set_hp(player:get_hp()-1)
	end
	
end

function hud.item_eat(hunger_change, replace_with_item, poisen)
	return function(itemstack, user, pointed_thing)
		if itemstack:take_item() ~= nil then
			local h = tonumber(hud.hunger[user:get_player_name()])
			h=h+hunger_change
			if h>30 then h=30 end
			hud.hunger[user:get_player_name()]=h
			hud.save_hunger(user)
			itemstack:add_item(replace_with_item) -- note: replace_with_item is optional
			--sound:eat
			if poisen then
				poisenp(1.0, poisen, 0, user)
			end
		end
		return itemstack
	end
end

local function overwrite(name, hunger_change, replace_with_item, poisen)
	local tab = minetest.registered_items[name]
	if tab == nil then return end
	tab.on_use = hud.item_eat(hunger_change, replace_with_item, poisen)
	minetest.registered_items[name] = tab
end

minetest.after(0.5, function()--ensure all other mods get loaded
if minetest.get_modpath("farming") ~= nil then
	overwrite("farming:cake", 16)
end

if minetest.get_modpath("bushes") ~= nil then
    for _, row in ipairs(bushes_classic.bushes) do
	    local name = row[1]
	    overwrite("bushes:sugar", 1)
	    overwrite("bushes:"..name, 1)
	    overwrite("bushes:"..name.."_pie_raw", 4)
	    overwrite("bushes:"..name.."_pie_cooked", 6)
	    overwrite("bushes:"..name.."_pie_slice", 1)
	    overwrite("bushes:basket_"..name, 18)
    end
end
end)
