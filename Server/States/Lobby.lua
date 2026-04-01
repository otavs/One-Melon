Lobby = {}

function Lobby.InitState()
    Game.State = State.Lobby
    Game.Timer = Config.LobbyDuration
    ClearScoreBoard()
    DestroyAllPowerUps()
    for _, player in pairs(Player.GetAll()) do
        EnterLobbyStateUI(player)
        DestroyWeapons(player)
        TeleportToLobby(player)
        SetLobbySettings(player)
        UnFreezePlayer(player)
    end
end

function Lobby.OnPlayerJoin(player)
    CreateCharacter(player, GetLobbySpawnLocation())
    EnterLobbyStateUI(player)
    SetLobbySettings(player)
    Timer.SetTimeout(function() ShowHelpUI(player) end, 1000)
end

function Lobby.OnCharacterDeath(character, last_damage_taken, last_bone_damaged, damage_type_reason, hit_from_direction, instigator, causer)
    character:Respawn(GetLobbySpawnLocation())
end

function Lobby.HandleVoidPlayers(playersOnVoid)
    for _, player in pairs(playersOnVoid) do
        TeleportToLobby(player)
    end
end

function TeleportToLobby(player)
    local character = player:GetControlledCharacter()
    if character and character:IsValid() then
        if character:IsDead() then
            character:Respawn(GetLobbySpawnLocation())
        else
            character:AddImpulse(character:GetVelocity() * -1, true)
            character:SetLocation(GetLobbySpawnLocation())
        end
    end
end

function SetLobbySettings(player)
    local character = player:GetControlledCharacter()
    if character and character:IsValid() then
        character:SetMaxHealth(Config.PlayerMaxHealth)
        character:SetHealth(Config.PlayerMaxHealth)
        character:SetSpeedMultiplier(Config.PlayerSpeed)
        character:SetJumpZVelocity(Config.PlayerJumpForce)
    end
end

function ShowHelpUI(player)
    Events.CallRemote("ShowHelpUI", player)
end

function EnterLobbyStateUI(player)
    Events.CallRemote("EnterLobbyStateUI", player)
end

function GetLobbySpawnLocation()
    return Vector(
        Config.LobbyLocation.X + math.random(-1200, 1500),
        Config.LobbyLocation.Y + math.random(-1300, 1600),
        Config.LobbyLocation.Z
    )
end