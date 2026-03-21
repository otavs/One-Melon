function PlaySound(file, location, volume, pitch)
    Events.BroadcastRemote("PlaySound", file, location, volume, pitch)
end
function PlaySoundP(player, file, location, volume, pitch)
    Events.CallRemote("PlaySound", player, file, location, volume, pitch)
end

function Play2dSound(file, volume, pitch)
    Events.BroadcastRemote("Play2dSound", file, volume, pitch)
end
function Play2dSoundP(player, file, volume, pitch)
    Events.CallRemote("Play2dSound", player, file, volume, pitch)
end