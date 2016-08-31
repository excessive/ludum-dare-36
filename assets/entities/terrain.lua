local cpml  = require "cpml"
local load  = require "load-files"

return function(args)
	local entity = {
		name        = "Terrain",
		visible     = true,
		always_visible = true,
		position    = cpml.vec3(),
		orientation = cpml.quat(0, 0, 0, 1),
		scale       = cpml.vec3(1, 1, 1),
		color       = { 0.8, 0.8, 0.8 },
		mesh        = load.model("assets/models/test_level_66.iqm", true)
	}

	-- Override defaults
	if type(args) == "table" then
		for k, v in pairs(args) do
			entity[k] = v
		end
	end

	-- Cast triangles to vertices
	for _, t in ipairs(entity.mesh.triangles) do
		t[1] = cpml.vec3(t[1].position)
		t[2] = cpml.vec3(t[2].position)
		t[3] = cpml.vec3(t[3].position)
	end

	return entity
end
