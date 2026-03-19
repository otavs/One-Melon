Package.Require("Config.lua")
Package.Require("Breakable.lua")
Package.Require("Sounds.lua")
Package.Require("Events.lua")
Package.Require("Input.lua")

UI = WebUI("Main HUD", "file://UI/index.html")

Viewport.SetBloodScreenEnabled(false)

Chat.SetConfiguration(
    Vector2D(-25, 200), --screen_location
    Vector2D(500, 250), --size
    Vector2D(1, 0.5), --anchors_min
    Vector2D(1, 0.5), --anchors_max
    Vector2D(1, 0.5), --alignment
    true, --justify
    true --show_scrollbar
)

UI:Subscribe("EnableMouse", function()
    Input.SetMouseEnabled(true)
end)

UI:Subscribe("DisableMouse", function()
    Input.SetMouseEnabled(false)
end)

UI:Subscribe("Ready", function()
    local localPlayer = Client.GetLocalPlayer()
    if localPlayer and localPlayer:IsValid() then
        UI:CallEvent("SetLocalPlayer", localPlayer:GetAccountID())
    end
end)

Events.SubscribeRemote("SpawnSound", function(location, sound_asset, is_2D, volume, pitch)
	Sound(location, sound_asset, is_2D, true, SoundType.SFX, volume or 1, pitch or 1)
end)