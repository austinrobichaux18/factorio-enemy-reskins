-- Reskins biter/spitter units and their corpses from graphics/units/<skin>.png
-- (162px cells, 8 directions, line_length 3; corpses 128px, 4 directions, line_length 2).
local common = require("helpers/common")
local constants = require("helpers/constants")

local units = {}

units.scale = {
    biter = { small = 0.3, medium = 0.5, big = 1.0, behemoth = 1.5 },
    spitter = { small = 0.3, medium = 0.5, big = 0.6, behemoth = 0.8 },
}

-- The chosen skin per tier for kind "biter" or "spitter".
function units.skins(kind)
    local skins = {}
    for _, tier in ipairs(constants.tiers) do
        skins[tier] = settings.startup[tier .. "-" .. kind .. "-skin-setting"].value
    end
    return skins
end

-- Returns true when the unit was reskinned (false for a missing unit or the 'default' skin).
---@param unit data.UnitPrototype
function units.update_unit(unit, kind, base_scale, skin)
    if not unit or skin == "default" then return false end
    local scale = common.scaled(base_scale, kind)
    local filename = "__enemy-reskins__/graphics/units/" .. skin .. ".png"

    unit.run_animation = { layers = { {
        filename = filename, width = 162, height = 162,
        frame_count = 1, direction_count = 8, line_length = 3, scale = scale,
    } } }
    -- The attack animation reuses the sheet as an 8-frame spin.
    unit.attack_parameters.animation = { layers = { {
        filename = filename, width = 162, height = 162,
        frame_count = 8, line_length = 3, scale = scale,
    } } }
    -- Vanilla frame sequencing indexes frames the new sheet doesn't have.
    unit.alternative_attacking_frame_sequence = nil

    local corpse = data.raw["corpse"][unit.corpse]
    if corpse then
        -- Every titan skin shares titan_corpse.png.
        local corpse_skin = skin:find("titan", 1, true) and "titan" or skin
        local anim = { layers = { {
            filename = "__enemy-reskins__/graphics/units/" .. corpse_skin .. "_corpse.png",
            width = 128, height = 128,
            frame_count = 1, direction_count = 4, line_length = 2, scale = scale,
        } } }
        corpse.animation = anim
        corpse.decay_animation = anim
        corpse.direction_shuffle = nil
    end
    return true
end

local function set_kind(kind)
    local skins = units.skins(kind)
    local colors = common.tint_colors
    -- {color, brightness} per tier; big turns blue only when it shares medium's skin.
    local tints = {
        small = { colors.small, 0.6 },
        medium = { colors.medium_same_troop },
        big = { skins.medium == skins.big and colors.big or colors.small },
        behemoth = { colors.medium },
    }
    for _, tier in ipairs(constants.tiers) do
        local unit = data.raw["unit"][tier .. "-" .. kind]
        if units.update_unit(unit, kind, units.scale[kind][tier], skins[tier]) then
            common.tint_unit(unit, tints[tier][1], true, tints[tier][2])
        end
    end
end

function units.set_all()
    set_kind("biter")
    set_kind("spitter")
end

return units
