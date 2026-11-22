-- Armoured Biters compat: reskins its armoured biters and spawners with the armoured-* skin settings.
-- Size comes from the name prefix (small-armoured-biter, ..., leviathan-armoured-biter).
local units = require("helpers/unit_logic")
local spawners = require("helpers/spawner_logic")

local armoured_biters = {}

local scale_by_size = { small = 0.3, medium = 0.5, big = 1.0, behemoth = 1.5, leviathan = 2.0 }

local function scale_for(name)
    for size, scale in pairs(scale_by_size) do
        if name:find(size, 1, true) then return scale end
    end
    return scale_by_size.small
end

function armoured_biters.apply()
    local biter_skin = settings.startup["armoured-biter-skin-setting"].value
    local spawner_skin = settings.startup["armoured-spawner-skin-setting"].value

    for name, unit in pairs(data.raw["unit"]) do
        if name:find("armoured", 1, true) and name:find("biter", 1, true) then
            units.update_unit(unit, "biter", scale_for(name), biter_skin)
        end
    end

    for name, spawner in pairs(data.raw["unit-spawner"]) do
        if name:find("armoured", 1, true) then
            spawners.update_spawner(spawner, spawners.base_scale, spawner_skin)
        end
    end
end

return armoured_biters
