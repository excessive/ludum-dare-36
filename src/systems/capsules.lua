local tiny = require "tiny"

-- Update capsule BEFORE collisions!
return tiny.processingSystem {
    name     = "Update Capsules",
    priority = 185,
    filter   = tiny.requireAll("position", "radius", "capsule", "capsule_offset"),
    process  = function(_, entity, dt)
        entity.capsule.a:add(entity.position, entity.capsule_offset.a)
        entity.capsule.b:add(entity.position, entity.capsule_offset.b)
    end
}
