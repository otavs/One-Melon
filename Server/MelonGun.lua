MelonGun = Weapon.Inherit("VeggieGun")
Melon = Prop.Inherit("Melon")

function MelonGun:Constructor(location, rotation)
	self.Super:Constructor(location or Vector(), rotation or Rotator(), "nanos-world::SK_FlareGun")

	self:SetAmmoSettings(1, 0)
	self:SetDamage(0)
	self:SetRecoil(0)
	self:SetSightTransform(Vector(0, 0, -4), Rotator(0, 0, 0))
	self:SetLeftHandTransform(Vector(0, 1, -5), Rotator(0, 60, 100))
	self:SetRightHandOffset(Vector(-25, -5, 0))
	self:SetHandlingMode(HandlingMode.SingleHandedWeapon)
	self:SetCadence(0.6)
	self:SetSoundDry("nanos-world::A_Pistol_Dry")
	self:SetSoundZooming("nanos-world::A_AimZoom")
	self:SetSoundAim("nanos-world::A_Rattle")
	self:SetSoundFire("nanos-world::A_Whoosh")
	self:SetAnimationCharacterFire("nanos-world::A_Mannequin_Sight_Fire_Pistol")
	self:SetCrosshairMaterial("nanos-world::MI_Crosshair_Square")
	self:SetUsageSettings(true, false)
	self:SetGravityEnabled(false)
end

function MelonGun:OnFire(character)
	local control_rotation = character:GetControlRotation()
	local forward_vector = control_rotation:GetForwardVector()
	local capsule_size = character:GetCapsuleSize()
	local spawn_location = self:GetLocation() + Vector(0, 0, capsule_size.HalfHeight / 2) + forward_vector * 100

	local melon = Melon(spawn_location, Rotator.Random(), "nanos-world::SM_Fruit_Watermelon_01", CollisionType.Normal, true, GrabMode.Disabled, CCDMode.Disabled)
	melon:SetLifeSpan(5)
	melon:SetScale(2)
	melon:SetValue("DebrisLifeSpan", 2)
	-- melon:SetMassOverride(100000000)

	SetupBreakableProp(melon)

	melon:Subscribe("Hit", function(melon, intensity, normal_impulse, impact_location, velocity, other)
		print("Melon hit something")
		if other and other:IsValid() and other:IsA(Melon) then
			print("Melon hit melon")
			BreakProp(melon, intensity)
			BreakProp(other, intensity)
		elseif other and other:IsValid() and other:IsA(Character) and other:GetHealth() > 0 then
			print("Melon hit char")
			BreakProp(melon, intensity)
			other:ApplyDamage(1000, nil, nil, nil, character:GetPlayer(), nil)
			Events.BroadcastRemote("PlaySound", "bonk.mp3", impact_location)
		end
	end)

	melon:AddImpulse(forward_vector * 3000, true)
end

function MelonGun:AddAmmo(amount)
	self:SetAmmoClip(self:GetAmmoClip() + amount)
end

MelonGun.SubscribeRemote("Fire", MelonGun.OnFire)