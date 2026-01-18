Server.LoadPackage("default-weapons")

Package.Require("Breakable.lua")
Package.Require("Player.lua")
Package.Require("MelonGun.lua")

-- local melon = StaticMesh(Vector(0, 0, 200), Rotator(), "nanos-world::SM_Fruit_Watermelon_01")
-- melon:SetScale(3)

-- Character(Vector(0, 0, 1000), Rotator(0, 0, 0), "nanos-world::SK_Mannequin")

-- Timer.SetInterval(function()
--     print("Spawn melon")
--     local melon = Prop(Vector(0, 0, 0), Rotator(), "nanos-world::SM_Fruit_Watermelon_01", CollisionType.Normal)
    
-- end, 4000)