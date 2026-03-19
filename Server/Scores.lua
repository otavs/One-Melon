PlayerScores = {}       -- id -> { id, name, icon, kills, deaths, jumps, powerups, maxCombo }
PlayerCombos = {}       -- runtime: id -> current combo count
PlayerComboTimers = {}  -- runtime: id -> timer handle
FinalAwards = {}        -- generated once when PostGame starts

function GetOrCreateScore(player)
  local playerId = player:GetAccountID()
  if not PlayerScores[playerId] then
    PlayerScores[playerId] = {
      id       = playerId,
      name     = player:GetName(),
      icon     = player:GetAccountIconURL(),
      kills    = 0,
      deaths   = 0,
      jumps    = 0,
      powerups = 0,
      maxCombo = 0,
    }
  end
  return PlayerScores[playerId]
end

function AddCombo(player)
  local playerId = player:GetAccountID()
  PlayerCombos[playerId] = (PlayerCombos[playerId] or 0) + 1
  local combo = PlayerCombos[playerId]
  local score = GetOrCreateScore(player)
  if combo > score.maxCombo then
    score.maxCombo = combo
  end
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

function AddDeath(player)
  if not player or not player:IsValid() then return end
  local score = GetOrCreateScore(player)
  score.deaths = score.deaths + 1
  BroadcastScoreUpdate(player:GetAccountID())
end

function AddJump(player)
  if not player or not player:IsValid() then return end
  local score = GetOrCreateScore(player)
  score.jumps = score.jumps + 1
  BroadcastScoreUpdate(player:GetAccountID())
end

function AddPowerUp(player)
  if not player or not player:IsValid() then return end
  local score = GetOrCreateScore(player)
  score.powerups = score.powerups + 1
  BroadcastScoreUpdate(player:GetAccountID())
end

function BroadcastKill(instigator, victimCharacter, weaponType)
  local killerPlayer = instigator and instigator:IsValid() and instigator or nil
  local killerName = killerPlayer and killerPlayer:GetName() or "Unknown"
  local victimPlayer = victimCharacter:GetPlayer()
  local victimName = victimPlayer and victimPlayer:IsValid() and victimPlayer:GetName() or "Bot"
  Events.BroadcastRemote("KillFeed", killerName, victimName, weaponType)
  if killerPlayer then
    local score = GetOrCreateScore(killerPlayer)
    score.kills = score.kills + 1
    BroadcastScoreUpdate(killerPlayer:GetAccountID())
    if score.kills >= Config.DefaultKillsToWin then
      PostGame.InitState()
    end
  end
end

function AddToScoreboard(player)
  local playerId = player:GetAccountID()
  if not PlayerScores[playerId] then
    GetOrCreateScore(player)
    BroadcastScoreboard()
  else
    -- Returning / reconnecting player: send them the current full board
    Events.CallRemote("UpdateScoreboard", player, BuildScoreList())
  end
end

-- Sends a single player's updated data to all clients (incremental update)
function BroadcastScoreUpdate(playerId)
  local data = PlayerScores[playerId]
  if data then
    Events.BroadcastRemote("ScoreUpdate", data)
  end
end

function BuildScoreList()
  local list = {}
  for _, data in pairs(PlayerScores) do
    table.insert(list, data)
  end
  table.sort(list, function(a, b)
    if a.kills ~= b.kills then return a.kills > b.kills end
    return a.name < b.name
  end)
  return list
end

-- Sends the full sorted board to all clients (new player join / after clear)
function BroadcastScoreboard()
  Events.BroadcastRemote("UpdateScoreboard", BuildScoreList())
end

-- Picks up to Config.AwardsAmount random players, assigns unique random awards, stores in FinalAwards
function GenerateFinalAwards()
  local playerIds = {}
  for id in pairs(PlayerScores) do
    table.insert(playerIds, id)
  end
  -- Fisher-Yates shuffle
  for i = #playerIds, 2, -1 do
    local j = math.random(i)
    playerIds[i], playerIds[j] = playerIds[j], playerIds[i]
  end
  local numAwards = math.min(Config.AwardsAmount, #playerIds)
  local usedAwards = {}
  FinalAwards = {}
  for i = 1, numAwards do
    local pData = PlayerScores[playerIds[i]]
    local awardIdx
    repeat
      awardIdx = math.random(#Awards)
    until not usedAwards[awardIdx]
    usedAwards[awardIdx] = true
    table.insert(FinalAwards, { name = pData.name, icon = pData.icon, award = Awards[awardIdx] })
  end
end

-- Sends full scores + generated awards; pass a player for targeted send, nil to broadcast
function BroadcastFinalScores(player)
  local list = BuildScoreList()
  if player then
    Events.CallRemote("FinalScores", player, list, FinalAwards)
  else
    Events.BroadcastRemote("FinalScores", list, FinalAwards)
  end
end

function ClearScoreBoard()
  PlayerScores = {}
  PlayerCombos = {}
  PlayerComboTimers = {}
  FinalAwards = {}
  BroadcastScoreboard()
end