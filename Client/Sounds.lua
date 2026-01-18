local SoundsDir = "package://" .. Package.GetName() .. "/Client/Sounds/"

Events.SubscribeRemote("PlaySound", function(sound, location)
    print(sound)
    print(location)
    Sound(
        location, -- Location (if a 3D sound)
        SoundsDir .. sound, -- Asset Path
        false, -- Is 2D Sound
        true, -- Auto Destroy (if to destroy after finished playing)
        SoundType.SFX,
        10, -- Volume
        1 -- Pitch
    )
end)
