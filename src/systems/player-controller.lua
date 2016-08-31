local conversation = _G.conversation

local tiny    = require "tiny"
local cpml    = require "cpml"

local actions = {
	idle = {
		name               = "idle",
		animation          = "idle",
		can_be_interrupted = true,
		align_to_camera    = false,
		lock_position      = false,
		lock_velocity      = false
	}
}

local function toggle_mouse(self)
	love.mouse.setRelativeMode(not self.in_menu)
	if self.in_menu then
		local w, h = love.graphics.getDimensions()
		love.mouse.setPosition(w/2, h/2)
	end
end

local system = tiny.system {
	name      = "Player Controller",
	priority  = 2,
	filter    = tiny.requireAll("possessed", "orientation"),
	dead_zone = 0.25
}

function system:onAddToWorld(world)
	toggle_mouse(self)
	self.listeners = {
		conversation:listen("player up", function(player)
			-- push just enough to counteract gravity
			player.force.z = player.force.z + 9 * player.mass
		end),

		conversation:listen("player down", function(player)
			-- push just enough to counteract gravity
			player.force.z = player.force.z - 9 * player.mass
		end),
	}
end

function system:onRemoveFromWorld(world)
	for _, listener in ipairs(self.listeners) do
		conversation:stopListening(listener)
	end
end

function system:onAdd(entity)
	entity.current_action = false
end

function system:update(dt)
	local gi = self.world.inputs.game
	local menu = gi.menu:pressed()

	local move_x = gi.move_x:getValue()
	local move_y = gi.move_y:getValue()

	-- Check movement early so we can cancel the menu if needed
	local move = cpml.vec3(move_x, -move_y, 0)
	local l    = move:len()

	-- menu
	if menu or (self.in_menu and l > 0) then
		-- self.in_menu = not self.in_menu
		-- toggle_mouse(self)
	end

	for _, entity in ipairs(self.entities) do
		self:process(entity, dt)
	end
end

function system:process(player, dt)
	player.timer:update(dt)

	local gi = self.world.inputs.game

	-- gather inputs
	local move     = cpml.vec3(gi.move_x:getValue(), -gi.move_y:getValue(), 0)
	local move_len = move:len()
	local turbo    = gi.turbo:pressed()
	local z_up     = gi.trigger_r:isDown()
	local z_down   = gi.trigger_l:isDown()


	-- camera
	local camera = self.world.camera_system.active_camera

	-- Each axis had a deadzone, but we also want a little more overall.
	if move_len < self.dead_zone then
		move.x = 0
		move.y = 0
	elseif move_len > 1 then
		-- normalize
		move = move / move_len
	end

	--== Orientation ==--

	local angle = cpml.vec2(move.x, move.y):angle_to() + math.pi / 2

	if self.in_menu then
		return
	end

	local action_orientation = camera.orientation:clone() * cpml.quat.rotate(math.pi, cpml.vec3.unit_z)
	action_orientation.x     = 0
	action_orientation.y     = 0

	if turbo then
		conversation:say("player turbo", player)
	end

	if z_up then
		conversation:say("player up", player, dt)
	end

	if z_down then
		conversation:say("player down", player, dt)
	end

	local current_action = player.current_action or actions.idle

	-- Change direction player is facing
	if move.x ~= 0 or move.y ~= 0 then
		local snap_to = camera.orientation:clone() * cpml.quat.rotate(player.on_ground and angle or math.pi, cpml.vec3.unit_z)

		if player.snap_to then
			-- Directions
			local current = player.snap_to * cpml.vec3.unit_y
			local next    = snap_to * cpml.vec3.unit_y
			local from    = current:dot(camera.direction)
			local to      = next:dot(camera.direction)

			-- If you move in the opposite direction, snap to end of slerp
			if from ~= to and math.abs(from) - math.abs(to) == 0 then
				player.orientation = player.snap_to:clone()
			end
		end

		player.snap_to = snap_to
		player.slerp   = 0
	end

	if player.snap_to and (not player.performing_action or current_action.align_to_movement) then
		player.orientation:slerp(player.orientation, player.snap_to, 8 * dt * 2)
		player.orientation.x = 0
		player.orientation.y = 0

		player.orientation:normalize(player.orientation)
		player.slerp = player.slerp + dt

		if player.slerp > 0.5 then
			player.snap_to = nil
			player.slerp   = 0
		end
	end

	local snap_cancel = current_action.align_to_camera

	--- cancel the orientation transition if needed
	if snap_cancel and player.snap_to then
		player.orientation   = player.snap_to:clone()
		player.orientation.x = 0
		player.orientation.y = 0

		player.orientation:normalize(player.orientation)
		player.snap_to = nil
		player.slerp   = 0
	end

	player.direction = player.orientation * -cpml.vec3.unit_y

	-- Prevent the movement animation from moving you along the wrong
	-- orientation (we want to only move how the player is trying to)
	local move_direction = camera.orientation:clone() * cpml.quat.rotate(angle, cpml.vec3.unit_z)
	if player.lock_velocity and player.snap_to then
		move_direction = player.snap_to
	end
	move_direction.x = 0
	move_direction.y = 0
	move_direction   = move_direction:normalize(move_direction) * -cpml.vec3.unit_y

	if current_action.align_to_camera then
		-- align player  to view direction
		player.orientation = action_orientation:clone()
	end

	local delta_velocity = (move_direction * math.min(move_len, 1))

	if player.on_ground then
		player.velocity = delta_velocity * player.run_speed
	else
		-- add lift based on velocity
		if player.velocity.z < 0 then
			player.force.z = player.force.z + (math.max(player.velocity:len(), 15) * player.mass) / 1.5
		end

		local new_v = player.velocity + delta_velocity * player.flight_speed
		if player.velocity:len() < player.max_speed or
			new_v:len() < player.velocity:len() then
			if not (new_v:len() > player.velocity:len() and move.y < 0) then
				player.force = player.force + delta_velocity * player.flight_speed
			end
		end
	end

	if not player.animation then
		return
	end

	if move_len == 0 then
		player.animation:play("fly")
	else
		player.animation:play("fly")
	end
end

return system
