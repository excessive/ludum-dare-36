local anchor = require "anchor"
local timer  = require "timer"
local tiny   = require "tiny"

local gs    = {}
local gs_mt = { __index = gs }

function gs:enter(from, results)
	love.graphics.setBackgroundColor(30, 30, 44)

	self.world          = tiny.world()
	self.world.language = require("languages").load(_G.PREFERENCES.language)
	self.world.inputs   = require "inputs"

	self.timer = 0
end

function gs:leave(self)
	love.mouse.setVisible(true)
end

function gs:update(dt)
	self.timer = self.timer + dt

	if self.timer < 5 then
		return
	end

	love.event.quit()
end

function gs:draw()
	love.graphics.print("you lost :( sorry, we're still finishing this screen!", anchor:center_x(), anchor:center_y())
end

return function()
	local t = tiny.system {
		name     = "Bad End",
		priority = 0
	}
	return setmetatable(t, gs_mt)
end
