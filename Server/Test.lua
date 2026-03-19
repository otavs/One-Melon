if not Config.TEST and not Game.State == State.Playing then
    return
end

local botAmount = 30

for i = 1, botAmount do
    local character = Character(Vector(math.random(-2000, 2000), math.random(-2000, 2000), 500), Rotator(0, 0, 0), "nanos-world::SK_Mannequin")

    character:Subscribe("Death", function(self, last_damage_taken, last_bone_damaged, damage_type_reason, hit_from_direction, instigator, causer)
        if damage_type_reason == DamageType.Explosion then
            Events.BroadcastRemote("KillFeed", "", "Bot", "Explosion")    
        else 
            if not instigator and causer and causer:IsA(Melon) then
                instigator = causer:GetValue("player")
            end
            AddAmmo(instigator, 1)
            AddCombo(instigator)
            BroadcastKill(instigator, self, GetWeaponType(causer))
        end
    end)

    character:SetMaterialColorParameter("Tint", RandomColor())
    character:SetMaxHealth(3)
    character:SetHealth(3)
    character:SetDeathSound("nanos-world::A_EmptySound")
end

PowerUp("Melon", Vector(0, 0, 150))
PowerUp("Jump", Vector(200, 0, 150))
PowerUp("Jump", Vector(400, 0, 150))
PowerUp("Speed", Vector(800, 0, 150))
PowerUp("Health", Vector(1200, 0, 150))
PowerUp("Bonker", Vector(1600, 0, 150))
PowerUp("Mysterious", Vector(2000, 0, 150))

-- spawn 100 random powerups
-- for i = 1, 200 do
--     local powerUpTypes = {"Melon", "Jump", "Speed", "Health", "Bonker"}
--     local randomType = powerUpTypes[math.random(1, #powerUpTypes)]
--     PowerUp(randomType, Vector(math.random(-2000, 2000), math.random(-2000, 2000), 150))
-- end

Timer.SetInterval(function()
    if Game.State ~= State.Playing then
        return
    end
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
end, 500)

Timer.SetInterval(function()
    if Game.State ~= State.Playing then
        return
    end
    -- now for the kill event
    local killerName = GetRandomName()
    local victimName = GetRandomName()
    Events.BroadcastRemote("KillFeed", killerName, victimName)
end, 1000)

local namesAmount = 22
local names = {}

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

-- Timer.SetInterval(function()
--     print("Random message " .. math.random(1, 100))
-- end, 500)