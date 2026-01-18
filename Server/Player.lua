Package.Require("MelonGun.lua")

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

  local veggie_gun = MelonGun(Vector(1000, 0, 5000))
  character:PickUp(veggie_gun)

end

for _, player in pairs(Player.GetAll()) do
  SpawnPlayer(player)
end

Player.Subscribe("Spawn", SpawnPlayer)


-- spawn 40 random characters
for i = 1, 40 do
    Character(Vector(math.random(-2000, 2000), math.random(-2000, 2000), 500), Rotator(0, 0, 0), "nanos-world::SK_Mannequin")
end