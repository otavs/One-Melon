MusicsDir = "package://" .. Package.GetName() .. "/Client/Musics/"

Musics = {
    "Monkeys-Spinning-Monkeys.mp3",
}

function StartSoundtrack()
    local soundtrack = Sound(
        Vector(), --location
        MusicsDir .. Musics[1], --asset
        true, --is_2D_sound
        false, --auto_destroy
        SoundType.Music, --sound_type
        0.6, --volume
        1, --pitch
        400, --inner_radius
        3600, --falloff_distance
        AttenuationFunction.Linear, --attenuation_function
        false, --keep_playing_when_silent
        SoundLoopMode.Forever, --loop_mode
        true --auto_play
    )
end

StartSoundtrack()