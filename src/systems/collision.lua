local conversation = _G.conversation
local tiny = require "tiny"
local cpml = require "cpml"
local cpcl = require "cpcl"
local fire = require "fire"

local player_player = tiny.processingSystem {
	name     = "Player Collision",
	priority = 201,
	filter   = tiny.requireAll("capsule", "position"),
	process = function(self, entity, _)
		if not entity.possessed then
			return
		end
		for _, other in ipairs(self.entities) do
			if other ~= entity then
				local hit, p1, p2 = cpml.intersect.capsule_capsule(entity.capsule, other.capsule)
				if hit then
					local direction = p1 - p2
					direction:normalize(direction)

					local power     = entity.velocity:dot(direction)
					local reject    = direction * -power
					entity.velocity = entity.velocity + reject * entity.velocity:len()

					local offset = p1 - entity.position
					entity.position = p2 - offset + direction * (entity.capsule.radius + other.capsule.radius)
				end
			end
		end
	end
}

local player_world = tiny.processingSystem {
	name     = "World Collision",
	priority = 202,
	filter   = tiny.requireAll("possessed", "position"),
	process  = function(self, entity, dt)
		-- local offset = entity.on_ground and 0.1 or 0.001
		local offset = 0.05
		local scale  = 1.15

		local a = entity.force / entity.mass
		entity.velocity = entity.velocity + a
		entity.force:scale(entity.force, 0)

		local packet = cpcl.collision.packet_from_entity(entity, offset, dt)
		local bounds = {
			min = packet.position - packet.e_radius * cpml.vec3(scale),
			max = packet.position + packet.e_radius * cpml.vec3(scale)
		}
		local bonk = false
		local total_triangles, total_objects, checks = 0, 0, 0
		function packet.check_collision(col_packet)
			local soup = self.world.octree:get_colliding(bounds)

			checks = checks + 1
			total_objects = total_objects + #soup

			for _, object in ipairs(soup) do
				-- Is it a single triangle, or an instance?
				if type(object.data) == "table" and object.data[3] then
					local triangle = object.data

					total_triangles  = total_triangles + 1
					local radius     = col_packet.e_radius
					local e_triangle = {
						triangle[1] / radius,
						triangle[2] / radius,
						triangle[3] / radius
					}

					cpcl.collision.check_triangle(col_packet, e_triangle, true)
				else
					-- Enter a delivery waypoint
					if object.data.waypoint then
						conversation:say("enter waypoint", entity, object)
						return
					end

					-- Return to the Amazon Warehouse
					if object.data.home then
						conversation:say("enter home", entity, object)
						return
					end

					-- Collide with tree
					if packet.found_collision and object.data.tree then
						bonk = true
					end
				end
			end
		end

		local power   = 9.807
		local gravity = false
		local t = love.timer.getTime()
		local max_slope = 0.9

		cpcl.collision.collide_and_slide(packet, gravity, false, max_slope)

		fire.print(string.format(
			"%0.2fms/f (%d triangles * %d checks)",
			(love.timer.getTime() - t) * 1000,
			total_triangles / checks,
			checks
		), 0, 0)

		if bonk then
			conversation:say("player bonk", entity, object)
		end

		packet.position.z = packet.position.z - packet.e_radius.z
		if not bonk or packet.on_ground then
			entity.position.x = packet.position.x
			entity.position.y = packet.position.y
			entity.position.z = packet.position.z - offset
		end
		if packet.found_collision and packet.on_ground then
			entity.position.z = entity.position.z + math.abs(packet.nearest_distance)
			entity.force.z = math.max(entity.force.z, 0)
			entity.velocity.z = math.max(entity.velocity.z, 0)
		end
		entity.force.z    = entity.force.z - power * entity.mass
		entity.on_ground  = packet.on_ground
		entity.on_wall    = packet.on_wall

		-- Invisible wall
		do
			local pos1 = entity.position:clone()
			local pos2 = self.world.home.position:clone()
			pos1.z = 0
			pos2.z = 0
			local dist = pos1:dist(pos2)
			local radius = 1000

			if dist > radius then
				local dir = pos1 - pos2
				dir:normalize(dir)

				local pos    = cpml.vec3():scale(dir, radius)
				local power  = entity.velocity:dot(dir)
				local reject = dir * -power

				entity.velocity   = entity.velocity + reject
				entity.position.x = pos.x - dir.x * entity.capsule.radius
				entity.position.y = pos.y - dir.y * entity.capsule.radius
			end
		end

		-- Invisible ceiling & floor
		do
			local ray = {
				position  = entity.position + cpml.vec3(0, 0, 10),
				direction = -cpml.vec3.unit_z
			}
			local func = function(ray, objects, out)
				for _, object in ipairs(objects) do
					if type(object.data) == "table" and object.data[3] then
						local point = cpml.intersect.ray_triangle(ray, object.data)

						if point then
							local dist  = point:dist(entity.position)

							entity.height = dist

							-- Only select largest distance (probably terrain)
							if out.dist < dist then
								out.dist  = dist
								out.point = point
							end
							if out.min > dist then
								out.min = dist
								out.point2 = point
							end
						end
					end
				end
			end

			local out = { dist=0, min=0 }
			self.world.octree:cast_ray(ray, func, out)
			if out.point then
				-- (Soft) Ceiling
				if out.dist > entity.height_limit then
					entity.velocity.z = math.min(entity.velocity.z, 0)
					entity.force.z    = math.min(entity.force.z, 0)
					entity.position.z = out.point.z + entity.height_limit
				-- Floor
				elseif out.dist < 1 then
					entity.position.z = (out.point or out.point).z + 1
					entity.velocity.z = math.max(entity.velocity.z, 0)
				end
			end
		end
	end
}

local player_accel = tiny.processingSystem {
	name     = "Player Acceleration",
	priority = 203,
	filter   = tiny.requireAll("possessed", "position", "velocity"),
	friction = 10,
	process  = function(self, entity, dt)
		-- We don't use physics-based movement on the ground.'
		if entity.on_ground then
			return
		end

		-- Velocity falloff
		-- entity.velocity:scale(entity.velocity, 0.975)
		local ev = cpml.vec3():normalize(entity.velocity)
		entity.velocity = ev * math.max(entity.velocity:len() - self.friction * dt, 0)
	end
}

return tiny.system {
	name     = "Collision",
	priority = 200,
	onAddToWorld = function(_, world)
		world:addSystem(player_player)
		world:addSystem(player_world)
		world:addSystem(player_accel)
	end,
	onRemoveFromWorld = function(_, world)
		world:removeSystem(player_player)
		world:removeSystem(player_world)
		world:removeSystem(player_accel)
	end
}
