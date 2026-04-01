Playing = {}

function Playing.InitState()
    Game.State = State.Playing
    DestroyAllPowerUps()
    for _, player in pairs(Player.GetAll()) do
        FreezePlayer(player)
        SetGameSettings(player)
        RespawnInGame(player)
        CreateWeapons(player)
        EquipWeapon(player, "MelonGun")
        EnterPlayingStateUI(player)
        AddToScoreboard(player)
        RemoveVoidedStatus(player)
    end
    Play2dSound("yay.mp3", 2, 1)
    Timer.SetTimeout(function()
        UnFreezeAllPlayers()
    end, 1200)
end

function Playing.OnPlayerJoin(player)
    CreateCharacter(player, Config.GameLocation)
    SetGameSettings(player)
    CreateWeapons(player)
    EquipWeapon(player, "MelonGun")
    ShowHelpUI(player)
    EnterPlayingStateUI(player)
    AddToScoreboard(player)
end

function Playing.OnCharacterDeath(character, last_damage_taken, last_bone_damaged, damage_type_reason, hit_from_direction, instigator, causer)
    AddDeath(character:GetPlayer())
    if damage_type_reason == DamageType.Explosion then
        Events.BroadcastRemote("KillFeed", "", character:GetPlayer():GetName(), "Explosion")
    elseif instigator then
        if causer and causer:IsA(Melon) then
            instigator = causer:GetValue("player")
        end
        AddAmmo(instigator, 1)
        AddCombo(instigator)
        BroadcastKill(instigator, character, GetWeaponType(causer))
    else
        Events.BroadcastRemote("KillFeed", "", character:GetPlayer():GetName(), "Explosion")
    end
    
    Events.CallRemote("UpdateHealth", character:GetPlayer(), 0, character:GetMaxHealth())
    Timer.SetTimeout(function()
        if character and character:IsValid() then
            RespawnInGame(character:GetPlayer())
        end
    end, Config.RespawnDelay * 1000)
end

function Playing.HandleVoidPlayers(playersOnVoid)
    for _, player in pairs(playersOnVoid) do
        local character = player:GetControlledCharacter()
        if character and character:IsValid() and not character:IsDead() then
            character:ApplyDamage(1000, nil, nil, nil, nil, nil)

            -- not works
            -- character:AddImpulse(Vector(2000000, 2000000, 2000000), true)

            local location = character:GetLocation()

            local particle = Particle(
                location,
                Rotator(0, 0, 0),
                "nanos-world::P_Explosion",
                true,
                true
            )
            particle:SetScale(50)

            Play2dSoundP(player, "nanos-world::A_Explosion_Large", 2, 1)

            character:SetValue("voided", true)
        end
    end
end

function RespawnInGame(player)
    local character = player:GetControlledCharacter()
    if character and character:IsValid() then
        character:Respawn(Vector(math.random(-5000, 5000), math.random(-5000, 5000), 500))

        HideWeapon(player:GetValue("MelonGun"))
        HideWeapon(player:GetValue("Bonker"))
        EquipWeapon(player, "MelonGun")
        if not character:GetValue("voided") then
            SetAmmo(player, 1)
        else
            SetAmmo(player, math.min(1, GetCurrentAmmo(character)))
        end
        character:SetValue("voided", nil)
        ClearCombo(player)
    end
end

function SetGameSettings(player)
    local character = player:GetControlledCharacter()
    if character and character:IsValid() then
        character:SetMaxHealth(Config.PlayerMaxHealth)
        character:SetHealth(Config.PlayerMaxHealth)
        character:SetSpeedMultiplier(Config.PlayerSpeed)
        character:SetJumpZVelocity(Config.PlayerJumpForce)
    end
end

function EnterPlayingStateUI(player)
    Events.CallRemote("EnterPlayingStateUI", player)
end

local PossiblePowerUps = {"Melon", "Jump", "Speed", "Health", "Bonker", "Mysterious"}
local PowerUpSpawnTimer = 0

function Playing.SpawnPowerUps()
    PowerUpSpawnTimer = PowerUpSpawnTimer + 1
    local interval = GetPowerUpSpawnInterval()
    if PowerUpSpawnTimer < interval then
        return
    end
    PowerUpSpawnTimer = 0
    local amount = 1
    for _ = 1, amount do
        local randomType = PossiblePowerUps[math.random(1, #PossiblePowerUps)]
        PowerUp(randomType, Vector(math.random(-2000, 2000), math.random(-2000, 2000), 155))
    end
end

function GetPowerUpSpawnInterval()
    local n = #Player.GetAll()
    local t_min = 1
    local t_max = 8
    local k = 0.1
    return math.ceil(t_min + (t_max - t_min) * math.exp(-k * n))
end