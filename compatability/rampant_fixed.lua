-- RampantFixed compat: reskins its tiered (-t<N>-) units, worms and spawners with the vanilla tier skins
-- and tints each by the element in its name.
local common = require("helpers/common")
local units = require("helpers/unit_logic")
local worms = require("helpers/worm_logic")
local spawners = require("helpers/spawner_logic")

local rampant_fixed = {}

-- Checked in order; the generic "spawner" goes last so an element keyword wins.
local element_tints = {
    { "acid", { 0, 255, 0 } },         -- neon green
    { "arachnids", { 120, 60, 20 } },  -- brown
    { "electric", { 0, 255, 255 } },   -- cyan
    { "energy-thief", { 160, 0, 255 } }, -- purple
    { "fast", { 255, 255, 255 } },     -- white
    { "fire", { 255, 64, 0 } },        -- orange-red
    { "inferno", { 255, 0, 0 } },      -- bright red
    { "juggernaut", { 96, 96, 96 } },  -- dark gray
    { "laser", { 255, 0, 255 } },      -- magenta
    { "neutral", { 192, 192, 192 } },  -- light gray
    { "nuclear", { 128, 255, 0 } },    -- radioactive lime
    { "physical", { 139, 69, 19 } },   -- dark brown
    { "poison", { 128, 0, 128 } },     -- violet
    { "suicide", { 255, 255, 0 } },    -- bright yellow
    { "troll", { 0, 128, 255 } },      -- azure
    { "wasp", { 255, 200, 0 } },       -- amber
    { "spawner", { 255, 215, 0 } },    -- gold
}

local function element_tint(name)
    for _, entry in ipairs(element_tints) do
        if name:find(entry[1], 1, true) then
            local c = entry[2]
            return common.rgb(c[1], c[2], c[3])
        end
    end
end

local function tier_of(name)
    return tonumber(name:match("%-t(%d+)%-"))
end

local function size_of(tier)
    if tier <= 2 then return "small" end
    if tier <= 5 then return "medium" end
    if tier <= 8 then return "big" end
    return "behemoth"
end

-- Spawner scale grows with tier, at half rate past tier 5.
local function spawner_scale(tier)
    if tier <= 5 then return tier end
    return 5 + (tier - 5) * 0.5
end

local function is_rampant(name)
    return name:find("rampant", 1, true) ~= nil
end

function rampant_fixed.apply()
    local unit_skins = { biter = units.skins("biter"), spitter = units.skins("spitter") }
    for name, unit in pairs(data.raw["unit"]) do
        if is_rampant(name) then
            local tier = tier_of(name)
            if tier then
                local size = size_of(tier)
                for _, kind in ipairs({ "biter", "spitter" }) do
                    if name:find(kind, 1, true) then
                        units.update_unit(unit, kind, units.scale[kind][size], unit_skins[kind][size])
                    end
                end
            end
            local color = element_tint(name)
            if color then common.tint_unit(unit, color) end
        end
    end

    local worm_skins = worms.skins()
    for name, turret in pairs(data.raw["turret"]) do
        if is_rampant(name) then
            local tier = tier_of(name)
            if tier and name:find("worm", 1, true) then
                local size = size_of(tier)
                worms.update_worm(turret, worms.scale[size], worm_skins[size])
            end
            local color = element_tint(name)
            if color then common.tint_turret(turret, color) end
        end
    end

    for name, spawner in pairs(data.raw["unit-spawner"]) do
        if is_rampant(name) then
            local tier = tier_of(name)
            if tier then
                for _, kind in ipairs({ "biter", "spitter" }) do
                    if name:find(kind, 1, true) then
                        spawners.update_spawner(spawner, spawner_scale(tier),
                            settings.startup[kind .. "-spawner-skin-setting"].value)
                        break
                    end
                end
            end
            local color = element_tint(name)
            if color then common.tint_spawner(spawner, color) end
        end
    end
end

return rampant_fixed
