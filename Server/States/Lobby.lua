Lobby = {}

function Lobby.InitState()
    Game.State = State.Lobby
    Game.Timer = Config.LobbyDuration
    ClearScoreBoard()
    for _, player in pairs(Player.GetAll()) do
        EnterLobbyStateUI(player)
        DestroyWeapons(player)
        SetLobbySettings(player)
        TeleportToLobby(player)
        UnFreezePlayer(player)
    end
end

function Lobby.OnPlayerJoin(player)
    CreateCharacter(player, Config.LobbyLocation)
    EnterLobbyStateUI(player)
    SetLobbySettings(player)
    ShowHelpUI(player)
end

function Lobby.OnCharacterDeath(character, last_damage_taken, last_bone_damaged, damage_type_reason, hit_from_direction, instigator, causer)
    character:Respawn(Config.LobbyLocation)
end

function UnFreezePlayer(player)
    local character = player:GetControlledCharacter()
    if character then
        character:SetInputEnabled(true)
    end
end

function TeleportToLobby(player)
    local character = player:GetControlledCharacter()
    if character and character:IsValid() then
        character:SetLocation(Config.LobbyLocation)
    end
end

function SetLobbySettings(player)
    local character = player:GetControlledCharacter()
    if character and character:IsValid() then
        character:SetMaxHealth(Config.PlayerMaxHealth)
        character:SetHealth(Config.PlayerMaxHealth)
        character:SetSpeedMultiplier(Config.PlayerSpeed)
        character:SetJumpZVelocity(Config.PlayerJumpForce)
        ChangeSkin(player)
    end
end

function ShowHelpUI(player)
    Events.CallRemote("ShowHelpUI", player)
end

function EnterLobbyStateUI(player)
    Events.CallRemote("EnterLobbyStateUI", player)
end