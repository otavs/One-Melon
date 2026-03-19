Package.Require("Scores.lua")

Package.Require("MelonGun.lua")
Package.Require("Bonker.lua")

function CreateCharacter(player, location)
  local character = Character(location, Rotator(0, 0, 0), "nanos-world::SK_Mannequin")
  character:SetFallDamageTaken(0)
  character:SetImpactDamageTaken(0)
  character:SetMaxHealth(Config.PlayerMaxHealth)
  character:SetHealth(Config.PlayerMaxHealth)
  character:SetSpeedMultiplier(Config.PlayerSpeed)
  character:SetJumpZVelocity(Config.PlayerJumpForce)
  character:SetRagdollOnHitEnabled(false)
  character:SetDeathSound("nanos-world::A_EmptySound")

  player:Possess(character)

  player:SetValue("HatId", 0)
  player:SetValue("SkinId", 0)

  Events.CallRemote("UpdateHealth", player, character:GetHealth(), character:GetMaxHealth())

  character:Subscribe("HealthChange", function(self, old_health, new_health)
    Events.CallRemote("UpdateHealth", player, new_health, self:GetMaxHealth())
  end)

  character:Subscribe("Jump", function(self)
    if Game.State ~= State.Playing then return end
    local p = self:GetPlayer()
    if p and p:IsValid() then
      AddJump(p)
    end
  end)

  character:Subscribe("Death", function(self, last_damage_taken, last_bone_damaged, damage_type_reason, hit_from_direction, instigator, causer)
    if Game.State == State.Lobby then
      Lobby.OnCharacterDeath(self, last_damage_taken, last_bone_damaged, damage_type_reason, hit_from_direction, instigator, causer)
    elseif Game.State == State.Playing then
      Playing.OnCharacterDeath(self, last_damage_taken, last_bone_damaged, damage_type_reason, hit_from_direction, instigator, causer)
    elseif Game.State == State.PostGame then
      PostGame.OnCharacterDeath(self, last_damage_taken, last_bone_damaged, damage_type_reason, hit_from_direction, instigator, causer)
    end
  end)
end

Player.Subscribe("Spawn", function(player)
  if Game.State == State.Lobby then
    Lobby.OnPlayerJoin(player)
  elseif Game.State == State.Playing then
    Playing.OnPlayerJoin(player)
  elseif Game.State == State.PostGame then
    PostGame.OnPlayerJoin(player)
  end
end)

Player.Subscribe("Destroy", function(player)
  DestroyWeapons(player)
	local character = player:GetControlledCharacter()
	if character then
		character:Destroy()
	end
end)