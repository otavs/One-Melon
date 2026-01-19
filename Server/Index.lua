Package.Require("Breakable.lua")
Package.Require("MelonGun.lua")
Package.Require("Bonker.lua")
Package.Require("Player.lua")
Package.Require("Controls.lua")

for i = 1, 40 do
    local character = Character(Vector(math.random(-2000, 2000), math.random(-2000, 2000), 500), Rotator(0, 0, 0), "nanos-world::SK_Mannequin")

    character:Subscribe("Death", function(self, last_damage_taken, last_bone_damaged, damage_type_reason, hit_from_direction, instigator, causer)
        AddAmmo(instigator, 1)
    end)
end