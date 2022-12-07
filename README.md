<h1 align="center">Sprint Stumble</h1>

<p align="center">
   <a href="https://www.moddb.com/mods/stalker-anomaly/addons/sprint-stumble" title="Download Sprint Stumble - Mod DB" target="_blank">
      <img src="https://button.moddb.com/download/medium/241415.png" alt="Sprint Stumble" />
   </a>
</p>

<br>

**MCM is Supported**

Gives the character to stumble when sprinting depending on the **weather, inventory
weight, and health**.

<br>


## How it Works

The computation of the probability is **not 0 to 1 but 0 to 100**. So 10% is not 0.1 but
10, 25% is not 0.25 but 25%.

<br>


### Weather to Ground Material Factor (30%)

To increase the percentage, change the value of this variable.
```lua
local MAX_WEATHER_TO_MATERIAL_MULTIPLIER = 30
```

Ground materials increases the chance of stumbling depending on the weather. If the
materials are not listed below the MATERIAL_MULTIPLIER variable, the default value is
going to be the value of DEFAULT_MATERIAL_MULTIPLIER.
```lua
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
```

The chances increases during rainy or stormy weathers. If the materials are not inside the
WET_WEATHER_MATERIAL_MULTIPLIER, then the default value will be the value of
DEFAULT_WET_WEATHER_MATERIAL_MULTIPLIER.
```lua
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
```

During Psi Storm and Emissions the Chance will maxed out to 30. Why? **To increase the
suffering that's why**.
```lua
-- for more tense running to cover
local BLOWOUT_PSISTORM_WEATHER_MULTIPLIER = 30
local BLOWOUT_PSISTORM_WEATHER = {
   fx_blowout_day = true,
   fx_blowout_night = true,
   fx_psi_storm_day = true,
   fx_psi_storm_night = true
}
```

The numbers can be modified as long as they are less than or equal to 30.

<br>


### Weight Factor (10%)

Why only 10%? Because most of the time the actor or the character always carry at least
70% of the max carry weight.

To change the percentage of the Weight Factor, just change the value of this variable.
```lua
local INV_WEIGHT_MULTIPLIER = 10
```

<br>


### Health Factor (40%)

Health has the largest factor because you can't run well if you're not also feeling well.

To change the percentage, just change the value of this variable.
```lua
local HEALTH_MULTIPLIER = 40
```

<br>


### Totalling of the Three Factors

The weather factor and the weight factor will be randomized.
```lua
-- randomize weather factor and inentory weight factor to for pure luck
rnd_weather_factor = math.random(0, weather_factor)
rnd_inv_weight_factor = math.random(0, inv_weight_factor)
```

The three factors will be totaled and will be deducted to 100. The closer the stability to
0, the higher the chance the character will stumble.
```lua
-- chance of stumbling
-- the lower the total_stability, the higher the chance it will pick 0
local stability = 100
stability = stability - (rnd_weather_factor + rnd_inv_weight_factor + health_factor)
stability = math.random(0, stability)
```

If ```stability``` become 0, then the character will stumble.
```lua
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
```

<br>


### Triggers For Stumbling

#### Health Amount
If the current health amount is less than or equal to the value of the ```HEALTH_AMOUNT_TRIGGER```
variable, which can be assigned in the MCM Menu for this addon

#### Rain or Storm Weathers
Even if the current health amount is greater than the value of ```HEALTH_AMOUNT_TRIGGER```
variable, as long as it is raining then the character will stumble when sprinting.

#### Overweight
Same as the Rain or Storm Weathers, it will ignore the Health Amount Trigger. It is when
the current inventory weight is greater than the maximum inventory weight.

#### Sprinting
The character will stumble when sprinting, it still depends on the three triggers above.

```lua
local WET_WEATHER = {
   w_rain1 = true,
   w_rain2 = true,
   w_rain3 = true,
   w_storm1 = true,
   w_storm2 = true,
}

-- get the assigned value in MCM
function load_settings()
   if ui_mcm then
      HEALTH_AMOUNT_TRIGGER = ui_mcm.get("sprint_stumble/HEALTH_AMOUNT_TRIGGER") * 0.01
   end
end

function actor_on_footstep(mat)
   -- health amount variable
   local health = db.actor.health

   -- current weather variable
   local current_weather = FIRST_LEVEL_WEATHER or get_current_weather_file()

   -- weight variables
   local current_inv_weight = db.actor:get_total_weight()
   local max_inv_weight = get_max_inv_weight()
   local overweight = current_inv_weight > max_inv_weight

   -- override HEALTH_AMOUNT_TRIGGER if it's a wet weather or overweight
   if WET_WEATHER[current_weather] or overweight then
      HEALTH_AMOUNT_TRIGGER = 1
   end

   if health <= HEALTH_AMOUNT_TRIGGER and IsMoveState('mcSprint') then

      -- compute stability here

   end
end

```

<br>
