function on_mcm_load()
	op = {
		id = "sprint_stumble",
		sh = true,
		gr = {
			{id = "title", type = "slide", link = "ui_options_slider_player", text = "ui_mcm_sprint_stumble_title", size = {512, 50}, spacing = 20 },

			-- {id = "DRY_MATERIAL_MULTIPLIER", type = "track", val = 2,
			-- 	def = 5,
			-- 	min = 0,
			-- 	max = 30,
			-- 	step =1
			-- },
			-- {id = "DRY_MATERIAL_MULTIPLIER_EARTH", type = "track", val = 2,
			-- 	def = 10,
			-- 	min = 0,
			-- 	max = 30,
			-- 	step = 1
			-- },
			-- {id = "DRY_MATERIAL_MULTIPLIER_GRASS", type = "track", val = 2,
			-- 	def = 10,
			-- 	min = 0,
			-- 	max = 30,
			-- 	step = 1
			-- },
			-- {id = "DRY_MATERIAL_MULTIPLIER_WOODEN_BOARD", type = "track", val = 2,
			-- 	def = 6,
			-- 	min = 0,
			-- 	max = 30,
			-- 	step = 1
			-- },
			-- {id = "DRY_MATERIAL_MULTIPLIER_WOODEN_BOARD", type = "track", val = 2,
			-- 	def = 6,
			-- 	min = 0,
			-- 	max = 30,
			-- 	step = 1
			-- },
			-- {id = "DRY_MATERIAL_MULTIPLIER_WOODEN_BOARD", type = "track", val = 2,
			-- 	def = 6,
			-- 	min = 0,
			-- 	max = 30,
			-- 	step = 1
			-- },
			-- {id = "DRY_MATERIAL_MULTIPLIER_WOODEN_BOARD", type = "track", val = 2,
			-- 	def = 6,
			-- 	min = 0,
			-- 	max = 30,
			-- 	step = 1
			-- },
			-- {id = "DRY_MATERIAL_MULTIPLIER_WOODEN_BOARD", type = "track", val = 2,
			-- 	def = 6,
			-- 	min = 0,
			-- 	max = 30,
			-- 	step = 1
			-- },

			{id = "divider", type = "line"},

			{id = "WET_WEATHERS_ONLY", type = "check", val = 1, def = false},
			{id = "BANDIT_PAIN", type = "check", val = 1, def = false},
			{id = "CONSOLE_LOG", type = "check", val = 1, def = false},
			{id = "DEBUG_MODE", type = "check", val = 1, def = false},
		}
	}
	return op
end
