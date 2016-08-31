local anchor = require "anchor"
local convoke = require "convoke"
local cpml  = require "cpml"
local lume  = require "lume"
local timer = require "timer"
local tiny = require "tiny"

local gs    = {}
local gs_mt = { __index = gs }

function gs:enter(from)
	self.timer = timer.new()
	self.bgm   = love.audio.newSource("assets/bgm/credits.ogg")
	self.bgm:setLooping(true)
	self.bgm:play()
	self.bgm:setVolume(0.25)

	self.time = 0

	self.crash = love.filesystem.read("assets/credits-crashlog.txt")

	self.lines = love.filesystem.read("assets/credits.txt")

	self.state = { opacity = 1, thanks_opacity = 0, volume = 0 }
	self.input_locked = true

	convoke(function(continue, wait)
		-- prevent accidental instant skipping
		self.timer.add(0.5, function()
			self.input_locked = false
		end)
		self.timer.tween(2.0, self.state, { opacity = 0 }, 'out-quad')
		self.timer.tween(5.0, self.state, { volume = 0.25 }, 'out-quad')
		self.timer.add(60, continue())
		wait()
		self:transition_out()
	end)()

	self.text = ""
	self.scroll_speed = 500

	self.font = love.graphics.newFont("assets/fonts/NotoSans-Regular.ttf", 12)
	self.font2 = love.graphics.newFont("assets/fonts/NotoSans-Bold.ttf", 24)
	self.font3 = love.graphics.newFont("assets/fonts/NotoSans-Regular.ttf", 14)

	local width, height = self.font3:getWrap(self.lines, anchor:width())
	self.text_width  = width
	self.text_height = #height * self.font3:getHeight()

	local sound = select(2, self.world.language("credits/thank-you"))
	self.thanks = sound and love.audio.newSource(sound) or false

	love.graphics.setBackgroundColor(0, 0, 0)
end

function gs:leave()
	self.world:clearEntities()
end

function gs:transition_out()
	convoke(function(continue, wait)
		self.timer.tween(1.0, self.state, { opacity = 1, volume = 0 }, 'in-out-quad', continue())
		wait()
		self.bgm:stop()
		self.timer.tween(1.0, self.state, { thanks_opacity = 1 }, 'in-out-quad')
		self.timer.add(2, continue())
		wait()
		if self.thanks then
			self.thanks:play()
		end
		self.timer.tween(3, self.state, { thanks_opacity = 0 }, 'in-out-quad')
		self.timer.add(4, continue())
		wait()
		love.event.quit()
		-- Scene.switch(require("scenes.main-menu")(self.world))
	end)()
end

function gs:mousepressed(x, y, button)
	if self.input_locked then
		return
	end
	if button == 1 then
		self:transition_out()
	end
end

function gs:update(dt)
	self.time = self.time + dt

	self.timer.update(dt)
	self.bgm:setVolume(self.state.volume)

	self.text = self.crash:sub(self.time*self.scroll_speed,self.time*self.scroll_speed+1200)
end

function gs:draw()
	love.graphics.setColor(255, 255, 255, 255 * (1-self.state.opacity))
	love.graphics.setFont(self.font)
	love.graphics.printf(
		self.text,
		anchor:center_x(),
		anchor:top(),
		anchor:width() / 2,
		"left"
	)
	love.graphics.setFont(self.font3)
	love.graphics.printf(
		self.lines,
		anchor:left(),
		anchor:center_y() - self.text_height / 2,
		anchor:width() / 2,
		"center"
	)
	love.graphics.setColor(0, 0, 0, 255 * self.state.opacity)
	love.graphics.rectangle(
		"fill", 0, 0,
		love.graphics.getWidth(),
		love.graphics.getHeight()
	)

	love.graphics.setFont(self.font2)
	love.graphics.setColor(255, 255, 255, 255 * self.state.thanks_opacity)
	love.graphics.printf(
		(self.world.language("credits/thank-you")),
		anchor:left(),
		anchor:center_y() - 12,
		anchor:width(),
		"center"
	)

	if self.input_locked then
		return
	end

	if self.world.inputs.game.menu_back:pressed() then
		self:transition_out()
	end
end

return function()
	local t = tiny.system {
		name     = "Credits",
		priority = 0
	}
	return setmetatable(t, gs_mt)
end
