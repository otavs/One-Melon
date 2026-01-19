Package.Require("MelonGun.lua")
Package.Require("Bonker.lua")

function SpawnPlayer(player)
  local character = Character(Vector(1000, 0, 500), Rotator(0, 0, 0), "nanos-world::SK_Mannequin")
  character:SetFallDamageTaken(0)
  character:SetImpactDamageTaken(0)
  character:SetMaxHealth(1000)
  character:SetHealth(100000)
  character:SetSpeedMultiplier(2)
  character:SetJumpZVelocity(600)
  character:SetRagdollOnHitEnabled(false)

  player:Possess(character)

  local melonGun = MelonGun(Vector(), Rotator())
  local bonker = Bonker(Vector(0, 0, -10000), Rotator())

  player:SetValue("MelonGun", melonGun)
  player:SetValue("Bonker", bonker)

  EquipWeapon(player, "MelonGun")
  
end

function EquipWeapon(player, weaponName)
  local character = player:GetControlledCharacter()
  if not character or not character:IsValid() then
    return
  end
  local weapon = player:GetValue(weaponName)
  character:PickUp(weapon)
  player:SetValue("EquippedWeapon", weapon)
end

function SwitchWeapon(player)
  local equippedWeapon = player:GetValue("EquippedWeapon")
  if equippedWeapon:IsA(MelonGun) then
    EquipWeapon(player, "Bonker")
  else
    EquipWeapon(player, "MelonGun")
  end
  equippedWeapon:SetLocation(Vector(0, 0, -10000))
end

for _, player in pairs(Player.GetAll()) do
  SpawnPlayer(player)
end

Player.Subscribe("Spawn", SpawnPlayer)
