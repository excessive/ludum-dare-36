-- Dickburger 2015.12.12 export
return {
	version = 20151212,
	objects = {
		{
			name           = "Water Plane",
			rigid_body     = true,
			actor          = false,
			visible        = true,
			always_visible = true,
			position       = { 0, 0, 0 },
			scale          = { 1000, 1000, 1000 },
			path           = "assets/models/debug/unit-plane.iqm",
			shader         = "water",
			color          = { 0.15, 0.55, 0.65, 0.25 },
			textures       = {
				Material = "assets/textures/lol.jpg"
			}
		},
		{
			name           = "Forest",
			rigid_body     = true,
			actor          = true,
			visible        = true,
			always_visible = true,
			position       = { 0, 0, 0 },
			scale          = { 1, 1, 1 },
			path           = "assets/models/forest.iqm",
			color          = { 0.8, 0.8, 0.8 }
		},
		{
			name        = "Waypoint",
			waypoint    = 1,
			time        = 120,
			instance    = true,
			actor       = true,
			visible     = false,
			orientation = { 0, 0, 0, 1 },
			color       = { 1, 0, 0 },
			scale       = { 30, 30, 10 },
			path        = "assets/models/debug/unit-cube.iqm"
		},
		{
			name        = "Amazon Warehouse",
			home        = true,
			instance    = true,
			actor       = true,
			visible     = false,
			orientation = { 0, 0, 0, 1 },
			color       = { 1, 1, 0 },
			position    = { 0, 0, 71 },
			scale       = { 50, 50, 35 },
			path        = "assets/models/debug/unit-cube.iqm"
		},
		{
			name        = "Waypoint",
			waypoint    = 4,
			time        = 240,
			instance    = true,
			actor       = true,
			visible     = false,
			orientation = { 0, 0, 0, 1 },
			color       = { 1, 0, 0 },
			scale       = { 30, 30, 10 },
			path        = "assets/models/debug/unit-cube.iqm"
		},
		{
			name        = "Waypoint",
			waypoint    = 8,
			time        = 85,
			instance    = true,
			actor       = true,
			visible     = false,
			orientation = { 0, 0, 0, 1 },
			color       = { 1, 0, 0 },
			scale       = { 30, 30, 10 },
			path        = "assets/models/debug/unit-cube.iqm"
		},
		{
			name        = "Waypoint",
			waypoint    = 3,
			time        = 120,
			instance    = true,
			actor       = true,
			visible     = false,
			orientation = { 0, 0, 0, 1 },
			color       = { 1, 0, 0 },
			scale       = { 30, 30, 10 },
			path        = "assets/models/debug/unit-cube.iqm"
		},
		{
			name        = "Waypoint",
			waypoint    = 9,
			time        = 250,
			instance    = true,
			actor       = true,
			visible     = false,
			orientation = { 0, 0, 0, 1 },
			color       = { 1, 0, 0 },
			scale       = { 30, 30, 10 },
			path        = "assets/models/debug/unit-cube.iqm"
		},
	},
}
