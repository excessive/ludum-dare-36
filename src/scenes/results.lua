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

	self.results = type(results) == "table" and results or {
		time        = 999,
		total_time  = 999,
		strikes     = 0,
		bonks       = 0,
		total_bonks = 0,
		level       = 1
	}

	self.formats = {
		time        = "%2.2f",
		total_time  = "%2.2f",
		strikes     = "%d",
		bonks       = "%d",
		total_bonks = "%d",
		level       = "%d"
	}

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

	local results = self.results
	-- 3 strikes, you're outta here!
	if results.strikes == 3 then
		_G.Scene.switch(require("scenes.bad-end")())
		return
	end

	-- You did it!
	if results.level == 7 then
		_G.Scene.switch(require("scenes.good-end")())
		return
	end

	-- Next level
	_G.Scene.switch(require("scenes.play")(), {
		total_elapsed = results.total_time,
		total_bonks   = results.total_bonks,
		level         = results.level + 1,
		strikes       = results.strikes,
		octree        = results.octree
	})
end

function gs:draw()
	local get = self.world.language
	local i = 1
	for k, v in pairs(self.results) do
		love.graphics.print(string.format("%s: %s", get(k), string.format(self.formats[k] or "%s", v)), anchor:center_x() - 200, anchor:center_y() - 200 + i * 30)
		i = i + 1
	end
end

return function()
	local t = tiny.system {
		name     = "Results",
		priority = 0
	}
	return setmetatable(t, gs_mt)
end
