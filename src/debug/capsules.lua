local cpml = require "cpml"
local tiny = require "tiny"

return function(self)
    -- Load player collision sphere
    self.sphere = self.world:addEntity(require("assets.entities.sphere")({
        orientation = self.player.orientation,
        radius      = cpml.vec3(0.5, 0.5, 1),
        scale       = cpml.vec3(0.5, 0.5, 1),
        wireframe   = true,
        color       = { 1, 1, 0 }
    }))

    -- Load player collision capsule
    self.capsule = {
        top = self.world:addEntity(require("assets.entities.sphere")({
            orientation = self.player.orientation,
            radius      = cpml.vec3(0.5, 0.5, 0.5),
            scale       = cpml.vec3(0.5, 0.5, 0.5),
            wireframe   = true,
            color       = { 0, 1, 0 }
        })),

        middle = self.world:addEntity(require("assets.entities.cylinder")({
            orientation = self.player.orientation,
            radius      = cpml.vec3(0.5, 0.5, 0.5),
            scale       = cpml.vec3(0.5, 0.5, 0.5),
            wireframe   = true,
            color       = { 0, 1, 0 }
        })),

        bottom = self.world:addEntity(require("assets.entities.sphere")({
            orientation = self.player.orientation,
            radius      = cpml.vec3(0.5, 0.5, 0.5),
            scale       = cpml.vec3(0.5, 0.5, 0.5),
            wireframe   = true,
            color       = { 0, 1, 0 }
        }))
    }

    self.enemy_capsule = {
        top = self.world:addEntity(require("assets.entities.sphere")({
            radius    = cpml.vec3(0.5, 0.5, 0.5),
            scale     = cpml.vec3(0.5, 0.5, 0.5),
            wireframe = true,
            color     = { 0.5, 0, 0.5 }
        })),

        middle = self.world:addEntity(require("assets.entities.cylinder")({
            radius    = cpml.vec3(0.5, 0.5, 0.5),
            scale     = cpml.vec3(0.5, 0.5, 0.5),
            wireframe = true,
            color     = { 0.5, 0, 0.5 }
        })),

        bottom = self.world:addEntity(require("assets.entities.sphere")({
            radius    = cpml.vec3(0.5, 0.5, 0.5),
            scale     = cpml.vec3(0.5, 0.5, 0.5),
            wireframe = true,
            color     = { 0.5, 0, 0.5 }
        }))
    }

    -- DEBUG SHAPES AROUND PLAYER
    self.world:addSystem(tiny.system {
        name     = "Debug Shapes",
        priority = 205,
        update   = function()
            local player  = self.player
            local sphere  = self.sphere
            local capsule = self.capsule
            local e_cap   = self.enemy_capsule
            local cap_off = player.capsule_offset
            local prz     = cpml.vec3(0, 0, player.radius.z + player.lifter.z)

            sphere.position:add(self.player.position, prz)
            capsule.top.position:add(self.player.position, cap_off.a)
            capsule.middle.position:add(self.player.position, prz)
            capsule.bottom.position:add(self.player.position, cap_off.b)

            e_cap.top.position:add(self.enemy.position, cap_off.a)
            e_cap.middle.position:add(self.enemy.position, prz)
            e_cap.bottom.position:add(self.enemy.position, cap_off.b)
        end
    })
end
