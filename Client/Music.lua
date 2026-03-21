MusicsDir = "package://" .. Package.GetName() .. "/Client/Musics/"

Musics = {
    "Monkeys-Spinning-Monkeys.mp3",
}

function StartSoundtrack()
    local soundtrack = Sound(
        Vector(),
        MusicsDir .. Musics[1],
        true,
        false,
        SoundType.Music,
        1,
        1,
        400,
        3600,
        AttenuationFunction.Linear,
        false,
        SoundLoopMode.Forever,
        true
    )
end

StartSoundtrack()