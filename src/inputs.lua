local tactile = require "tactile"
local cpml    = require "cpml"

-- Define inputs
local k = tactile.keys
local m = function(button)
	 return function() return love.mouse.isDown(button) end
end
local g = function(button)
	return tactile.gamepadButtons(1, button)
end

local kb_return = function()
	return love.keyboard.isDown("return") and
		not (love.keyboard.isDown("lalt") or love.keyboard.isDown("ralt"))
end

return {
	mouse = {
		position = cpml.vec2(0, 0),
		delta    = cpml.vec2(0, 0)
	},
	update_mouse = function(self, x, y, dx, dy)
		if x then self.mouse.position.x = x end
		if y then self.mouse.position.y = y end
		if not dx then self.mouse.delta.x = 0 end
		if not dy then self.mouse.delta.y = 0 end
		if dx then self.mouse.delta.x = self.mouse.delta.x + dx end
		if dy then self.mouse.delta.y = self.mouse.delta.y + dy end
	end,
	sys = {
		enter           = tactile.newControl():addButton(kb_return),
		escape          = tactile.newControl():addButton(k "escape"),
		mute            = tactile.newControl():addButton(k "pause"),
		change_language = tactile.newControl():addButton(k "f12"),
		show_overscan   = tactile.newControl():addButton(k "f10"),
	},
	game = {
		move_x = tactile.newControl()
			:addAxis(tactile.gamepadAxis(1, "leftx"))
			:addButtonPair(k("a", "left"), k("d", "right")),
		move_y = tactile.newControl()
			:addAxis(tactile.gamepadAxis(1, "lefty"))
			:addButtonPair(k("w", "up"), k("s", "down")),
		camera_x = tactile.newControl()
			:addAxis(tactile.gamepadAxis(1, "rightx")),
		camera_y = tactile.newControl()
			:addAxis(tactile.gamepadAxis(1, "righty")),
		trigger_l = tactile.newControl()
			:addButton(k("q", "rshift", "lshift"))
			:addAxis(tactile.gamepadAxis(1, "triggerleft")),
		trigger_r = tactile.newControl()
			:addButton(k("e", "kp0", "space"))
			:addAxis(tactile.gamepadAxis(1, "triggerright")),
		action = tactile.newControl()
			:addButton(m(1))
			:addButton(k("z", "k"))
			:addButton(g("a")),
		dodge = tactile.newControl()
			:addButton(m(2))
			:addButton(k("x", "l"))
			:addButton(g("b")),
		jump = tactile.newControl()
			:addButton(k("space", "kp0"))
			:addButton(g("x")),
		turbo = tactile.newControl()
			:addButton(k("return", "f"))
			:addButton(g("x")),
		menu = tactile.newControl()
			:addButton(k("escape"))
			:addButton(g("back", "start", "y")),
		menu_back = tactile.newControl()
			:addButton(m(3))
			:addButton(k("escape"))
			:addButton(g("back", "b")),
		menu_action = tactile.newControl()
			:addButton(kb_return)
			:addButton(k("space"))
			:addButton(g("a")),
		menu_up = tactile.newControl()
			:addButton(k("up", "w"))
			:addButton(g("dpup")),
		menu_down = tactile.newControl()
			:addButton(k("down", "s"))
			:addButton(g("dpdown")),
		menu_left = tactile.newControl()
			:addButton(k("left", "a"))
			:addButton(g("dpleft")),
		menu_right = tactile.newControl()
			:addButton(k("right", "d"))
			:addButton(g("dpright"))
	},
	update = function(self)
		for k, v in pairs(self.sys) do
			v:update()
		end
		if console.visible then
			return
		end
		for k, v in pairs(self.game) do
			v:update()
		end
	end
}
