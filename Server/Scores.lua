PlayerScores = {}
PlayerCombos = {}
PlayerComboTimers = {}
AAA = 0

function BroadcastKill(instigator, victimCharacter)
  local killerPlayer = instigator and instigator:IsValid() and instigator or nil
  local killerName = killerPlayer and killerPlayer:GetName() or "Unknown"
  local victimPlayer = victimCharacter:GetPlayer()
  local victimName = victimPlayer and victimPlayer:IsValid() and victimPlayer:GetName() or "Bot"
  Events.BroadcastRemote("KillFeed", killerName, victimName, Config.KillFeedDuration)

  if killerPlayer then
    local killerId = killerPlayer:GetAccountID()

    if not PlayerScores[killerId] then
      PlayerScores[killerId] = { id = killerId, name = killerName, icon = killerPlayer:GetAccountIconURL(), kills = 0 }
    end
    PlayerScores[killerId].kills = PlayerScores[killerId].kills + 1

    PlayerCombos[killerId] = (PlayerCombos[killerId] or 0) + 1
    local combo = PlayerCombos[killerId]
    Events.CallRemote("UpdateCombo", killerPlayer, combo)

    if PlayerComboTimers[killerId] then
      Timer.ClearTimeout(PlayerComboTimers[killerId])
    end
    PlayerComboTimers[killerId] = Timer.SetTimeout(function()
      PlayerCombos[killerId] = 0
      if killerPlayer:IsValid() then
        Events.CallRemote("UpdateCombo", killerPlayer, 0)
      end
      PlayerComboTimers[killerId] = nil
    end, Config.ComboDuration * 1000)

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