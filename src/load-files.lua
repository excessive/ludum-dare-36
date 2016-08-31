local anim9   = require "anim9"
local cpcl    = require "cpcl"
local cpml    = require "cpml"
local geo     = require "geometry"
local iqm     = require "iqm"
local memoize = require "memoize"
local load    = {}

local _lanim = memoize(function(filename)
	return iqm.load_anims(filename)
end)

load.model = memoize(function(filename, actor, invert)
	local m = iqm.load(filename, actor, invert)
	if actor then
		for _, triangle in ipairs(m.triangles) do
			triangle[1].position = cpml.vec3(triangle[1].position)
			triangle[2].position = cpml.vec3(triangle[2].position)
			triangle[3].position = cpml.vec3(triangle[3].position)
		end
	end
	return m
end)

load.anims = function(filename)
	return anim9(_lanim(filename))
end

load.markers = memoize(function(filename)
	return love.filesystem.load(filename)()
end)

load.sound = memoize(function(filename)
	return love.audio.newSource(filename)
end)

load.font = memoize(function(filename, size)
	return love.graphics.newFont(filename, size)
end)

load.texture = memoize(function(filename, flags)
	local texture = love.graphics.newImage(filename, flags)
	texture:setFilter("linear", "linear", 16)
	return texture
end)

local octrees = {}

local ffi = require "ffi"
ffi.cdef [[
	typedef struct {
		float v1[3], v2[3], v3[3];
	} oshit_triangle;
]]
-- local EVERYTHING = ffi.new("oshit_triangle[?]", (10000*200) + 100000)
-- local gi = 0

local function add_triangles(octree, entity, mesh, oriented)
	local total_triangles = 0
	local m = cpml.mat4()
	if oriented then
		m
			:translate(m, entity.position)
			:rotate(m, entity.orientation)
			:scale(m, entity.scale)
	end

	mesh = mesh or entity.mesh

	if mesh then
		-- If we want to instance objects, only add the whole object
		if entity.instance then
			entity.aabb = geo.get_aabb(entity)
			octree:add(entity, entity.aabb)
		else
			for _, triangle in ipairs(mesh.triangles) do
				local t = {
					-- triangle = true,
					m * triangle[1].position,
					m * triangle[2].position,
					m * triangle[3].position
				}

				local aabb = geo.calculate_aabb(t)
				octree:add(t, aabb)
				total_triangles = total_triangles + 1
			end
		end
	end
	return total_triangles
end


load.map = memoize(function(filename, world, faster)
	local treec = 0
	local total_triangles = 0
	local map = love.filesystem.load(filename)()

	local trees = {
		["Tree 1"] = {
			"assets/models/tree-tall.iqm",
			"assets/models/collision-tree-tall.iqm"
		},
		["Tree 2"] = {
			"assets/models/tree-tall2.iqm",
			"assets/models/collision-tree-tall2.iqm"
		},
		["Tree 3"] = {
			"assets/models/tree-tall3.iqm",
			"assets/models/collision-tree-tall3.iqm"
		},
		["Tree 4"] = {
			"assets/models/tree-tall4.iqm",
			"assets/models/collision-tree-tall4.iqm"
		},
		["Tree 5"] = {
			"assets/models/tree-tall5.iqm",
			"assets/models/collision-tree-tall5.iqm"
		}
	}

	local base = collectgarbage "count"

	world.level_entities = {}
	for _, data in ipairs(map.objects) do
		-- this is pretty much the absolute limit of what we can get away with, AFAICT
		if collectgarbage "count" > 550000 then
			print "low on memory, bailing!"
			break
		end

		local entity = {}

		for k, v in pairs(data) do
			entity[k] = v
		end

		entity.tree        = true
		-- entity.visible     = true
		entity.position	 = cpml.vec3(entity.position)
		entity.orientation = cpml.quat(entity.orientation)
		entity.scale		 = cpml.vec3(entity.scale)
		entity.mesh        = load.model(trees[entity.model][1], false)
		entity.collision   = load.model(trees[entity.model][2], true)

		world:addEntity(entity)

		if world.octree then
			treec = treec + 1
			entity.aabb = geo.get_aabb(entity)
			if not faster then
				world.octree:add(entity, entity.aabb)
				total_triangles = total_triangles + add_triangles(world.octree, entity, entity.collision, true)
			end
		end

		love.event.pump()
		collectgarbage "step"
	end

	console.d("trees we managed to load: %d (%dMiB)", treec, (collectgarbage("count") - base)/ 1024)
	-- print(total_triangles)

	return true
end)

load.map_old = memoize(function(filename, world)
	local map = love.filesystem.load(filename)()
	local total_triangles = 0

	world.level_entities = {}
	for _, data in ipairs(map.objects) do
		local entity = {}

		for k, v in pairs(data) do
			entity[k] = v
		end

		local path = entity.path

		if entity.collision then
			path = entity.collision
		end

		if path then
			if love.filesystem.isFile(path) then
				entity.mesh = load.model(path, entity.actor, entity.invert)
			end
		end

		entity.radius      = cpml.vec3(entity.radius, entity.radius, entity.radius)
		entity.position	 = cpml.vec3(entity.position)
		entity.orientation = cpml.quat(entity.orientation)
		entity.scale		 = cpml.vec3(entity.scale)
		entity.velocity	 = cpml.vec3(0, 0, 0)
		entity.force		 = cpml.vec3(0, 0, 0)
		entity.direction   = entity.orientation * cpml.vec3.unit_y

		if entity.waypoint then
			table.insert(world.active_waypoints, {
				id   = entity.waypoint,
				time = entity.time
			})
			world.player.packages = world.player.packages + 1
			entity.position = cpml.vec3(world.waypoints[entity.waypoint])

			local camp = {
				position    = entity.position:clone(),
				orientation = entity.orientation:clone(),
				scale       = cpml.vec3(1, 1, 1),
				visible     = true,
				mesh        = load.model("assets/models/campfire.iqm")
			}
			camp.position.z = camp.position.z - world.way_offset[entity.waypoint]
			world:addEntity(camp)

			-- Smoke
			world:addEntity {
				particles  = 3000,
				spawn_rate = 1/5,
				lifetime   = { 25, 45 },
				radius     = 0.05,
				spread     = 0.075,
				size       = 1,
				color      = { 0.25, 0.25, 0.25, 0.65 },
				velocity   = cpml.vec3(0, 0, 0.5),
				offset     = cpml.vec3(0, 0, 0.1),
				position   = camp.position:clone()
			}
		end

		if entity.home then
			world.home = entity
			local temple = {
				position    = entity.position:clone(),
				orientation = entity.orientation:clone(),
				scale       = cpml.vec3(1, 1, 1),
				visible     = true,
				mesh        = load.model("assets/models/warehouse.iqm", true)
			}
			world:addEntity(temple)

			if world.octree then
				total_triangles = total_triangles + add_triangles(world.octree, temple, temple.mesh, true)
			end
		end

		world.level_entities[entity.name] = entity
		world:addEntity(entity)

		if world.octree then
			total_triangles = total_triangles + add_triangles(world.octree, entity, entity.mesh, true)
		end
	end

	return true
end)

return load
