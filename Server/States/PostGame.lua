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
    CreateCharacter(player, Config.GameLocation)
    FreezePlayer(player)
    EnterPostGameUI(player)
    BroadcastFinalScores(player)
end

function PostGame.OnCharacterDeath(character, last_damage_taken, last_bone_damaged, damage_type_reason, hit_from_direction, instigator, causer)
    character:Respawn(Config.GameLocation)
end

function EnterPostGameUI(player)
    Events.CallRemote("EnterPostGameStateUI", player)
end