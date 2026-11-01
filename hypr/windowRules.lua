local floatingWindows = {
	{ class = "^(steam)$", title = "^(Friends List)$" },
	{ class = "steam_app_4227351746", title = "^(Battle.net)$" },
	{ class = "steam_app_4227351746", title = "^(Battle.net - Chats and Groups)$" },
}

for i, m in ipairs(floatingWindows) do
	hl.window_rule({
		name = "floating-windows" .. i,
		match = m,

		float = true,
		center = true,
	})
end

-- Hyprland-run windowrule
hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },

	move = "20 monitor_h-120",
	float = true,
})

hl.window_rule({
	-- Ignore maximize requests from all apps. You'll probably like this.
	name = "suppress-maximize-events",
	match = { class = ".*" },

	suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
	-- Fix some dragging issues with XWayland
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})

hl.window_rule({
	name = "battle-net-wine",
	match = {
		class = "steam_app_4227351746",
		title = "^$",
	},

	workspace = "special:hidden silent",
	no_focus = true,
})

hl.window_rule({
	name = "battle-net-games",
	match = {
		class = "steam_app_4227351746",
		title = "^(World of Warcraft)$",
	},

	fullscreen = true,
	idle_inhibit = "fullscreen",
	immediate = true,
})
