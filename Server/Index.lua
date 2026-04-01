Package.Require("Config.lua")
Package.Require("Utils.lua")
Package.Require("Log.lua")
Package.Require("Chat.lua")
Package.Require("Sound.lua")
Package.Require("Game.lua")
Package.Require("Hats.lua")
Package.Require("Skins.lua")
Package.Require("Breakable.lua")
Package.Require("Awards.lua")
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

Timer.SetTimeout(function() SpawnUgandan() end, 200)

StateList = {
    [State.Lobby] = Lobby,
    [State.Playing] = Playing,
    [State.PostGame] = PostGame
}

Timer.SetInterval(function()
    if #Player.GetAll() == 0 then
        return
    end

    local currentState = StateList[Game.State]

    Game.Timer = Game.Timer - 1
    -- print(Game.State .. ": " .. Game.Timer)
    Events.BroadcastRemote("UpdateTimer", Game.Timer)

    local playersOnVoid = GetPlayersOnVoid()
    currentState.HandleVoidPlayers(playersOnVoid)
    if Game.State == State.Lobby then
        if Game.Timer <= 0 then
            Playing.InitState()
        end
    elseif Game.State == State.Playing then
        Playing.SpawnPowerUps()
    elseif Game.State == State.PostGame then
        if Game.Timer <= 0 then
            Lobby.InitState()
        end
    end
end, 1000)

function GetPlayersOnVoid()
    local playersOnVoid = {}
    for _, player in pairs(Player.GetAll()) do
        local character = player:GetControlledCharacter()
        if character and character:IsValid() and character:GetLocation().Z < -100 then
            table.insert(playersOnVoid, player)
        end
    end
    return playersOnVoid
end

function SpawnUgandan()
    local location = Vector(61402.10, -24949.10, 597.90 + 10)
    local ugandan = CharacterSimple(location, Rotator(0, 90, 0), "nanos-world::SK_AncientUgandan")
    
    ugandan:SetScale(1.1)
    ugandan:SetHealth(10000)

    ugandan:Subscribe("TakeDamage", function(self, damage, bone, type, from_direction, instigator, causer)
        local character = instigator:GetControlledCharacter()
        if character and character:IsValid() then
            local impulse = -from_direction:GetSafeNormal() * 13000 + Vector(0, 0, 200)
            character:AddImpulse(impulse, true)
        end
    end)
end
