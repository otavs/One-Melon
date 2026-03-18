LogLevel = {
    GameChat = 1,
    Console = 2,
    None = 3
}

Config = {
    TEST = false,
    LogLevel = LogLevel.GameChat,
    ShowTriggers = true,
    EnableCommands = true,

    LobbyLocation = Vector(1000, 0, 500),
    GameLocation = Vector(1000, 0, 500),

    DefaultKillsToWin = 1,

    LobbyDuration = 3,
    PostGameDuration = 40,

    PlayerSpeed = 2,
    PowerUpSpeed = 4,
    PowerUpSpeedDuration = 10,
    
    PlayerJumpForce = 600,
    PowerUpJumpForce = 1000,
    PowerUpJumpDuration = 10,

    ComboDuration = 60,

    PlayerMaxHealth = 3,
    PowerUpHealth = 6,
    PowerUpHealthDuration = 10,

    KillFeedDuration = 5,

    LeaderboardMaxTop = 3,
    LeaderboardSize = 16,

    RespawnDelay = 2,
}