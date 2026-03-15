Package.Require("Config.lua")
Package.Require("Utils.lua")
Package.Require("Log.lua")
Package.Require("Chat.lua")
Package.Require("Breakable.lua")
Package.Require("MelonGun.lua")
Package.Require("Bonker.lua")
Package.Require("Player.lua")
Package.Require("Controls.lua")
Package.Require("PowerUp.lua")

Hats = Assets.GetStaticMeshes("polygon-hats")
table.insert(Hats, false)

for i = 1, 20 do
    local character = Character(Vector(math.random(-2000, 2000), math.random(-2000, 2000), 500), Rotator(0, 0, 0), "nanos-world::SK_Mannequin")

    character:Subscribe("Death", function(self, last_damage_taken, last_bone_damaged, damage_type_reason, hit_from_direction, instigator, causer)
        AddAmmo(instigator, 1)
        BroadcastKill(instigator, self)
    end)

    character:SetMaterialColorParameter("Tint", RandomColor())

    local hat = Hats[math.random(#Hats)]

    if hat then 
        character:AddStaticMeshAttached(
            "head",
            "polygon-hats::" .. hat.key,
            "head",
            Vector(7, 3, 0),
            Rotator(-90, 0, 0)
        )
    end
end

PowerUp("Melon", Vector(0, 0, 150))
PowerUp("Jump", Vector(200, 0, 150))
PowerUp("Jump", Vector(400, 0, 150))
PowerUp("Speed", Vector(800, 0, 150))
PowerUp("Health", Vector(1200, 0, 150))

Server.Subscribe("Tick", function(delta)
    for _, powerUp in pairs(PowerUp.GetAll()) do
        powerUp:Tick(delta)
    end
end)
