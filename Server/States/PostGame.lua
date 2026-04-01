PostGame = {}

function PostGame.InitState()
    Game.State = State.PostGame
    Game.Timer = Config.PostGameDuration
    Events.BroadcastRemote("AnnounceWinner", killerName)
    GenerateFinalAwards()
    for _, player in pairs(Player.GetAll()) do
        FreezePlayer(player)
        EnterPostGameUI(player)
    end
    BroadcastFinalScores(nil)
    Play2dSound("yay.mp3", 2, 1)
end

function PostGame.OnPlayerJoin(player)
    CreateCharacter(player, GetGameSpawnLocation())
    FreezePlayer(player)
    EnterPostGameUI(player)
    BroadcastFinalScores(player)
end

function PostGame.OnCharacterDeath(character, last_damage_taken, last_bone_damaged, damage_type_reason, hit_from_direction, instigator, causer)
    character:Respawn(GetGameSpawnLocation())
end

function PostGame.HandleVoidPlayers(playersOnVoid)
    for _, player in pairs(playersOnVoid) do
        local character = player:GetControlledCharacter()
        if character and character:IsValid() then
            character:Respawn(GetGameSpawnLocation())
        end
    end
end

function EnterPostGameUI(player)
    Events.CallRemote("EnterPostGameStateUI", player)
end