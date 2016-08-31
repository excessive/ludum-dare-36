local cpml  = require "cpml"
local timer = require "timer"
local load  = require "load-files"

return function(args)
	local entity = {
		name        = "Player",
		visible     = true,
		always_visible = true,
		rigid_body  = true,
		wireframe   = false,
		mass        = 15,
		run_speed   = 5,
		flight_speed = 3,
		max_speed   = 25,
		height_limit  = 40,
		height_normal = 40,
		height_return = 100,
		radius      = cpml.vec3(0.6, 0.9, 0.5),
		lifter      = cpml.vec3(0.3, 0.3, 0.3),
		orientation = cpml.quat(0, 0, 0, 1),
		scale       = cpml.vec3(1, 1, 1),
		position    = cpml.vec3(0, 0, 2),
		velocity    = cpml.vec3(0, 0, 0),
		force       = cpml.vec3(0, 0, 0),
		color       = { 1, 1, 1 },
		bonks       = 0,
		strikes     = 0,
		packages    = 0,
		turbo       = false,
		turbo_time  = 10,
		mesh        = load.model("assets/models/bird.iqm", false),
		animation   = load.anims("assets/models/bird.iqm"),
		markers     = load.markers("assets/markers/player.lua"),
		timer       = timer.new()
	}

	entity.capsule = {
		a      = cpml.vec3(),
		b      = cpml.vec3(),
		radius = 0.5
	}

	entity.capsule_offset = {
		a  = cpml.vec3(0, 0, entity.radius.z + entity.capsule.radius),
		b  = cpml.vec3(0, 0, entity.radius.z - entity.capsule.radius)
	}

	-- Override defaults
	if type(args) == "table" then
		for k, v in pairs(args) do
			entity[k] = v
		end
	end

	entity.direction = entity.orientation * -cpml.vec3.unit_y

	if entity.animation then
		entity.animation:play("idle")
	end

	return entity
end
