-- Entry point: reskins vanilla spawners, worms, biters and spitters, then the enemies of supported mods.
require("helpers/spawner_logic").set_all()
require("helpers/worm_logic").set_all()
require("helpers/unit_logic").set_all()

if mods["RampantFixed"] then
    require("compatability/rampant_fixed").apply()
end

if mods["ArmouredBiters"] then
    require("compatability/armoured_biters").apply()
end
