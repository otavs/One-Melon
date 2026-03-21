Bonker = Melee.Inherit("Bonker")

function Bonker:Constructor(location, rotation)
	self.Super:Constructor(location or Vector(), rotation or Rotator(), "nanos-world::SM_BaseballBat_01", CollisionType.StaticOnly, true, HandlingMode.SingleHandedMelee, "")

	self:SetScale(1.6)
    self:AddAnimationCharacterUse("nanos-world::AM_Mannequin_Melee_Slash_Attack")
    self:SetDamageSettings(0.3, 0.5)
    self:SetCooldown(1.0)
    self:SetBaseDamage(1)
    self:SetGravityEnabled(true)
    self:SetPickable(false)
    -- local impactSound = SoundsDir .. "bonk.mp3"
    local impactSound = "nanos-world::A_EmptySound"
    self:SetImpactSound(SurfaceType.Flesh, impactSound, 10, 1)
end
