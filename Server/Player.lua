Package.Require("MelonGun.lua")
Package.Require("Bonker.lua")

function SpawnPlayer(player)
  local character = Character(Vector(1000, 0, 500), Rotator(0, 0, 0), "nanos-world::SK_Mannequin")
  character:SetFallDamageTaken(0)
  character:SetImpactDamageTaken(0)
  character:SetMaxHealth(Config.PlayerMaxHealth)
  character:SetHealth(Config.PlayerMaxHealth)
  character:SetSpeedMultiplier(Config.PlayerSpeed)
  character:SetJumpZVelocity(Config.PlayerJumpForce)
  character:SetRagdollOnHitEnabled(false)

  player:Possess(character)

  local melonGun = CreateWeapon("MelonGun")
  local bonker = CreateWeapon("Bonker")

  player:SetValue("MelonGun", melonGun)
  player:SetValue("Bonker", bonker)

  HideWeapon(player:GetValue("MelonGun"))
  HideWeapon(player:GetValue("Bonker"))
  EquipWeapon(player, "MelonGun")

  Events.CallRemote("UpdateAmmo", player, melonGun:GetAmmoClip())
  Events.CallRemote("UpdateHealth", player, character:GetHealth(), character:GetMaxHealth())

  character:Subscribe("HealthChange", function(self, old_health, new_health)
    Events.CallRemote("UpdateHealth", player, new_health, self:GetMaxHealth())
  end)

  character:Subscribe("Death", function(self, last_damage_taken, last_bone_damaged, damage_type_reason, hit_from_direction, instigator, causer)
    AddAmmo(instigator, 1)
    BroadcastKill(instigator, self)
    Events.CallRemote("UpdateHealth", player, 0, character:GetMaxHealth())
    Timer.SetTimeout(function()
      Respawn(player)
    end, Config.RespawnDelay * 1000)
  end)
end

function Respawn(player)
  if player:IsValid() then
    local character = player:GetControlledCharacter()
    character:Respawn(Vector(1000, 0, 500), Rotator(0, 0, 0))
    HideWeapon(player:GetValue("MelonGun"))
    HideWeapon(player:GetValue("Bonker"))
    EquipWeapon(player, "MelonGun")
    SetAmmo(player, 1)
  end
end

function EquipWeapon(player, weaponName)
  local character = player:GetControlledCharacter()
  if not character or not character:IsValid() then
    return
  end
  local weapon = player:GetValue(weaponName)
  if not weapon or not weapon:IsValid() then
    weapon = CreateWeapon(weaponName)
    player:SetValue(weaponName, weapon)
  end
  character:PickUp(weapon)
  player:SetValue("EquippedWeapon", weapon)
  ShowWeapon(weapon)
end

function CreateWeapon(weaponName)
  if weaponName == "MelonGun" then
    return MelonGun(Vector(), Rotator())
  elseif weaponName == "Bonker" then
    return Bonker(Vector(), Rotator())
  end
end

function SwitchWeapon(player)
  local equippedWeapon = player:GetValue("EquippedWeapon")
  if equippedWeapon:IsA(MelonGun) then
    EquipWeapon(player, "Bonker")
  else
    EquipWeapon(player, "MelonGun")
  end
  HideWeapon(equippedWeapon)
end

function HideWeapon(weapon)
  weapon:SetGravityEnabled(false)
  weapon:SetVisibility(false)
end

function ShowWeapon(weapon)
  weapon:SetGravityEnabled(true)
  weapon:SetVisibility(true)
end

function AddAmmo(player, amount)
  local melonGun = player:GetValue("MelonGun")
  if melonGun and melonGun:IsValid() then
    melonGun:AddAmmo(amount)
    Events.CallRemote("UpdateAmmo", player, melonGun:GetAmmoClip())
  end
end

function SetAmmo(player, amount)
  local melonGun = player:GetValue("MelonGun")
  if melonGun and melonGun:IsValid() then
    melonGun:SetAmmoSettings(amount, 0)
    Events.CallRemote("UpdateAmmo", player, melonGun:GetAmmoClip())
  end
end

PlayerScores = {}
PlayerCombos = {}
PlayerComboTimers = {}
AAA = 0

function BroadcastKill(instigator, victimCharacter)
  local killerPlayer = instigator and instigator:IsValid() and instigator or nil
  local killerName = killerPlayer and killerPlayer:GetName() or "Unknown"
  -- concat killername with random string
  killerName = killerName .. " " .. AAA
  AAA=AAA+1
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
  Events.BroadcastRemote("UpdateScoreboard", list, Config.LeaderboardMaxTop)
end

for _, player in pairs(Player.GetAll()) do
  SpawnPlayer(player)
end

Player.Subscribe("Spawn", function(player)
  SpawnPlayer(player)
  -- Send current scoreboard state to the new player
  local list = {}
  for _, data in pairs(PlayerScores) do
    table.insert(list, data)
  end
  table.sort(list, function(a, b) return a.kills > b.kills end)
  Events.CallRemote("UpdateScoreboard", player, list, Config.LeaderboardMaxTop)
end)
