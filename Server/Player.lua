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
  character:SetPunchDamage(1)

  player:Possess(character)

  DefineHat(player)
  DefineSkin(player)

  Events.CallRemote("UpdateHealth", player, character:GetHealth(), character:GetMaxHealth())

  character:Subscribe("HealthChange", function(self, old_health, new_health)
    Events.CallRemote("UpdateHealth", player, new_health, self:GetMaxHealth())
  end)

  character:Subscribe("Death", function(self, last_damage_taken, last_bone_damaged, damage_type_reason, hit_from_direction, instigator, causer)
    if causer and (causer:IsA(Melon) or causer:IsA(Bonker)) then
      PlaySound("bonk.mp3", self:GetLocation())
    end
    if Game.State == State.Lobby then
      Lobby.OnCharacterDeath(self, last_damage_taken, last_bone_damaged, damage_type_reason, hit_from_direction, instigator, causer)
    elseif Game.State == State.Playing then
      Playing.OnCharacterDeath(self, last_damage_taken, last_bone_damaged, damage_type_reason, hit_from_direction, instigator, causer)
    elseif Game.State == State.PostGame then
      PostGame.OnCharacterDeath(self, last_damage_taken, last_bone_damaged, damage_type_reason, hit_from_direction, instigator, causer)
    end
  end)

  character:Subscribe("TakeDamage", function(self, damage, bone, type, from_direction, instigator, causer)
    if type == DamageType.Punch then
      local impulse = from_direction:GetSafeNormal() * 1500 + Vector(0, 0, 400)
      self:AddImpulse(impulse, true)
      return false
    end
    if causer and causer:IsA(Bonker) then
      local impulse = from_direction:GetSafeNormal() * 300 + Vector(0, 0, 200)
      self:AddImpulse(impulse, true)
      if self:GetHealth() - damage > 0 then
        PlaySound("mini-bonk.mp3", self:GetLocation(), 1.5, 1)
      end 
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