PostGame = {}

function PostGame.InitState()
    Game.State = State.PostGame
    Game.Timer = Config.PostGameDuration
    Events.BroadcastRemote("AnnounceWinner", killerName)
    for _, player in pairs(Player.GetAll()) do
        FreezePlayer(player)
        OpenPostGameUI(player)
    end
end

function PostGame.OnPlayerJoin(player)
    CreateCharacter(player, Config.GameLocation)
    FreezePlayer(player)
    OpenPostGameUI(player)
end

function PostGame.OnCharacterDeath(character, last_damage_taken, last_bone_damaged, damage_type_reason, hit_from_direction, instigator, causer)
    character:Respawn(Config.GameLocation)
end

function FreezePlayer(player)
    local character = player:GetControlledCharacter()
    if character then
        character:SetInputEnabled(false)
    end
end

function OpenPostGameUI(player)
    print("TODO OpenPostGameUI")
end