Events.SubscribeRemote("UpdateAmmo", function(ammo)
    UI:CallEvent("UpdateAmmo", ammo)
end)

Events.SubscribeRemote("PowerUpActivated", function(name, label, duration)
    UI:CallEvent("PowerUpActivated", name, label, duration)
end)

Events.SubscribeRemote("KillFeed", function(killer, victim)
    UI:CallEvent("KillFeed", killer, victim, Config.KillFeedDuration)
end)

Events.SubscribeRemote("UpdateCombo", function(combo)
    UI:CallEvent("UpdateCombo", combo)
end)

Events.SubscribeRemote("UpdateScoreboard", function(entries)
    UI:CallEvent("UpdateScoreboard", entries, Config.LeaderboardMaxTop, Config.LeaderboardSize)
end)

Events.SubscribeRemote("UpdateHealth", function(health, maxHealth)
    UI:CallEvent("UpdateHealth", health, maxHealth)
end)
