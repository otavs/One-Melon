Bonker = Melee.Inherit("Bonker")

function Bonker:Constructor(location, rotation)
	self.Super:Constructor(location or Vector(), rotation or Rotator(), "nanos-world::SM_BaseballBat_01", CollisionType.Normal, true, HandlingMode.SingleHandedMelee, "")

	self:SetScale(1.5)
    self:AddAnimationCharacterUse("nanos-world::AM_Mannequin_Melee_Slash_Attack")
    self:SetDamageSettings(0.3, 0.5)
    self:SetCooldown(1.0)
    self:SetBaseDamage(40)
    self:SetGravityEnabled(false)
end
