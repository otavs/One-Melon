LogLevel = {
    GameChat = 1,
    Console = 2,
    None = 3
}

Config = {
    TEST = true,
    LogLevel = LogLevel.Console,
    ShowTriggers = true,
    EnableCommands = true,

    LobbyLocation = Vector(1000, 0, 500),
    GameLocation = Vector(1000, 0, 500),

    DefaultKillsToWin = 1,

    LobbyDuration = 60,
    PostGameDuration = 2,

    PlayerSpeed = 2,
    PowerUpSpeed = 4,
    PowerUpSpeedDuration = 15,
    
    PlayerJumpForce = 600,
    PowerUpJumpForce = 1000,
    PowerUpJumpDuration = 15,

    PowerUpBonkerDamage = 2,
    PowerUpBonkerScale = 6,
    PowerUpBonkerDuration = 20,

    PlayerMaxHealth = 3,
    PowerUpHealth = 6,
    PowerUpHealthDuration = 15,

    ComboDuration = 60,

    KillFeedDuration = 5,

    LeaderboardMaxTop = 3,
    LeaderboardSize = 16,

    AwardsAmount = 5,

    RespawnDelay = 3,

    PowerUpLifetime = 10 * 60,
    MysteriousPowerUpLifetime = 100,

}