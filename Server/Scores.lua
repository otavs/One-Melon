PlayerScores = {}
PlayerCombos = {}
PlayerComboTimers = {}

function AddCombo(player)
  local playerId = player:GetAccountID()
  PlayerCombos[playerId] = (PlayerCombos[playerId] or 0) + 1
  local combo = PlayerCombos[playerId]
  Events.CallRemote("UpdateCombo", player, combo)

  if PlayerComboTimers[playerId] then
    Timer.ClearTimeout(PlayerComboTimers[playerId])
  end
  PlayerComboTimers[playerId] = Timer.SetTimeout(function()
    if player and player:IsValid() then
      ClearCombo(player)
    end
  end, Config.ComboDuration * 1000)
end

function ClearCombo(player)
  local playerId = player:GetAccountID()
  PlayerCombos[playerId] = 0
  PlayerComboTimers[playerId] = nil
  if player:IsValid() then
    Events.CallRemote("UpdateCombo", player, 0)
  end
end

function BroadcastKill(instigator, victimCharacter, weaponType)
  local killerPlayer = instigator and instigator:IsValid() and instigator or nil
  local killerName = killerPlayer and killerPlayer:GetName() or "Unknown"
  local victimPlayer = victimCharacter:GetPlayer()
  local victimName = victimPlayer and victimPlayer:IsValid() and victimPlayer:GetName() or "Bot"
  Events.BroadcastRemote("KillFeed", killerName, victimName, weaponType)

  if killerPlayer then
    local killerId = killerPlayer:GetAccountID()

    if not PlayerScores[killerId] then
      PlayerScores[killerId] = { id = killerId, name = killerName, icon = killerPlayer:GetAccountIconURL(), kills = 0 }
    end
    PlayerScores[killerId].kills = PlayerScores[killerId].kills + 1

    BroadcastScoreboard()

    if PlayerScores[killerId].kills >= Config.DefaultKillsToWin then
      PostGame.InitState()
    end
  end
end

function AddToScoreboard(player)
  local playerId = player:GetAccountID()
  if not PlayerScores[playerId] then
    PlayerScores[playerId] = { id = playerId, name = player:GetName(), icon = player:GetAccountIconURL(), kills = 0 }
    BroadcastScoreboard()
  end
end

function BroadcastScoreboard()
  local list = {}
  for _, data in pairs(PlayerScores) do
    table.insert(list, data)
  end
  table.sort(list, function(a, b) return a.kills > b.kills end)
  Events.BroadcastRemote("UpdateScoreboard", list)
end

function ClearScoreBoard()
  PlayerScores = {}
  BroadcastScoreboard()
end