local anchor  = require "anchor"
local timer   = require "timer"
local tiny    = require "tiny"

local gs    = {}
local gs_mt = { __index = gs }

function gs:enter()
	love.graphics.setBackgroundColor(30, 30, 44)
	self.bgm.music:play()
	love.mouse.setVisible(false)

	self.world = tiny.world()
	self.world.language = require("languages").load(_G.PREFERENCES.language)
	self.world.inputs   = require "inputs"

	-- BGM
	self.timer:script(function(wait)
		self.bgm.music:setVolume(self.bgm.volume)
		self.bgm.music:play()
		wait(self.delay)
		self.timer:tween(1.5, self.bgm, {volume = 0}, 'in-quad')
		wait(1.5)
		self.bgm.music:stop()
	end)

	-- Overlay fade
	self.timer:script(function(wait)
		-- Fade in
		self.timer:tween(1.5, self.overlay, {opacity=0}, 'cubic')
		-- Wait a little bit
		wait(self.delay)
		-- Fade out
		self.timer:tween(1.25, self.overlay, {opacity=255}, 'out-cubic')
		-- Wait briefly
		wait(1.5)
		-- Switch
		Scene.switch(require(self.next_scene)())
	end)
end

function gs:leave(self)
	love.mouse.setVisible(true)
end

function gs:update(dt)
	self.timer:update(dt)
	self.bgm.music:setVolume(self.bgm.volume)

	-- Skip if user wants to get the hell out of here.
	if self.world.inputs.game.menu_action:pressed() then
		self.bgm.music:stop()
		Scene.switch(require(self.next_scene)())
	end
end

function gs:draw()
	local cx, cy = anchor:center()

	local lw, lh = self.logos.exmoe:getDimensions()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(self.logos.exmoe, cx-lw/2, cy-lh/2 - 84)

	local lw, lh = self.logos.l3d:getDimensions()
	love.graphics.draw(self.logos.l3d, cx-lw/2, cy-lh/2 + 64)

	-- Full screen fade, we don't care about logical positioning for this.
	local w, h = love.graphics.getDimensions()
	love.graphics.setColor(0, 0, 0, self.overlay.opacity)
	love.graphics.rectangle("fill", 0, 0, w, h)
end

return function()
	local t = tiny.system {
		name     = "Splash",
		priority = 0,
		logos = {
			l3d   = love.graphics.newImage("assets/ui/logo-love3d.png"),
			exmoe = love.graphics.newImage("assets/ui/logo-exmoe.png")
		},
		timer   = timer.new(),
		delay   = 5.5, -- seconds before fade out
		overlay = {
			opacity = 255
		},
		bgm = {
			volume = 0.5,
			music  = love.audio.newSource("assets/bgm/love.ogg")
		},
		next_scene = "scenes.play"
	}
	return setmetatable(t, gs_mt)
end
