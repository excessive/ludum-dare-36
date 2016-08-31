local conversation = _G.conversation

local anchor = require "anchor"
local cpcl   = require "cpcl"
local cpml   = require "cpml"
local load   = require "load-files"
local timer  = require "timer"
local tiny   = require "tiny"

local gs    = {}
local gs_mt = { __index = gs }

local colors = {
	black   = {   0,   0,   0, 255 },
	red     = { 255,   0,   0, 255 },
	green   = {   0, 255,   0, 255 },
	blue    = {   0,   0, 255, 255 },
	yellow  = { 255, 255,   0, 255 },
	cyan    = {   0, 255, 255, 255 },
	magenta = { 255,   0, 255, 255 },
	white   = { 255, 255, 255, 255 },

	comp_red     = { 100,   0,  50, 220 },
	comp_red_l   = { 150,   0,  50, 220 },
	comp_green   = {  50, 100,   0, 220 },
	comp_green_l = {  50, 150,   0, 220 },
	comp_blue    = {   0,  50, 100, 220 },
	comp_blue_l  = {   0,  50, 150, 220 },
}

function gs:load()
	love.graphics.clear { 0, 0, 0, 255 }
	love.graphics.print("Loading...", 10, 10)
end

function gs:enter(from, data)
	data  = data or {}
	data.level = data.level or 1

	self.paused = false

	self.font = love.graphics.newFont("assets/fonts/NotoSans-Regular.ttf", 13)

	-- Create world
	local world         = tiny.world()
	world.language      = require("languages").load(_G.PREFERENCES.language)
	world.inputs        = require "inputs"
	world.octree        = data.octree or cpcl.octree(2500, cpml.vec3(0, 0, 0), 25.0, 1.0)
	world.particles     = world:addSystem(require "systems.particle")
	world.camera_system = world:addSystem(require "systems.camera")
	world.renderer      = world:addSystem(require "systems.render")
	self.world          = world

	love.graphics.setBackgroundColor(220, 245, 220, 255)

	self.level_strikes = 0

	self.timer    = timer.new()
	self.time     = 0
	self.subtitle = {
		text    = "",
		opacity = 0,
		font    = load.font("assets/fonts/NotoSans-Regular.ttf", 18)
	}

	-- Speed limits
	self.normal_max = 25
	self.turbo_max  = 100

	-- New Game+
	if _G.NGP then
		self.max_speed = self.turbo_max
	else
		self.max_speed = self.normal_max
	end

	-- Speed run data
	self.world.start_timer  = false
	self.time_elapsed       = 0
	self.total_elapsed      = data.total_elapsed or 0
	self.level_bonks        = 0
	self.total_bonks        = data.total_bonks or 0

	-- Waypoint data
	self.world.waypoints = {
		{ -699.2458496,  417.9103699,  46.3143616 },
		{ -650.5330811, -193.5679169,  66.0930977 },
		{ -463.3736267, -670.4398193,  85.9476013 },
		{ -385.1450500,  288.9722290,  59.1892242 },
		{   18.6259995, -388.4188232,  30.5132751 },
		{   96.8281250, -826.8332520,  65.0544968 },
		{  182.7109222,  861.4525757, 156.1229553 },
		{  494.2215271,  547.3783569, 178.8545074 },
		{  540.0032959, -670.3044434, 110.1263351 },
		{  781.3701172,   49.9957123, 160.3677673 }
	}

	-- Campfire offset
	self.world.way_offset = { 5, 5, 3, 4, 6, 4, 3, 2.5, 3, 4 }

	 -- which waypoint, time left in seconds
	self.world.active_waypoints = {}

	-- Load player
	self.player = self.world:addEntity(require("assets.entities.player")({
		wireframe = false,
		possessed = true,
		max_speed = self.max_speed,
		position  = cpml.vec3(0, 0, 100),
		strikes   = data.strikes or 0
	}))
	self.world.player = self.player
	self.player.animation:play("fly")

	--[[ COLLISION SPHERE
	self.world:addEntity {
		name        = "BONK!",
		visible     = true,
		always_visible = true,
		wireframe   = true,
		orientation = self.player.orientation,
		scale       = self.player.radius / 2,
		position    = self.player.position,
		offset      = cpml.vec3(0, 0, 0.25),
		color       = { 0, 1, 1 },
		mesh        = load.model("assets/models/debug/unit-sphere.iqm", false)
	}
	--]]

	-- Load map
	load.map("assets/levels/forest.lua", self.world, data.octree)
	load.map_old(string.format("assets/levels/level%d.lua", data.level), self.world)

	self.camera = self.world:addEntity {
		name             = "Camera",
		camera           = true,
		fov              = 60,
		near             = 0.1,
		far              = 300,
		exposure         = 1.15,
		pitch_limit_down = 0.85,
		pitch_limit_up   = 0.35,
		position         = cpml.vec3(0, 0, 0),
		orientation      = cpml.quat(0, 0, 0, 1) * cpml.quat.from_angle_axis(math.pi, cpml.vec3.unit_z),
		orbit_offset     = cpml.vec3(0, 0, -2.25),
		offset           = cpml.vec3(0, 0, -0.95),
	}
	self.camera.direction = self.camera.orientation * -cpml.vec3.unit_y

	-- NB: This needs to go BEFORE the camera system. Failing that, you'll
	-- find yourself losing sleep and ripping your hair out over the
	-- mysterious frame of latency which causes the player to go out of
	-- alignment with their position on the screen.
	--
	-- KEEP THIS. BEFORE. THE CAMERA. ALSO FUCK YOU. -Landon
	self.world:addSystem(tiny.processingSystem {
		name     = "Camera tracking",
		priority = 224,
		filter   = tiny.requireAll("possessed"),
		process  = function(_, entity, dt)
			if self.player_controller and not self.player_controller.in_menu then
				self.world.camera_system:rotate_xy(-self.world.inputs.mouse.delta)
			end
			self.camera.position = entity.position:clone()
			local velocity = self.player.velocity:clone()
			velocity.z = 0

			if _G.NGP then
				self.camera.fov            = cpml.utils.map(velocity:len(), 0, self.max_speed, 60, 120)
				self.camera.orbit_offset.z = cpml.utils.map(velocity:len(), 0, self.max_speed, -2.25, -0.75)
			elseif self.player.turbo then
				self.camera.fov            = cpml.utils.clamp(cpml.utils.map(velocity:len(), self.normal_max, self.turbo_max, 60, 120), 60, 120)
				self.camera.orbit_offset.z = cpml.utils.clamp(cpml.utils.map(velocity:len(), self.normal_max, self.turbo_max, -2.25, -0.75), -2.25, -0.75)

				-- Camera goes back to normal and then disables turbo view
				if velocity:len() < self.normal_max and self.player.turbo_speed == 0 then
					self.player.turbo = false
				end
			end
		end
	})

	local light = self.world:addEntity {
		name        = "Sol",
		light       = true,
		direction   = cpml.vec3(0.2, 0.1, 0.7),
		position    = cpml.vec3(3, -2.1, 0),
		color       = { 1.6, 1.1, 1.1 },
		intensity   = 2.0,
		range       = 5,
		fov         = 25,
		near        = 1.0,
		far         = 100.0,
		bias        = 1.0e-4,
		depth       = 80,
		cast_shadow = true,
		tracking    = true
	}
	light.direction:normalize(light.direction)

	local sky = self.world:addEntity {
		name        = "Sol 2",
		light       = true,
		direction   = cpml.vec3(0.0, 0.0, 1.0),
		color       = { 0.1, 0.2, 1.0 },
		intensity   = 0.9,
		cast_shadow = false
	}
	sky.direction:normalize(sky.direction)

	-- Make the light follow the player
	self.world:addSystem(tiny.system {
		name   = "Light tracking",
		update = function()
			if light.tracking then
				light.position = self.player.position:clone()
			end
		end
	})

	-- START LEVEL
	self.timer:script(function(wait)
		local text, duration, audio
		local chief

		if data.level == 1 then
			-- Synopsis
			text, duration, audio = self.world.language:get("chief-intro-1")
			self:draw_text(text, duration)
			if audio then
				chief = load.sound(audio)
				chief:setVolume(_G.PREFERENCES.volume)
				chief:play()
			end
			wait(duration + 1)

			-- Threat
			text, duration, audio = self.world.language:get("chief-intro-2")
			self:draw_text(text, duration)
			if audio then
				if chief then
					chief:stop()
				end
				chief = load.sound(audio)
				chief:setVolume(_G.PREFERENCES.volume)
				chief:play()
			end
			wait(duration + 2)
		end

		-- Start the game already!
		text, duration, audio = self.world.language:get("chief-intro-3")
		self:draw_text(text, duration)
		if audio then
			if chief then
				chief:stop()
			end
			chief = load.sound(audio)
			chief:setVolume(_G.PREFERENCES.volume)
			chief:play()
		end
		wait(duration)

		-- Start BGM!
		self.bgm = load.sound("assets/audio/pool-noodles.ogg")
		self.bgm:setVolume(0.4)
		self.bgm:setLooping(true)
		self.bgm:play()

		-- GO!
		self.world.start_timer = true
		self.collision         = self.world:addSystem(require "systems.collision")
		self.player_controller = self.world:addSystem(require "systems.player-controller")
		wait(0.5)

		-- Bwak!
		local r = love.math.random(1, 4)
		text, duration, audio = self.world.language:get("random-"..r)
		self:draw_text(text, duration)
		if audio then
			self.player.voice = load.sound(audio)
			self.player.voice:setVolume(_G.PREFERENCES.volume)
			self.player.voice:play()
		end
	end)

	--== CONVERSATIONS ==--

	conversation:listen("anim flap", function()
		local audio = load.sound("assets/audio/sfx/flap.wav")
		audio:setVolume(_G.PREFERENCES.volume)
		audio:play()
	end)

	conversation:listen("player turbo", function(player)
		-- Turbo is always on in NG+!
		if _G.NGP then return end

		if player.turbo_time == 10 then
			player.turbo     = true
			player.max_speed = self.turbo_max
			self.max_speed   = self.turbo_max
			return
		end

		if player.turbo_time == 0 then
			player.max_speed = self.normal_max
			self.max_speed   = self.normal_max
		end
	end)

	self.bonk_timer = 0
	-- Bonk!
	conversation:listen("player bonk", function(player)
		local velocity = player.velocity:clone()
		velocity.z = 0

		if self.bonk_timer > 5 and velocity:len() > 10 then
			self.bonk_timer = 0
			player.velocity = player.velocity * -1
			player.bonks = math.min(player.bonks + 1, 3)
			self.level_bonks = self.level_bonks + 1
			self.total_bonks = self.total_bonks + 1

			-- BONK!
			local r = love.math.random(1, 4)
			local text, duration, audio = self.world.language:get("bonk-"..r)

			-- Display subtitle
			self:draw_text(text, duration)

			-- Stop whatever current audio is playing
			if audio then
				self.player.voice:stop()
				self.player.voice = load.sound(audio)
				self.player.voice:setVolume(_G.PREFERENCES.volume)
				self.player.voice:play()
			end

			-- Bonk!
			audio = load.sound("assets/audio/sfx/bonk.wav")
			audio:setVolume(_G.PREFERENCES.volume)
			audio:play()
		end
	end)

	-- Strike against player
	conversation:listen("player strike", function(player, cause)
		player.strikes = math.min(player.strikes + 1, 3)
		self.level_strikes = math.min(self.level_strikes + 1, 3)

		-- maybe some animation shit or text tweening or whatever
		-- Update strike UI

		-- Oh noes!
		local r, text, duration, audio
		if cause == "time" then
			self.timer:script(function(wait)
				-- Civilian
				local civ
				r = love.math.random(1, 3)
				text, duration, audio = self.world.language:get("civ-late-"..r)
				self:draw_text(text, duration)
				if audio then
					civ = load.sound(audio)
					civ:setVolume(_G.PREFERENCES.volume)
					civ:play()
				end
				wait(duration + 1)

				-- Papi
				r = love.math.random(1, 1)
				text, duration, audio = self.world.language:get("late-"..r)

				self:draw_text(text, duration)

				if audio then
					self.player.voice:stop()
					self.player.voice = load.sound(audio)
					self.player.voice:setVolume(_G.PREFERENCES.volume)
					self.player.voice:play()
				end
			end)
		else
			self.timer:script(function(wait)
				-- Civilian
				local civ
				r = love.math.random(1, 2)
				text, duration, audio = self.world.language:get("civ-broke-"..r)
				self:draw_text(text, duration)
				if audio then
					civ = load.sound(audio)
					civ:setVolume(_G.PREFERENCES.volume)
					civ:play()
				end
				wait(duration + 1)

				-- Papi
				r = love.math.random(1, 1)
				text, duration, audio = self.world.language:get("broke-"..r)

				self:draw_text(text, duration)

				if audio then
					self.player.voice:stop()
					self.player.voice = load.sound(audio)
					self.player.voice:setVolume(_G.PREFERENCES.volume)
					self.player.voice:play()
				end
			end)
		end

		-- Display subtitle
		self:draw_text(text, duration)

		-- Stop whatever current audio is playing
		if audio then
			self.player.voice:stop()
			self.player.voice = load.sound(audio)
			self.player.voice:setVolume(_G.PREFERENCES.volume)
			self.player.voice:play()
		end
	end)

	conversation:listen("player delivered", function(player, object, waypoint)
		player.packages = math.max(player.packages - 1, 0)

		for i, w in ipairs(self.world.active_waypoints) do
			-- Remove waypoint from map
			if w == waypoint then
				table.remove(self.world.active_waypoints, i)
			end
		end

		if #self.world.active_waypoints == 0 then
			player.height_limit = player.height_return
		else
			player.height_limit = player.height_normal
		end

		-- Remove waypoint from world
		object.data.visible = false
		self.world.octree:remove(object)
	end)

	-- Waypoint Junk
	conversation:listen("enter waypoint", function(player, object)
		for _, way in ipairs(self.world.active_waypoints) do
			-- deliver package
			if way.id == object.data.waypoint then
				conversation:say("player delivered", player, object, way)

				-- if delivery is late , add strike
				if way.time == 0 then
					conversation:say("player strike", player, "time")
					return
				end

				-- if item is broken, add strike
				if player.bonks == 3 then
					conversation:say("player strike", player, "bonk")
					return
				end

				self.timer:script(function(wait)
					local r, text, duration, audio

					-- Civilian
					local civ
					r = love.math.random(1, 6)
					text, duration, audio = self.world.language:get("civ-happy-"..r)
					self:draw_text(text, duration)
					if audio then
						civ = load.sound(audio)
						civ:setVolume(_G.PREFERENCES.volume)
						civ:play()
					end
					wait(duration + 1)

					-- Papi
					r = love.math.random(1, 1)
					text, duration, audio = self.world.language:get("delivered-"..r)

					self:draw_text(text, duration)

					if audio then
						self.player.voice:stop()
						self.player.voice = load.sound(audio)
						self.player.voice:setVolume(_G.PREFERENCES.volume)
						self.player.voice:play()
					end
				end)
			end
		end
	end)

	-- TODO: Flesh this out!
	conversation:listen("bad end", function(player)
		self.world.start_timer = false
		self.total_elapsed = self.total_elapsed + self.time_elapsed

		self.timer:script(function(wait)
			local r, text, duration, audio

			local z = "strike"
			if player.strikes == 3 then
				z = "fail"
			end

			-- Chief
			local chief
			r = love.math.random(1, 2)
			text, duration, audio = self.world.language:get("chief-complete-"..z.."-"..r)
			self:draw_text(text, duration)
			if audio then
				chief = load.sound(audio)
				chief:setVolume(_G.PREFERENCES.volume)
				chief:play()
			end
			wait(duration + 1)

			-- Papi
			r = love.math.random(1, 1)
			text, duration, audio = self.world.language:get("bad-end-"..r)

			self:draw_text(text, duration)

			if audio then
				self.player.voice:stop()
				self.player.voice = load.sound(audio)
				self.player.voice:setVolume(_G.PREFERENCES.volume)
				self.player.voice:play()
			end
			wait(duration + 1)

			-- Switch to results
			_G.Scene.switch(require("scenes.results")(), {
				time        = self.time_elapsed,
				total_time  = self.total_elapsed,
				strikes     = self.player.strikes,
				bonks       = self.level_bonks,
				total_bonks = self.total_bonks,
				level       = data.level,
				octree      = self.world.octree
			})
		end)
	end)

	-- TODO: Put this at the end of a results scene!
	-- TODO: Flesh this out!
	conversation:listen("good end", function(player)
		self.world.start_timer = false
		self.total_elapsed = self.total_elapsed + self.time_elapsed

		self.timer:script(function(wait)
			local r, text, duration, audio

			-- Chief
			local chief
			r = love.math.random(1, 2)
			text, duration, audio = self.world.language:get("chief-complete-"..r)
			self:draw_text(text, duration)
			if audio then
				chief = load.sound(audio)
				chief:setVolume(_G.PREFERENCES.volume)
				chief:play()
			end
			wait(duration + 1)

			-- Papi
			r = love.math.random(1, 2)
			text, duration, audio = self.world.language:get("complete-"..r)

			self:draw_text(text, duration)

			if audio then
				self.player.voice:stop()
				self.player.voice = load.sound(audio)
				self.player.voice:setVolume(_G.PREFERENCES.volume)
				self.player.voice:play()
			end
			wait(duration + 1)

			-- Switch to results
			_G.Scene.switch(require("scenes.results")(), {
				time        = self.time_elapsed,
				total_time  = self.total_elapsed,
				strikes     = self.player.strikes,
				bonks       = self.level_bonks,
				total_bonks = self.total_bonks,
				level       = data.level,
				octree      = self.world.octree
			})
		end)
	end)

	-- TODO: Flesh this out!
	conversation:listen("level complete", function(player)
		if not self.world.start_timer then return end

		if self.level_strikes > 0 then
			conversation:say("bad end", player)
			return
		end

		conversation:say("good end", player)
	end)

	-- Home Junk
	conversation:listen("enter home", function(player, object)
		-- if all packages delivered (even the late or damaged ones!)
		if player.packages == 0 then
			conversation:say("level complete", player)
			return
		end

		-- sfx
	end)

	self.world:addSystem(require "systems.animation")
end

function gs:update(dt)
	if self.paused then
		dt = 0
	end

	if self.world.inputs.game.menu:pressed() then
		self.paused = not self.paused
	end

	if _G.FLAGS.debug_mode then
		fire.bind("2", function()
			self.player.packages = math.max(self.player.packages - 1, 0)
			if #self.world.active_waypoints > 0 then
				table.remove(self.world.active_waypoints, 1)
			end
		end)
	end

	self.timer:update(dt)

	if self.world.start_timer then
		self.time_elapsed = self.time_elapsed + dt
	end

	for _, waypoint in ipairs(self.world.active_waypoints) do
		waypoint.time = math.max(waypoint.time - dt, 0)
	end

	if self.player.turbo then
		self.player.turbo_time = math.max(self.player.turbo_time - dt, 0)

		if self.player.turbo_time == 0 then
			conversation:say("player turbo", self.player)
		end
	end

	self.bonk_timer = self.bonk_timer + dt

	-- Toggle octree debug view
	fire.bind("1", function()
		_G.FLAGS.show_octree = not _G.FLAGS.show_octree
	end)

	-- Print player stats
	local velocity = self.player.velocity:clone()
	velocity.z = 0
	fire.print(string.format("LEVEL TIME: %2.3f", self.time_elapsed),      70, 0)
	fire.print(string.format("Position:   %s",    self.player.position),   0,  4)
	-- fire.print(string.format("Velocity:   %s",    self.player.velocity),   0,  5)
	fire.print(string.format("Speed:      %2.2f", velocity:len()),         0,  6)
	fire.print(string.format("Packages:   %d",    self.player.packages),   0,  7)
	fire.print(string.format("Strikes:    %d",    self.player.strikes),    0,  8)
	fire.print(string.format("Bonks:      %d",    self.player.bonks),      0,  9)
	-- fire.print(string.format("Ground:     %s",    self.player.on_ground),  0, 10)
	-- fire.print(string.format("Wall:       %s",    self.player.on_wall),    0, 11)
	fire.print(string.format("Turbo:      %s",    self.player.turbo),      0, 12)
	fire.print(string.format("Turbo Time: %2.2f", self.player.turbo_time), 0, 13)
end

function gs:draw()
	local w, h = love.graphics.getDimensions()
	local camera = self.world.camera_system:get_data()

	local function draw_frame(wpos, c1, c2, time)
		local spos = cpml.mat4.project(wpos, camera.view, camera.projection, { 0, 0, w, h })
		spos.y = h-spos.y -- flip y, because opengl
		spos.x = math.floor(spos.x)
		spos.y = math.floor(spos.y)

		local distance = self.player.position:dist(wpos)
		wpos:normalize(wpos - self.player.position)
		local d = cpml.vec3.dot(wpos, self.camera.direction)
		if d > 0 then
			-- Time Plate
			love.graphics.setColor(c1)
			love.graphics.rectangle("fill", spos.x - 10, spos.y - 10, 150, 20, 5)
			love.graphics.setColor(c2)
			love.graphics.circle("fill", spos.x, spos.y, 5, 32)

			local offset = 8

			-- Text shadow
			love.graphics.setColor(colors.black)
			love.graphics.setFont(self.font)
			if time then
				love.graphics.print(string.format("%0.2fs", time), spos.x + 15, spos.y - offset)
			end
			if distance > 1000 then
				love.graphics.print(string.format("%0.2fkm", distance/1000), spos.x + 80, spos.y - offset)
			else
				love.graphics.print(string.format("%0.2fm", distance), spos.x + 80, spos.y - offset)
			end

			-- Text
			love.graphics.setColor(colors.white)
			if time then
				love.graphics.print(string.format("%0.2fs", time), spos.x + 15, spos.y - offset - 2)
			end
			if distance > 1000 then
				love.graphics.print(string.format("%0.2fkm", distance/1000), spos.x + 80, spos.y - offset - 2)
			else
				love.graphics.print(string.format("%0.2fm", distance), spos.x + 80, spos.y - offset - 2)
			end
		end
	end

	for _, point in ipairs(self.world.active_waypoints) do
		local c1 = colors.comp_blue
		local c2 = colors.comp_blue_l

		if point.time == 0 then
			c1 = colors.comp_red
			c2 = colors.comp_red_l
		end

		draw_frame(cpml.vec3(self.world.waypoints[point.id]), c1, c2, point.time)
	end

	if self.player.packages == 0 and self.world.start_timer then
		draw_frame(self.world.home.position:clone(), colors.comp_green, colors.comp_green_l)
	end

	local velocity = self.player.velocity

	local function box(x, y, w, h)
		love.graphics.setColor(0, 0, 0, 200)
		love.graphics.rectangle("fill", x, y, w, h, 2)
		love.graphics.setColor(255, 255, 255, 255)
	end

	love.graphics.setFont(load.font("assets/fonts/NotoSans-Bold.ttf", 18))
	box(anchor:left(), anchor:bottom() - 30, 300, 30)
	love.graphics.print(string.format("Packages:   %d",    self.player.packages),   anchor:left() + 10, anchor:bottom() - 29)

	box(anchor:right() - 150, anchor:bottom() - 30, 150, 30, 2)
	love.graphics.print(string.format("Speed:      %2.2f", velocity:len()),         anchor:right() - 138, anchor:bottom() - 29)

	local str = string.format("LEVEL TIME: %2.3f", self.time_elapsed)
	local width = love.graphics.getFont():getWidth(str)
	box(anchor:center_x() - width/2 - 20, anchor:top(), width + 40, 30)
	love.graphics.print(str, anchor:center_x() - width/2, anchor:top() + 2)

	-- love.graphics.print(string.format("Strikes:    %d",    self.player.strikes),    anchor:left(), anchor:top() + 30)

	-- love.graphics.print(string.format("Bonks:      %d",    self.player.bonks),      anchor:left(), anchor:top() + 50)

	-- love.graphics.print(string.format("Turbo:      %s",    self.player.turbo),      anchor:left(), anchor:top() + 70)

	-- love.graphics.print(string.format("Turbo Time: %2.2f", self.player.turbo_time), anchor:left(), anchor:top() + 90)

	if self.paused then
		love.graphics.push()
		love.graphics.translate(w/2 - 50, h/2 - 15)
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.rectangle("fill", 0, 0, 100, 30, 5)
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.print("Paused", 25, 5)
		love.graphics.pop()
	end

	-- Draw subtitles
	local o = love.graphics.getFont()
	local f = self.subtitle.font
	local w = f:getWidth(self.subtitle.text)
	local c = anchor:center_x()
	local b = anchor:bottom() - 50

	love.graphics.setFont(f)
	love.graphics.setColor(0, 0, 0, self.subtitle.opacity)
	love.graphics.print(self.subtitle.text, c - w / 2 + 2, b - 48)
	love.graphics.setColor(255, 255, 255, self.subtitle.opacity)
	love.graphics.print(self.subtitle.text, c - w / 2, b - 50)
	love.graphics.setFont(o)
	love.graphics.setColor(255, 255, 255, 255)
end

function gs:draw_text(text, len)
	-- Set text
	self.subtitle.text    = text
	self.subtitle.opacity = 255

	self.timer:script(function(wait)
		self.timer:tween(0.25, self.subtitle, { opacity=255 }, 'in-cubic')
		wait(len)
		self.timer:tween(0.25, self.subtitle, { opacity=0 }, 'out-cubic', function()
			self.subtitle.text = ""
		end)
	end)
end

function gs:resize(w, h)
	self.world.renderer:resize(w, h)
end

return function()
	local t = tiny.system {
		name = "Test Scene",
		priority = 0
	}
	return setmetatable(t, gs_mt)
end
