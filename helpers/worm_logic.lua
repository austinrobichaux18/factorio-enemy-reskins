-- Reskins worm turrets and their corpses from graphics/worms/<skin>.png
-- (128px cells, 8 directions, line_length 3; corpses <skin>_corpse.png, 128px, 4 directions, line_length 2).
local common = require("helpers/common")
local constants = require("helpers/constants")

local worms = {}

worms.scale = { small = 1, medium = 1.2, big = 1.4, behemoth = 2 }

local animation_fields = {
    "folded_animation", "preparing_animation", "prepared_animation", "folding_animation",
    "attacking_animation", "ending_attack_animation", "starting_attack_animation",
    "prepared_alternative_animation",
}

function worms.skins()
    local skins = {}
    for _, tier in ipairs(constants.tiers) do
        skins[tier] = settings.startup[tier .. "-worm-skin-setting"].value
    end
    return skins
end

-- Returns true when the worm was reskinned (false for a missing worm or the 'default' skin).
---@param worm data.TurretPrototype
function worms.update_worm(worm, base_scale, skin)
    if not worm or skin == "default" then return false end
    local scale = common.scaled(base_scale, "worm")
    local base = "__enemy-reskins__/graphics/worms/" .. skin

    local animation = { layers = { {
        filename = base .. ".png", width = 128, height = 128,
        frame_count = 1, direction_count = 8, line_length = 3, scale = scale,
    } } }
    for _, field in ipairs(animation_fields) do
        worm[field] = animation
    end
    worm.attack_parameters.animation = animation
    -- The glow layer draws additively on top; the vanilla one doesn't fit the new sprite.
    worm.energy_glow_animation = nil

    local corpse = data.raw["corpse"][worm.corpse]
    if corpse then
        local anim = { layers = { {
            filename = base .. "_corpse.png", width = 128, height = 128,
            frame_count = 1, direction_count = 4, line_length = 2, scale = scale,
        } } }
        corpse.animation = anim
        corpse.decay_animation = anim
        corpse.direction_shuffle = nil
    end
    return true
end

function worms.set_all()
    local skins = worms.skins()
    for _, tier in ipairs(constants.tiers) do
        worms.update_worm(data.raw["turret"][tier .. "-worm-turret"], worms.scale[tier], skins[tier])
    end
end

return worms
