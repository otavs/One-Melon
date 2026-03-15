Package.Require("MelonGun.lua")
Package.Require("Bonker.lua")

function SpawnPlayer(player)
  local character = Character(Vector(1000, 0, 500), Rotator(0, 0, 0), "nanos-world::SK_Mannequin")
  character:SetFallDamageTaken(0)
  character:SetImpactDamageTaken(0)
  character:SetMaxHealth(1000)
  character:SetHealth(100000)
  character:SetSpeedMultiplier(Config.PlayerSpeed)
  character:SetJumpZVelocity(Config.PlayerJumpForce)
  character:SetRagdollOnHitEnabled(false)

  player:Possess(character)

  local melonGun = MelonGun(Vector(), Rotator())
  local bonker = Bonker(Vector(0, 0, -10000), Rotator())

  player:SetValue("MelonGun", melonGun)
  player:SetValue("Bonker", bonker)

  EquipWeapon(player, "MelonGun")

  Events.CallRemote("UpdateAmmo", player, melonGun:GetAmmoClip())

  character:Subscribe("Death", function(self, last_damage_taken, last_bone_damaged, damage_type_reason, hit_from_direction, instigator, causer)
    AddAmmo(instigator, 1)
    BroadcastKill(instigator, self)
  end)
end

function EquipWeapon(player, weaponName)
  local character = player:GetControlledCharacter()
  if not character or not character:IsValid() then
    return
  end
  local weapon = player:GetValue(weaponName)
  character:PickUp(weapon)
  player:SetValue("EquippedWeapon", weapon)
  ShowWeapon(weapon)
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
  weapon:SetLocation(Vector(0, 0, -10000))
  weapon:SetVisibility(false)
end

function ShowWeapon(weapon)
  weapon:SetVisibility(true)
end

function AddAmmo(player, amount)
  local melonGun = player:GetValue("MelonGun")
  if melonGun and melonGun:IsValid() then
    melonGun:AddAmmo(amount)
    Events.CallRemote("UpdateAmmo", player, melonGun:GetAmmoClip())
  end
end

function BroadcastKill(instigator, victimCharacter)
  local killerName = instigator and instigator:IsValid() and instigator:GetName() or "Unknown"
  local victimPlayer = victimCharacter:GetPlayer()
  local victimName = victimPlayer and victimPlayer:IsValid() and victimPlayer:GetName() or "Bot"
  Events.BroadcastRemote("KillFeed", killerName, victimName, Config.KillFeedDuration)
end

for _, player in pairs(Player.GetAll()) do
  SpawnPlayer(player)
end

Player.Subscribe("Spawn", SpawnPlayer)
