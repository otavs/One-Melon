Package.Require("Breakable.lua")
Package.Require("Sounds.lua")

Input.Register("SwitchWeapon", "Q")
Input.Bind("SwitchWeapon", InputEvent.Pressed, function()
	Events.CallRemote("SwitchWeapon")
end)

local main_hud = WebUI("Main HUD", "file://UI/index.html")