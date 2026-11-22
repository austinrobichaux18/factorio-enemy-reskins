-- Shared reskin helpers: the per-kind scale setting multiplier and tinting of units, worms and spawners.
-- Tinting is a no-op when the enable-tint-setting startup setting is off.
local common = {}

common.tint_colors = {
    small = { 0.85, 0.7, 0.25, 1 },
    medium = { 0.35, 0.45, 0.65, 1 },
    big = { 0.25, 0.35, 0.80, 1 },
    medium_same_troop = { 0.75, 0.30, 0.45, 1 },
}

-- kind is "biter", "spitter", "worm" or "spawner".
function common.scaled(base_scale, kind)
    return base_scale * settings.startup[kind .. "-scale-setting"].value
end

function common.rgb(r, g, b)
    return { r / 255, g / 255, b / 255, 1 }
end

local function tint_enabled()
    return settings.startup["enable-tint-setting"].value
end

local function final_color(color, brightness)
    brightness = brightness or 0.7
    return {
        math.min(color[1] * brightness, 1),
        math.min(color[2] * brightness, 1),
        math.min(color[3] * brightness, 1),
        color[4] or 1,
    }
end

local function tint_layers(anim, color, overlay)
    if not anim or not anim.layers then return end
    for _, layer in pairs(anim.layers) do
        layer.tint = color
        layer.tint_as_overlay = overlay
    end
end

local function tint_corpse(corpse_name, color, overlay)
    local corpse = corpse_name and data.raw["corpse"][corpse_name]
    if corpse then tint_layers(corpse.animation, color, overlay) end
end

---@param unit data.UnitPrototype
function common.tint_unit(unit, color, overlay, brightness)
    if not unit or not tint_enabled() then return end
    local c = final_color(color, brightness)
    tint_layers(unit.run_animation, c, overlay)
    tint_layers(unit.attack_parameters and unit.attack_parameters.animation, c, overlay)
    tint_corpse(unit.corpse, c, overlay)
end

local turret_fields = {
    "folded_animation", "preparing_animation", "prepared_animation", "folding_animation",
    "attacking_animation", "energy_glow_animation", "ending_attack_animation",
    "starting_attack_animation", "prepared_alternative_animation",
}

---@param turret data.TurretPrototype
function common.tint_turret(turret, color, overlay, brightness)
    if not turret or not tint_enabled() then return end
    local c = final_color(color, brightness)
    for _, field in ipairs(turret_fields) do
        tint_layers(turret[field], c, overlay)
    end
    tint_layers(turret.attack_parameters and turret.attack_parameters.animation, c, overlay)
    tint_corpse(turret.corpse, c, overlay)
end

---@param spawner data.EnemySpawnerPrototype
function common.tint_spawner(spawner, color, overlay, brightness)
    if not spawner or not tint_enabled() then return end
    local c = final_color(color, brightness)
    tint_layers(spawner.graphics_set and spawner.graphics_set.animations, c, overlay)
    tint_corpse(spawner.corpse, c, overlay)
end

return common
