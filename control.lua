-- Prints a one-time welcome message to each player, gated by the runtime-global startup-message-setting.
-- Handlers are registered unconditionally (never removed mid-game) so multiplayer peers stay in sync.
local MESSAGE = "Thanks for using Enemy Reskins. Pick skins in Settings > Mod Settings > Startup > Enemy Reskins "
    .. "(restart required). You can turn this message off under Map settings."

local function welcome(player)
    if not player or not settings.global["startup-message-setting"].value then return end
    storage.welcomed = storage.welcomed or {}
    if storage.welcomed[player.index] then return end
    storage.welcomed[player.index] = true
    player.print(MESSAGE)
end

local function welcome_all()
    for _, player in pairs(game.players) do welcome(player) end
end

script.on_init(welcome_all)
script.on_configuration_changed(welcome_all)
script.on_event(defines.events.on_player_created, function(event)
    welcome(game.get_player(event.player_index))
end)
