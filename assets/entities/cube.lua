local cpml = require "cpml"
local load = require "load-files"

return function(args)
	local entity = {
		name        = "CUBE AS FCUK",
		visible     = true,
		orientation = cpml.quat(0, 0, 0, 1),
		scale       = cpml.vec3(0.05, 0.05, 0.05),
		position    = cpml.vec3(),
		color       = { 1, 0, 1 },
		mesh        = load.model("assets/models/debug/unit-cube.iqm", false)
	}

	-- Override defaults
	if type(args) == "table" then
		for k, v in pairs(args) do
			entity[k] = v
		end
	end

	return entity
end
