-- Reskins unit spawners and their corpses from graphics/spawners/<skin>.png and <skin>_corpse.png (64px, single frame).
local common = require("helpers/common")

local spawners = {}

spawners.base_scale = 3

-- Returns true when the spawner was reskinned (false for a missing spawner or the 'default' skin).
---@param spawner data.EnemySpawnerPrototype
function spawners.update_spawner(spawner, base_scale, skin)
    if not spawner or skin == "default" then return false end
    local scale = common.scaled(base_scale, "spawner")
    local base = "__enemy-reskins__/graphics/spawners/" .. skin

    spawner.graphics_set.animations = { layers = { {
        filename = base .. ".png", width = 64, height = 64,
        frame_count = 1, line_length = 1, scale = scale,
    } } }

    local corpse = data.raw["corpse"][spawner.corpse]
    if corpse then
        local anim = { layers = { {
            filename = base .. "_corpse.png", width = 64, height = 64,
            frame_count = 1, line_length = 1, scale = scale / 2,
            tint = { 1, 1, 1, 0.5 },
        } } }
        corpse.time_before_removed = 3600
        corpse.animation = anim
        corpse.decay_animation = anim
        corpse.direction_shuffle = nil
    end
    return true
end

function spawners.set_all()
    for _, kind in ipairs({ "biter", "spitter" }) do
        spawners.update_spawner(data.raw["unit-spawner"][kind .. "-spawner"], spawners.base_scale,
            settings.startup[kind .. "-spawner-skin-setting"].value)
    end
end

return spawners
