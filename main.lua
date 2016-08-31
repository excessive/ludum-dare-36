require "iqm"
-- WE GLOBAL NOW
_G.fire = require "fire"
local fire = _G.fire
fire.save_the_world()

_G.Scene        = require "scene"
_G.conversation = require("talkback").new()
_G.console      = require "console"

local Scene   = _G.Scene
local console = _G.console

local anchor = require "anchor"
local tiny   = require "tiny"

local output        = love.thread.getChannel("output")
local flags         = {
	["debug"] = false
}

console.defineCommand(
	"current-screen",
	"(debug) current-screen: what screen is this?",
	function()
		local top = Scene.current()
		console.d("Current screen: %s", top.name or "<unknown>")
	end
)

console.defineCommand(
	"set-screen",
	"(debug) set-screen: go to screen",
	function(name)
		local screen = "scenes." .. name
		local ok, msg = pcall(require, screen)
		if ok then
			_G.initial_screen = screen
			Scene.switch(msg())
		else
			console.d("Invalid screen!")
		end
	end
)

function love.load(args)
	for _, arg in pairs(args) do
		if arg:sub(1,2) == "--" then
			local flag = arg:sub(3)
			flags[flag] = true
		end
	end

	-- Load global preferences
	_G.PREFERENCES = {
		language  = "en",
		volume    = 1.0,
		completed = 0
	}
	if love.filesystem.isFile("preferences.json") then
		local json = require "dkjson"
		local p = love.filesystem.read("preferences.json")
		_G.PREFERENCES = json.decode(p)
	end

	-- Set overscan
	anchor:set_overscan(0.1)

	love.audio.setVolume(_G.PREFERENCES.volume)
	love.audio.setDistanceModel("inverseclamped")

	love.keyboard.setTextInput(false)

	local default_screen = "scenes.splash"
	Scene.switch(require(_G.initial_screen or default_screen)(), 1)
	Scene.register_callbacks()

	love.resize(love.graphics.getDimensions())
end

-- Painfully, we can't get a thread backtrace from here. The only way to get
-- one is if you xpcall everything in a thread yourself to gather the trace
-- and push the results over a channel...
function love.threaderror(t, e)
	console.e("%s: %s", t, e)
end

local was_paused = false
local was_grabbed = true
local focused = true
function love.focus(f)
	local top = Scene.current()
	focused = f
	if f then
		love.mouse.setRelativeMode(was_grabbed)
		if top then
			top.paused = was_paused
		end 
	else
		if top then
			was_paused = top.paused
			top.paused = true
		end
		was_grabbed = love.mouse.getRelativeMode()
		love.mouse.setRelativeMode(false)
	end
	love.mousemoved()
end

function love.mousemoved(x, y, dx, dy)
	local top    = Scene.current()
	local world  = assert(top.world)

	if not focused then
		world.inputs:update_mouse()
		return
	end

	world.inputs:update_mouse(x, y, dx, dy)
end

function love.update(delta, _)
	local unstoppable_systems = tiny.requireAll("no_pause")
	local update_systems      = tiny.requireAll("update", tiny.rejectAny("no_pause"))

	if _G.FLAGS.debug_mode then
		fire.bind("c", function()
			console.d("Cleared debug objects.")
			_G.conversation:say("debug clear")
		end)
	end

	local top    = Scene.current()
	local world  = assert(top.world)

	anchor:update()

	world.inputs:update()

	-- Get all of our thread outputs, they have to print from here.
	local s = output:pop()
	while s do
		local f = s:sub(1,1) .. "s"
		local line = s:sub(2)
		-- console.ps is special
		if not console[f] or f == "ps" then
			f = "es"
		end
		console[f](line)
		s = output:pop()
	end

	delta = math.min(1/60, delta)
	top:update(delta)

	if top.paused then
		delta = 0
	end

	if top.world then
		local world = top.world

		world:update(delta, update_systems)
		world:update(delta, unstoppable_systems)
		world.inputs:update_mouse()

		if world.renderer then
			-- present what we've got.
			world.renderer:draw()
		else
			top:draw()
		end
	end

	-- Display overscan
	if _G.FLAGS.show_overscan then
		love.graphics.setColor(180, 180, 180, 200)
		love.graphics.setLineStyle("rough")
		love.graphics.line(anchor:left(), anchor:center_y(), anchor:right(), anchor:center_y())
		love.graphics.line(anchor:center_x(), anchor:top(), anchor:center_x(), anchor:bottom())
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.rectangle("line", anchor:bounds())
	end

	-- Cycle language
	if world.inputs.sys.change_language:pressed() then
		world.language.cycle(world)
	end

end

function love.resize(w, h)
	local top = Scene.current()

	-- Resize UI or whatever else needs doing.
	if top.resize then top:resize(w, h) end
end
