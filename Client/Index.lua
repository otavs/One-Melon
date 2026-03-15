Package.Require("Breakable.lua")
Package.Require("Sounds.lua")

UI = WebUI("Main HUD", "file://UI/index.html")

Input.Register("SwitchWeapon", "Q")
Input.Bind("SwitchWeapon", InputEvent.Pressed, function()
	Events.CallRemote("SwitchWeapon")
end)

Events.SubscribeRemote("UpdateAmmo", function(ammo)
    UI:CallEvent("UpdateAmmo", ammo)
end)

Events.SubscribeRemote("PowerUpActivated", function(name, label, duration)
    UI:CallEvent("PowerUpActivated", name, label, duration)
end)

Events.SubscribeRemote("KillFeed", function(killer, victim, duration)
    UI:CallEvent("KillFeed", killer, victim, duration)
end)
