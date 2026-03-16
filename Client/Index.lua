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

Events.SubscribeRemote("UpdateCombo", function(combo)
    UI:CallEvent("UpdateCombo", combo)
end)

Events.SubscribeRemote("UpdateScoreboard", function(entries, maxTop, size)
    UI:CallEvent("UpdateScoreboard", entries, maxTop, size)
end)

Events.SubscribeRemote("UpdateHealth", function(health, maxHealth)
    UI:CallEvent("UpdateHealth", health, maxHealth)
end)

UI:Subscribe("Ready", function()
    local localPlayer = Client.GetLocalPlayer()
    if localPlayer and localPlayer:IsValid() then
        UI:CallEvent("SetLocalPlayer", localPlayer:GetAccountID())
    end
end)

Client.SetBloodScreenEnabled(false)