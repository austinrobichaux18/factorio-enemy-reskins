-- Startup settings: a scale multiplier per enemy kind and a skin dropdown per tier, built from helpers/constants.lua.
local constants = require("helpers/constants")

local list = {
    {
        type = "bool-setting",
        name = "startup-message-setting",
        setting_type = "runtime-global",
        default_value = true,
        order = "a"
    },
    {
        type = "bool-setting",
        name = "enable-tint-setting",
        setting_type = "startup",
        default_value = true,
        order = "a"
    },
}

-- One "<kind>-scale-setting" plus one "<key>-<kind>-skin-setting" per key.
local function add_group(kind, order, skins, defaults, keys)
    table.insert(list, {
        type = "double-setting",
        name = kind .. "-scale-setting",
        setting_type = "startup",
        default_value = 1.0,
        minimum_value = 0.1,
        maximum_value = 10,
        order = order .. "-00"
    })
    for i, key in ipairs(keys) do
        table.insert(list, {
            type = "string-setting",
            name = key .. "-" .. kind .. "-skin-setting",
            setting_type = "startup",
            default_value = defaults[key],
            allowed_values = skins,
            order = order .. "-" .. (9 + i)
        })
    end
end

add_group("biter", "a[biters]", constants.unit_skins, constants.biter_defaults, constants.tiers)
add_group("spitter", "b[spitters]", constants.unit_skins, constants.spitter_defaults, constants.tiers)
add_group("worm", "c[worms]", constants.worm_skins, constants.worm_defaults, constants.tiers)
add_group("spawner", "d[spawners]", constants.spawner_skins, constants.spawner_defaults, { "biter", "spitter" })

if mods["ArmouredBiters"] then
    table.insert(list, {
        type = "string-setting",
        name = "armoured-biter-skin-setting",
        setting_type = "startup",
        default_value = "default",
        allowed_values = constants.unit_skins,
        order = "ea[biters]-10"
    })
    table.insert(list, {
        type = "string-setting",
        name = "armoured-spawner-skin-setting",
        setting_type = "startup",
        default_value = "default",
        allowed_values = constants.spawner_skins,
        order = "eb[spawners]-10"
    })
end

data:extend(list)
