local love = require "love"
local tiny = require "tiny"
local cpcl = require "cpcl"
local cpml = require "cpml"
local load = require "load-files"
local geo  = require "geometry"
local l3d  = love.graphics.getLove3D()
local Scene = _G.Scene

local renderer = tiny.system {
	name     = "Render",
	priority = 250,
	filter   = tiny.requireAny(
		tiny.requireAll("mesh", "position"),
		tiny.requireAll("light", "direction"),
		tiny.requireAll("particles", "position")
	),
	view_range   = false,
	view_offset  = 4,
	msaa         = 4,
	shaders      = {
		default  = love.graphics.newShader("assets/shaders/shaded.glsl"),
		post     = love.graphics.newShader("assets/shaders/post.glsl"),
		sky      = love.graphics.newShader("assets/shaders/sky.glsl"),
		particle = love.graphics.newShader("assets/shaders/particle.glsl"),
		water    = love.graphics.newShader("assets/shaders/water.glsl"),
		shadow   = l3d.new_shader_raw("2.1", "assets/shaders/shadow.glsl")
	},
	debug_cube = require "iqm".load("assets/models/debug/unit-cube.iqm"),
	shadow_maps = {
		love.system.getOS() ~= "Windows" and l3d.new_shadow_map(2048, 2048) or false
	}
}

function renderer:onAddToWorld(world)
	self.shadow_projs        = {}
	self.default_orientation = cpml.quat(0, 0, 0, 1)
	self.default_scale       = cpml.vec3(1, 1, 1)
	self.lights              = {
		ambient = { 0.04, 0.08, 0.08 },
		default = {
			direction = cpml.vec3(0.3, 0.0, 0.7),
			color     = { 1, 1, 1 },
			specular  = { 1, 1, 1 }
		}
	}

	self.sky              = false
	self.particle_systems = {}
	self.objects          = {}
	self.grass            = {}
	self.vis_octree       = cpcl.octree(2500, cpml.vec3(0, 0, 0), 25, 1)
	self.time             = 0
end

function renderer:resize(w, h)
	local limits  = love.graphics.getSystemLimits()
	local formats = love.graphics.getCanvasFormats()
	local msaa    = limits.canvasmsaa >= self.msaa and self.msaa or false
	local fmt     = "normal"
	if formats.rg11b10f then
		fmt = "rg11b10f"
		self.use_hdr = true
	end
	-- canvas support in general is guaranteed in 0.10.0+, so we just need to
	-- make sure to get the right number of msaa samples.
	self.canvases = {
		love.graphics.newCanvas(w, h, fmt, msaa, true)
		-- love.graphics.newCanvas(w, h, fmt, msaa, true)
	}

	self.use_canvas = self.canvases[1] and true or false
end

local tree = 0
local lookup = {}

function renderer:onAdd(entity)
	if lookup[entity] then
		console.d("double added %s", entity.name or entity.model)
		return
	end

	lookup[entity] = entity

	if entity.model and string.find(entity.model, "Tree") then
		tree = tree + 1
	end

	if entity.light then
		table.insert(self.lights, entity)
		return
	end

	if entity.sky then
		self.sky = entity
		return
	end

	if entity.possessed then
		self.player = entity
	end

	if entity.textures then
		for _, v in pairs(entity.textures) do
			load.texture(v) -- pre-load all the textures
		end
	end

	if entity.particles then
		table.insert(self.particle_systems, entity)
		return
	end

	if string.find(entity.name or "", "Grass") then
		table.insert(self.grass, entity)
		return
	end

	self.vis_octree:add(entity, geo.get_aabb(entity))

	table.insert(self.objects, entity)
end

function renderer:onRemove(entity)
	if entity.light then
		for i, light in ipairs(self.lights) do
			if light == entity then
				table.remove(self.lights, i)
				return
			end
		end
	end

	if entity.sky then
		self.sky = false
	end

	for i, object in ipairs(self.objects) do
		self.vis_octree:remove(object)
		if object == entity then
			table.remove(self.objects, i)
			return
		end
	end

	for i, object in ipairs(self.particle_systems) do
		if object == entity then
			table.remove(self.particle_systems, i)
			return
		end
	end
end

function renderer:send_lights(shader, caster, light_vp)
	local lights = math.min(math.max(#self.lights, 1), 4)
	shader:sendInt("u_lights", lights)

	if light_vp and self.shadow_maps[1] then
		shader:send("u_shadow_vp", light_vp:to_vec4s())
		l3d.bind_shadow_texture(self.shadow_maps[1], shader)
	end

	if #self.lights == 0 then
		if shader:getExternVariable("u_light_direction") then
			shader:send("u_light_direction", { self.lights.default.direction:unpack() })
		end
		if shader:getExternVariable("u_light_color") then
			shader:send("u_light_color", self.lights.default.color)
		end
		if shader:getExternVariable("u_light_specular") then
			shader:send("u_light_specular", self.lights.default.specular)
		end
		if shader:getExternVariable("u_shadow_index") then
			shader:sendInt("u_shadow_index", 0)
		end
		return
	end

	local light_info = {
		directions = {},
		colors     = {},
		speculars  = {}
	}

	for i = 1, math.min(#self.lights, 4) do
		local light     = self.lights[i]
		local color     = light.color     or light.color    or self.lights.default.color
		local specular  = light.specular  or light.specular or self.lights.default.specular
		local intensity = light.intensity or 1

		if light == caster then
			shader:sendInt("u_shadow_index", i-1)
		end

		table.insert(light_info.directions, {
			light.direction:unpack()
		})

		table.insert(light_info.speculars, {
			specular[1] * intensity,
			specular[2] * intensity,
			specular[3] * intensity
		})

		table.insert(light_info.colors, {
			color[1] * intensity,
			color[2] * intensity,
			color[3] * intensity
		})
	end

	if shader:getExternVariable("u_light_direction") then
		shader:send("u_light_direction", unpack(light_info.directions))
	end
	if shader:getExternVariable("u_light_specular") then
		shader:send("u_light_specular",  unpack(light_info.speculars))
	end
	if shader:getExternVariable("u_light_color") then
		shader:send("u_light_color",     unpack(light_info.colors))
	end
end

function renderer:update(dt)
	self.time = self.time + dt
end

local transparent_objects = {}
local relevant_objects = {}
setmetatable(transparent_objects, { __mode = "v" })
setmetatable(relevant_objects,    { __mode = "v" })

function renderer:draw()
	fire.print(tree, 50, 0)
	local camera = self.world.camera_system.active_camera
	if Scene.current().disable_camera or not camera then
		self:draw_overlay()
		return
	end

	-- -- Render everything
	local shader = self.shaders.shadow

	-- love.graphics.setColor(255, 255, 255, 255)
	love.graphics.setDepthTest("less")
	love.graphics.setDepthWrite(true)

	local caster = false
	local light_vp, light_view, light_proj

	for _, light in ipairs(self.lights) do
		if light.cast_shadow and light.position then
			caster = light
			break
		end
	end

	local player = false
	local t = love.timer.getTime()
	local frustum = self.world.camera_system:get_frustum()
	--[[
	relevant_objects = self.vis_octree:get_colliding(frustum, function(o)
		if o.position:dist(camera.position) > 150 then
			return false
		end

		if o.possessed then
			player = o
		end

		return true, o.always_visible
	end)
	local remove = {}
	for i, v in ipairs(relevant_objects) do
		relevant_objects[i] = v.data
		if (v.shader and v.shader ~= "default") or (v.color and v.color[4] and v.color[4] < 1) then
			table.insert(transparent_objects, v)
			table.insert(remove, i)
		end
	end
	for _, i in ipairs(remove) do
		table.remove(relevant_objects, i)
	end
	local i, j = #relevant_objects, #transparent_objects
	--]]

	---[[
	local i, j = 0, 0
	for _, object in ipairs(self.objects) do
		local vis, distance
		if object.position:dist(self.world.camera_system.active_camera.position) < 350 then
			if object.mesh and object.mesh.bounds.base then
				if not object.bounds_ws then
					object.bounds_ws = geo.get_aabb(object)
				end
				-- bug: sometimes things flicker
				vis, distance = cpml.intersect.aabb_frustum(object.bounds_ws, frustum)
			end
		end
		if object.possessed then
			player = object
		end
		if vis or object.always_visible then
			if (object.shader and object.shader ~= "default") or (object.color and object.color[4] and object.color[4] < 1) then
				j = j + 1
				transparent_objects[j] = object
				object.distance_from_camera = distance or 0
			else
				i = i + 1
				relevant_objects[i] = object
			end
		end
	end
	--]]

	if _G.FLAGS.debug_mode then
		fire.print(string.format("Culling took %0.5fms", (love.timer.getTime() - t) * 1000), 0, 2)
	end

	-- make sure transparent objects are z-sorted in camera space
	table.sort(transparent_objects, function(a, b)
		return a.distance_from_camera < b.distance_from_camera
	end)

	local fire = require "fire"
	fire.print(string.format("Objects: %d, Transparent: %d", i, j), 0, 1, "blue")

	if caster and self.shadow_maps[1] and player then
		local t = love.timer.getTime()
		if not self.shadow_projs[1] then
			self.shadow_projs[1] = cpml.mat4.from_ortho(-(caster.range or 2), (caster.range or 2), -(caster.range or 2), (caster.range or 2), -(caster.depth or 50), (caster.depth or 50))
		end
		light_proj = self.shadow_projs[1]
		light_view = cpml.mat4()
		light_view:look_at(
			light_view,
			caster.position,
			caster.position - caster.direction,
			cpml.vec3.unit_y
		)

		local bias = cpml.mat4 {
			0.5, 0.0, 0.0, 0.0,
			0.0, 0.5, 0.0, 0.0,
			0.0, 0.0, 0.5, 0.0,
			0.5, 0.5, 0.5, 1.0 + caster.bias or 0.0
		}

		light_vp = light_view * light_proj * bias
		love.graphics.setShader(shader)
		shader:send("u_projection", light_proj:to_vec4s())
		shader:send("u_view",       light_view:to_vec4s())

		-- remove this after filtering
		love.graphics.setCulling("front")
		l3d.bind_shadow_map(self.shadow_maps[1])
		l3d.clear()

		-- local frustum = cpml.mat4():to_frustum(light_proj * light_view)

		-- for _, entity in ipairs(self.objects) do
			-- local bounds
			-- if entity.mesh then
			-- 	bounds = {
			-- 		min = cpml.vec3(entity.mesh.bounds.base.min),
			-- 		max = cpml.vec3(entity.mesh.bounds.base.max)
			-- 	}
			-- end
			local entity = player
			if entity.mesh then --and cpml.intersect.aabb_frustum(bounds, frustum) then
				-- TODO: change to cast_shadow instead of a negative
				if not entity.no_shadow and (entity.visible or entity.tree) and not entity.wireframe then
					self:draw_entity(entity, shader)
				end
			end
		-- end

		if _G.FLAGS.debug_mode then
			fire.print(string.format("Light draw took %0.5fms", (love.timer.getTime() - t) * 1000), 0, 3)
		end

		l3d.bind_shadow_map()
		-- gl.GenerateMipmap(self.shadow_maps[1].buffers[1])
		if gl.GetError() ~= GL.NO_ERROR then
			print "fuck"
		end
	end

	love.graphics.setCulling("back")
	if self.use_canvas then
		love.graphics.setFrontFace("cw")
		love.graphics.setCanvas(self.canvases[1])
		love.graphics.clear(love.graphics.getBackgroundColor())
	end
	love.graphics.clearDepth()

	if self.sky then
		-- don't write depth for the skybox, it'll cause problems.
		love.graphics.setDepthWrite(false)
		shader = self.shaders.sky
		shader:send("u_light_direction", {(caster.direction or self.lights.default.direction):unpack()})
		love.graphics.setShader(shader)
		self.world.camera_system:send(shader)
		self:draw_entity(self.sky, shader)
		love.graphics.setDepthWrite(true)
	end

	shader = self.shaders.default
	love.graphics.setShader(shader)
	love.graphics.setBlendMode("alpha", "premultiplied")

	shader:send("u_ambient", self.lights.ambient)
	self:send_lights(shader, caster, light_vp)

	self.world.camera_system:send(shader)

	if caster and caster.light_debug then
		shader:send("u_projection", light_proj:to_vec4s())
		shader:send("u_view", light_view:to_vec4s())
	end

	for k, entity in ipairs(relevant_objects) do
		if k > i then
			break
		end
		if entity.visible or entity.tree then
			shader:sendInt("force_color", entity.force_color and 1 or 0)
			shader:send("u_roughness",    entity.roughness   or  0.4)

			if entity.color then
				love.graphics.setColor(
					entity.color[1]*255,
					entity.color[2]*255,
					entity.color[3]*255
				)
			else
				love.graphics.setColor(255, 255, 255)
			end

			self:draw_entity(entity, shader, entity.textures or false)
		end
	end

	love.graphics.setWireframe(false)

	love.graphics.setDepthWrite(false)
	love.graphics.setBlendMode("alpha", "alphamultiply")
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.setCulling()

	-- Draw transparent objects
	local last_shader = false
	for k, entity in ipairs(transparent_objects) do
		if k > j then
			break
		end
		local _shader = self.shaders[entity.shader or "default"]
		if _shader ~= last_shader then
			love.graphics.setShader(_shader)
			if _shader:getExternVariable("u_time") then
				_shader:send("u_time", self.time)
			end
			if _shader:getExternVariable("u_ambient") then
				_shader:send("u_ambient", self.lights.ambient)
			end
			if _shader:getExternVariable("u_lights") then
				self:send_lights(_shader, caster, light_vp)
			end
			self.world.camera_system:send(_shader)
			last_shader = _shader
		end
		if _shader:getExternVariable("force_color") then
			_shader:sendInt("force_color", entity.force_color and 1 or 0)
		end
		if _shader:getExternVariable("u_roughness") then
			_shader:send("u_roughness",    entity.roughness   or  0.4)
		end

		if entity.color then
			love.graphics.setColor(
				entity.color[1]*255,
				entity.color[2]*255,
				entity.color[3]*255,
				(entity.color[4] or 1)*255
			)
		else
			love.graphics.setColor(255, 255, 255, 255)
		end

		self:draw_entity(entity, _shader, entity.textures or false)
	end

	-- Draw Particles last
	if self.world.particles then
		shader = self.shaders.particle
		love.graphics.setShader(shader)
		self.world.camera_system:send(shader)

		for _, entity in ipairs(self.particle_systems) do
			if entity.position:dist(player.position) < 350 then
				self.world.particles:draw_particles(entity, shader)
			end
		end
	end

	-- Octree Junk
	if _G.FLAGS.show_octree then
		shader = self.shaders.default
		love.graphics.setShader(shader)
		self.world.camera_system:send(shader)

		local model = self.debug_cube
		love.graphics.setWireframe(true)
		--self.world.octree:draw_bounds(model.mesh, shader, player and player.position or false)
		love.graphics.setWireframe(false)
		self.world.octree:draw_objects(model.mesh, shader, player and player.position or false, function(o)
			return not o.triangle
		end)
	end

	-- Reset
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.setDepthWrite(true)
	love.graphics.setDepthTest()
	love.graphics.setCulling()
	love.graphics.setWireframe(false)

	love.graphics.setCanvas()

	if self.use_hdr then
		love.graphics.setShader(self.shaders.post)
		self.world.camera_system:send(self.shaders.post)
	else
		love.graphics.setShader()
	end

	if self.use_canvas then
		love.graphics.draw(self.canvases[1])
	end
	love.graphics.setShader()

	-- Draw top screen
	self:draw_overlay()
end

function renderer:draw_entity(entity, shader, textures)
	local model = assert(entity.mesh)

	local orientation = entity.orientation or self.default_orientation
	if entity.orientation_offset then
		orientation = orientation * entity.orientation_offset
	end

	local position = entity.position
	if entity.offset then
		position = position + entity.offset
	end

	local scale = entity.scale or self.default_scale
	local m     = cpml.mat4()

	shader:send("u_model",
		m
			:translate(m, position)
			:rotate(m, orientation)
			:scale(m, scale)
			:to_vec4s()
	)

	if entity.animation then
		entity.animation:send_pose(shader, "u_bone_matrices", "u_skinning")
	else
		if shader:getExternVariable("u_skinning") then
			shader:sendInt("u_skinning", 0)
		end
	end

	love.graphics.setWireframe(entity.wireframe or false)

	for _, buffer in ipairs(model) do
		if textures then
			model.mesh:setTexture(load.texture(textures[buffer.material]))
		else
			model.mesh:setTexture()
		end

		model.mesh:setDrawRange(buffer.first, buffer.last)
		love.graphics.draw(model.mesh)
	end
end

function renderer:draw_overlay()
	if Scene.current().draw then
		Scene.current():draw()
	elseif not self.world.camera_system.active_camera then
		local fire = require "fire"
		local s = "Current scene (%s) has no active camera or draw function."
		s = s:format(Scene.current().name or "<unnamed>")
		fire.print(s, 0, 0, "red")
	end
	love.graphics.setColor(255, 255, 255, 255)
end

return renderer
