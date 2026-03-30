SoundsDir = "package://" .. Package.GetName() .. "/Client/Sounds/"

function PlaySound(sound, location, volume, pitch)
    if sound:sub(1, 13) ~= "nanos-world::" then
        sound = SoundsDir .. sound
    end
    Sound(
        location, -- Location (if a 3D sound)
        sound, -- Asset Path
        false, -- Is 2D Sound
        true, -- Auto Destroy (if to destroy after finished playing)
        SoundType.SFX,
        volume or 10, -- Volume
        pitch or 1 -- Pitch
    )
end

function Play2dSound(sound, volume, pitch)
    if sound:sub(1, 13) ~= "nanos-world::" then
        print(sound:sub(1, 13))
        sound = SoundsDir .. sound
    end
    Sound(
        Vector(), -- Location (if a 3D sound)
        sound, -- Asset Path
        true, -- Is 2D Sound
        true, -- Auto Destroy (if to destroy after finished playing)
        SoundType.SFX,
        volume or 10, -- Volume
        pitch or 1 -- Pitch
    )
end

Events.SubscribeRemote("PlaySound", PlaySound)
Events.SubscribeRemote("Play2dSound", Play2dSound)