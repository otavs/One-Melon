local namesAmount = 22
local names = {}

Timer.SetInterval(function()
    local killerName = GetRandomName()
    local killerId = killerName
    if not PlayerScores[killerId] then
      PlayerScores[killerId] = { 
        id = killerId,
        name = killerName,
        icon = "https://upload.wikimedia.org/wikipedia/commons/8/89/Portrait_Placeholder.png",
        kills = 0 
    }
    end
    PlayerScores[killerId].kills = PlayerScores[killerId].kills + 1
    BroadcastScoreboard()
end, 1000)

Timer.SetInterval(function()
    -- now for the kill event
    local killerName = GetRandomName()
    local victimName = GetRandomName()
    Events.BroadcastRemote("KillFeed", killerName, victimName)
end, 1000)

function GetRandomName()
    return names[math.random(1, #names)]
end

function GenerateRandomName(minLength, maxLength)
    local length = math.random(minLength or 5, maxLength or 10)
    local name = ""
    for i = 1, length do
        name = name .. string.char(math.random(65, 90))
    end
    return name
end

for i = 1, namesAmount do
    table.insert(names, GenerateRandomName(5, 10))
end