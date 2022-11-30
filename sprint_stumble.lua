-- based on the "Falls" addon of FeldW
-- health, weather, and terrain (type of ground) can affect the chance of stumbling
-- the computation of probability is not the standard 0 to 1, but 0 to 100
-- requires demonized_time_events

-- default max factor for material chance is 30 (30%)
-- default max factor for inventory weight is 10 (10%)
-- default max factor for health chance is 40 (40%)

local CreateTimeEvent = demonized_time_events.CreateTimeEvent
local RemoveTimeEvent = demonized_time_events.RemoveTimeEvent

local DEBUG_MODE = false
local CONSOLE_LOG = false -- true if you want to output the logs in the console
local BANDIT_PAIN = false

local HEALTH_MULTIPLIER = 40
local INV_WEIGHT_MULTIPLIER = 10

-- dry weather material factor
local DEFAULT_MATERIAL_MULTIPLIER = 5
local MATERIAL_MULTIPLIER = {
	["materials\\earth"] = 10,
	["materials\\grass"] = 10,
	["materials\\wooden_board"] = 5,
	["materials\\gravel"] = 15,
	["materials\\bush"] = 20,
	["materials\\water"] = 30,
	["materials\\tree_trunk"] = 5,
	["materials\\body"] = 15,
	["materials\\monster_body"] = 15,
	["materials\\dead_body"] = 15,
	["materials\\metal"] = 5,
}

local WET_WEATHER = {
	w_rain1 = true,
	w_rain2 = true,
	w_rain3 = true,
	w_storm1 = true,
	w_storm2 = true,
}

-- wet weathers should make the materials a little bit slippery
local DEFAULT_WET_WEATHER_MATERIAL_MULTIPLIER = 10
local WET_WEATHER_MATERIAL_MULTIPLIER = {
	["materials\\earth"] = 20,
	["materials\\grass"] = 20,
	["materials\\wooden_board"] = 15,
	["materials\\gravel"] = 20,
	["materials\\bush"] = 20,
	["materials\\water"] = 30,
	["materials\\tree_trunk"] = 25,
	["materials\\body"] = 20,
	["materials\\monster_body"] = 20,
	["materials\\dead_body"] = 20,
	["materials\\metal"] = 20,
}

-- for more tense running to cover
local BLOWOUT_PSISTORM_WEATHER_MULTIPLIER = 30
local BLOWOUT_PSISTORM_WEATHER = {
	fx_blowout_day = true,
	fx_blowout_night = true,
	fx_psi_storm_day = true,
	fx_psi_storm_night = true
}

-- MCM support
function load_settings()
	if ui_mcm then
		DEBUG_MODE = ui_mcm.get("sprint_stumble/DEBUG_MODE")
		CONSOLE_LOG = ui_mcm.get("sprint_stumble/CONSOLE_LOG")
		BANDIT_PAIN = ui_mcm.get("sprint_stumble/BANDIT_PAIN")
	end
end

local FIRST_LEVEL_WEATHER = nil
function actor_on_first_update()
	if is_blowout_psistorm_weather() and DEBUG_MODE == true then
		FIRST_LEVEL_WEATHER = nil
	else
		FIRST_LEVEL_WEATHER = get_current_weather_file()
	end
	RemoveTimeEvent("reset_first_level_weather", "reset_first_level_weather")
end

function actor_on_footstep(mat)
	local health = db.actor.health
	local health_factor = 0

	-- weather to material factor
	local current_weather = FIRST_LEVEL_WEATHER or get_current_weather_file()
	local weather_factor = 0
	local rnd_weather_factor = 0

	-- Current weight
	local current_inv_weight = db.actor:get_total_weight()
	local max_inv_weight = get_max_inv_weight()
	local inv_weight_factor = 0
	local rnd_inv_weight_factor = 0

	local total_stability = 100	-- 100%
	local stability = 100

	-- the stumbling will only happen when sprinting
	if IsMoveState('mcSprint') then
		if is_blowout_psistorm_weather() then
			weather_factor = BLOWOUT_PSISTORM_WEATHER_MULTIPLIER
		elseif WET_WEATHER[current_weather] then
			weather_factor = WET_WEATHER_MATERIAL_MULTIPLIER[mat] or DEFAULT_WET_WEATHER_MATERIAL_MULTIPLIER
		else
			weather_factor = MATERIAL_MULTIPLIER[mat] or DEFAULT_MATERIAL_MULTIPLIER
		end

		-- inventory weight factor
		if current_inv_weight > max_inv_weight then
			inv_weight_factor = INV_WEIGHT_MULTIPLIER
		else
			inv_weight_factor = normalize(current_inv_weight, 0, max_inv_weight)
			inv_weight_factor = denormalize(inv_weight_factor, 0, INV_WEIGHT_MULTIPLIER)
		end

		-- health factor
		health_factor = denormalize(health, HEALTH_MULTIPLIER, 0)

		-- randomize weather factor and inentory weight factor to for pure luck
		rnd_weather_factor = math.random(0, weather_factor)
		rnd_inv_weight_factor = math.random(0, inv_weight_factor)

		-- total all factors and deduc it to 100
		-- total_stability = total_stability - (weather_factor + health_factor + inv_weight_factor)
		total_stability = total_stability - (weather_factor + health_factor + inv_weight_factor)

		-- chance of stumbling
		-- the lower the total_stability, the higher the chance it will pick 0
		stability = stability - (rnd_weather_factor + rnd_inv_weight_factor + health_factor)
		stability = math.random(0, stability)

		-- if stability is 0 based on randomization then the character will stumble
		if stability == 0 then
			-- jump to prone when stumbled
			level.press_action(bind_to_dik(key_bindings.kCROUCH))
			level.press_action(bind_to_dik(key_bindings.kACCEL))

			-- play pain sounds when grok's body health system is installed
			hurt_sound()

			if not game.actor_weapon_lowered() then
				game.actor_lower_weapon(true)
			end
			level.add_cam_effector("script\\sprint_stumble.anm", 1, false, "")

			-- fixes the unable to ammo-check when stumbled
			level.release_action(bind_to_dik(key_bindings.kACCEL))
		end
	end

	if CONSOLE_LOG == true then
		printf("material: " .. mat)
		printf("current_weather: " .. current_weather)
		printf("FIRST_LEVEL_WEATHER: " .. FIRST_LEVEL_WEATHER)
		printf("--------------------")
		printf("total weight: " .. current_inv_weight)
		printf("max_weight: " .. max_inv_weight)
		printf("--------------------")
		printf("health_factor: " .. health_factor)
		printf("--------------------")
		printf("inv_weight_factor: " .. inv_weight_factor)
		printf("rnd_inv_weight_factor: " .. rnd_inv_weight_factor)
		printf("--------------------")
		printf("weather_factor: " .. weather_factor)
		printf("rnd_weather_factor: " .. rnd_weather_factor)
		printf("--------------------")
		printf("total_stability: " .. total_stability)
		printf("stability: " .. stability)
		printf("--------------------")
		printf("--------------------")
	end
end

-- copied from ui_inventory.script
function get_max_inv_weight()
	local actor = db.actor
	local outfit = actor:item_in_slot(7)
	local backpack = actor:item_in_slot(13)

	-- Additional weight - Actor
	local max_weight = actor:get_actor_max_weight()

	-- Additional weight - Outfit
	max_weight = max_weight + (outfit and outfit:get_additional_max_weight() or 0)

	-- Additional weight - Backpack
	max_weight = max_weight + (backpack and backpack:get_additional_max_weight() or 0)

	-- Additional weight - Artefacts
	actor:iterate_belt( function(owner, obj)
		local c_arty = obj:cast_Artefact()
		max_weight = max_weight + (c_arty and c_arty:AdditionalInventoryWeight() or 0)
	end)

	-- Additional weight - Booster
	actor:cast_Actor():conditions():BoosterForEach( function(booster_type, booster_time, booster_value)
		if (booster_type == 4) then --eBoostMaxWeight
			max_weight = max_weight + booster_value
		end
	end)

	return max_weight
end

-- copied from grok's body health system (zzz_player_injuries.script)
-- pain sounds when grok's body health system is installed
function hurt_sound()
	local file
	local sound_play = math.random(1,13)
	local helmet = (db.actor:item_in_slot(12) or db.actor:get_current_outfit())

	if BANDIT_PAIN == true then
		file = "sprint_stumble_bandit\\pain_" .. sound_play
	elseif helmet then
		muffle = "m_"
		file = "bhs\\" .. muffle .. "pain_" .. sound_play
	else
		muffle = ""
		file = "actor\\pain_" .. sound_play
	end

	file_to_say = sound_object( file )
	file_to_say:play(db.actor,0,sound_object.s2d)
end

function is_blowout_psistorm_weather()
	local weather = get_current_weather_file()
	if BLOWOUT_PSISTORM_WEATHER[weather] then
		return true
	end
	return false
end

function get_current_weather_file()
	return level.get_weather()
end

function normalize(val, min, max)
	return (val - min) / (max - min)
end

function denormalize(val, min, max)
	return val * (max - min) + min
end

function actor_on_sleep()
	CreateTimeEvent("reset_first_level_weather", "reset_first_level_weather", 3, actor_on_first_update)
end

function on_game_start()
	-- MCM support
	RegisterScriptCallback("on_option_change", load_settings)
	RegisterScriptCallback("actor_on_first_update", load_settings)
	-- MCM support

	RegisterScriptCallback("actor_on_footstep", actor_on_footstep)
	RegisterScriptCallback("actor_on_first_update", actor_on_first_update)
	RegisterScriptCallback("actor_on_sleep", actor_on_sleep)
end

