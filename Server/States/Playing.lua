Playing = {}

function Playing.InitState()
    Game.State = State.Playing
    for _, player in pairs(Player.GetAll()) do
        RespawnInGame(player)
        SetGameSettings(player)
        CreateWeapons(player)
        EquipWeapon(player, "MelonGun")
        EnterPlayingStateUI(player)
    end
end

function Playing.OnPlayerJoin(player)
    CreateCharacter(player, Config.LobbyLocation)
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
    else 
        if causer and causer:IsA(Melon) then
            instigator = causer:GetValue("player")
        end
        AddAmmo(instigator, 1)
        AddCombo(instigator)
        BroadcastKill(instigator, character, GetWeaponType(causer))
    end
    
    Events.CallRemote("UpdateHealth", character:GetPlayer(), 0, character:GetMaxHealth())
    Timer.SetTimeout(function()
        if character and character:IsValid() then
            RespawnInGame(character:GetPlayer())
        end
    end, Config.RespawnDelay * 1000)
end

function RespawnInGame(player)
    local character = player:GetControlledCharacter()
    if character and character:IsValid() then
        character:Respawn(Config.GameLocation)
        HideWeapon(player:GetValue("MelonGun"))
        HideWeapon(player:GetValue("Bonker"))
        EquipWeapon(player, "MelonGun")
        SetAmmo(player, 1)
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