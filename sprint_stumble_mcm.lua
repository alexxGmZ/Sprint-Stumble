function on_mcm_load()
	op = {
		id = "sprint_stumble",
		sh = true,
		gr = {
			{id = "title", type = "slide", link = "ui_options_slider_player", text = "ui_mcm_sprint_stumble_title", size = {512, 50}, spacing = 20 },
			{id = "ENABLE", type = "check", val = 1, def = true},
			{id = "DEBUG_MODE", type = "check", val = 1, def = false},
			{id = "CONSOLE_LOG", type = "check", val = 1, def = false},
			{id = "BANDIT_PAIN", type = "check", val = 1, def = false},
		}
	}
	return op
end
