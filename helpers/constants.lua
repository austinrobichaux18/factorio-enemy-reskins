-- Skin name lists and default picks. settings.lua turns them into allowed_values / default_value.
-- A skin name is its png name under graphics/<units|worms|spawners>/; 'default' keeps vanilla graphics.
local constants = {}

constants.tiers = { "small", "medium", "big", "behemoth" }

constants.unit_skins = { "goblin", "orc", "piggy", "eye",
    "armoured_titan", "attack_titan", "beast_titan", "cart_titan", "colossal_titan",
    "female_titan", "jaw_titan", "titan_1", "titan_2", "war_hammer_titan", "default" }

constants.biter_defaults = { small = "goblin", medium = "goblin", big = "orc", behemoth = "orc" }
constants.spitter_defaults = { small = "piggy", medium = "piggy", big = "eye", behemoth = "eye" }

constants.worm_skins = { "zerg", "portal2", "default" }
constants.worm_defaults = { small = "portal2", medium = "portal2", big = "portal2", behemoth = "portal2" }

constants.spawner_skins = { "grey-tent", "horn-tent", "default" }
constants.spawner_defaults = { biter = "horn-tent", spitter = "grey-tent" }

return constants
