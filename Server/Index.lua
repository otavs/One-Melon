Package.Require("Config.lua")
Package.Require("Utils.lua")
Package.Require("Log.lua")
Package.Require("Chat.lua")
Package.Require("Game.lua")
Package.Require("Hats.lua")
Package.Require("Skins.lua")
Package.Require("Breakable.lua")
Package.Require("Scores.lua")
Package.Require("MelonGun.lua")
Package.Require("Bonker.lua")
Package.Require("Player.lua")
Package.Require("Weapons.lua")
Package.Require("Controls.lua")
Package.Require("PowerUp.lua")
Package.Require("Test.lua")
Package.Require("States/Lobby.lua")
Package.Require("States/Playing.lua")
Package.Require("States/PostGame.lua")

Server.Subscribe("Tick", function(delta)
    TickAllPowerUps(delta)
end)

Lobby.InitState()

for _, player in pairs(Player.GetAll()) do
  CreateCharacter(player, Config.LobbyLocation)
end

Timer.SetInterval(function()
    if #Player.GetAll() == 0 then
        return
    end
    Game.Timer = Game.Timer - 1
    print(Game.State .. ": " .. Game.Timer)
    Events.BroadcastRemote("UpdateTimer", Game.Timer)
    if Game.Timer <= 0 then
        if Game.State == State.Lobby then
            Playing.InitState()
        elseif Game.State == State.PostGame then
            Lobby.InitState()
        end
    end
end, 1000)
