PowerUp = StaticMesh.Inherit("PowerUp")

PowerUps = {
    Melon = {
        image = "watermelon.png",
        fireworkColor = Color.GREEN,
        playerParticle = nil,
        sound = {
            file = "powerup-melon.mp3",
            volume = 1,
        },
        handler = function(character)
            local player = character:GetPlayer()
            AddAmmo(player, 1)
        end
    },
    Jump = {
        image = "jump.png",
        fireworkColor = Color.BLUE,
        playerParticle = {
            asset = "nanos-world::P_RocketExhaust_Blue",
            rotation = Rotator(0, 180, 0),
            scale = 0.3,
        },
        sound = {
            file = "powerup-jump.mp3",
            volume = 1,
        },
        handler = function(character)
            local player = character:GetPlayer()
            character:SetJumpZVelocity(Config.PowerUpJumpForce)
            ActivatePowerUp(player, "Jump", "Jump Boost", Config.PowerUpJumpDuration, function()
                character:SetJumpZVelocity(Config.PlayerJumpForce)
            end)
        end
    },
    Speed = {
        image = "speed.png",
        fireworkColor = Color.YELLOW,
        playerParticle = {
            asset = "nanos-world::P_RocketExhaust_Yellow",
            rotation = Rotator(0, -90, 0),
            scale = 0.2,
        },
        sound = {
            file = "powerup-speed.mp3",
            volume = 3,
        },
        handler = function(character)
            local player = character:GetPlayer()
            character:SetSpeedMultiplier(Config.PowerUpSpeed)
            ActivatePowerUp(player, "Speed", "Speed Boost", Config.PowerUpSpeedDuration, function()
                character:SetSpeedMultiplier(Config.PlayerSpeed)
            end)
        end
    },
    Health = {
        image = "health.png",
        fireworkColor = Color.RED,
        playerParticle = {
            asset = "nanos-world::P_RocketExhaust_Red",
            rotation = Rotator(0, -135, 0),
            scale = 0.2,
        },
        sound = {
            file = "powerup-health.mp3",
            volume = 1,
        },
        handler = function(character)
           local player = character:GetPlayer()
            character:SetMaxHealth(Config.PowerUpHealth)
            character:SetHealth(Config.PowerUpHealth)
            ActivatePowerUp(player, "Health", "Health Boost", Config.PowerUpHealthDuration, function()
                character:SetMaxHealth(Config.PlayerMaxHealth)
                if character:GetHealth() > Config.PlayerMaxHealth then
                    character:SetHealth(Config.PlayerMaxHealth)
                end
            end)
        end
    },
    Bonker = {
        image = "bonker.png",
        fireworkColor = Color.WHITE,
        playerParticle = nil,
        sound = {
            file = "powerup-bonker.mp3",
            volume = 1,
        },
        handler = function(character)
            local player = character:GetPlayer()
            local bonker = player:GetValue("Bonker")
            if not bonker or not bonker:IsValid() then
                bonker = CreateWeapon("Bonker")
                player:SetValue("Bonker", bonker)
            end
            bonker:SetScale(Config.PowerUpBonkerScale)
            bonker:SetBaseDamage(Config.PowerUpBonkerDamage)
            EquipWeapon(player, "Bonker")
            ActivatePowerUp(player, "Bonker", "Mega Bonker", Config.PowerUpBonkerDuration, function()
                bonker = player:GetValue("Bonker")
                if bonker and bonker:IsValid() then
                    bonker:SetScale(1.6)
                    bonker:SetBaseDamage(1)
                end
            end)
        end
    },
    Mysterious = {
        image = "mysterious.png",
        fireworkColor = Color.BLACK,
        playerParticle = nil,
        sound = nil,
        handler = function(character)
            local location = character:GetLocation()

            local particle = Particle(
                location,
                Rotator(0, 0, 0),
                "nanos-world::P_Explosion",
                true,
                true
            )
            particle:SetScale(50)

            for _ = 1, 10 do
                local grenade = Grenade(location, Rotator(), "nanos-world::SM_None", "nanos-world::P_Grenade_Special", "nanos-world::A_Explosion_Large", CollisionType.StaticOnly, false)
                grenade:SetScale(100)
                grenade:SetDamage(1000, 1000, 2000, 2000, 1)
                grenade:Explode()
            end
        end
    }
}

function ActivatePowerUp(player, type, name, duration, callback)
    local timerKey = "PU_Timer_" .. type

    Events.CallRemote("PowerUpActivated", player, type, name, duration)

    local oldTimer = player:GetValue(timerKey)
    if oldTimer and Timer.IsValid(oldTimer) then
        Timer.ClearInterval(oldTimer)
    end

    AddPowerUpParticles(player, type)

    local timeLeft = duration
    Events.CallRemote("PowerUpUpdate", player, type, timeLeft)

    local timer = nil
    timer = Timer.SetInterval(function()
        if not player or not player:IsValid() then
            if timer and Timer.IsValid(timer) then
                Timer.ClearInterval(timer)
            end
            return
        end

        timeLeft = timeLeft - 1
        Events.CallRemote("PowerUpUpdate", player, type, math.max(timeLeft, 0))

        if timeLeft <= 0 then
            callback()
            RemovePowerUpParticles(player, type)
            if timer and Timer.IsValid(timer) then
                Timer.ClearInterval(timer)
            end
            player:SetValue(timerKey, nil)
            return
        end
    end, 1000)

    player:SetValue(timerKey, timer)
end

function PowerUp:Constructor(type, location)
	self.Super:Constructor(location, Rotator(0, 0, 0), "nanos-world::SM_Cube", CollisionType.NoCollision)
    self:SetScale(0.5)
    self:SetMaterialTextureParameter("Texture", "package://" .. Package.GetName() .. "/Client/Textures/" .. PowerUps[type].image)
    self.spin = 0
    self.spinSpeed = 70

    local lifetime = Config.PowerUpLifetime
    if type == "Mysterious" then
        lifetime = Config.MysteriousPowerUpLifetime
    end
    local lifetimeTimer = Timer.SetTimeout(function()
        if self:IsValid() then
            self:Destroy()
        end
    end, lifetime * 1000)
    Timer.Bind(lifetimeTimer, self)

    local trigger = Trigger(location, Rotator(), Vector(100), TriggerType.Sphere, false, Color(1, 0, 0), {"Character"})

    trigger:Subscribe("BeginOverlap", function(trigger, character)
        if character and character:IsValid() and character:IsDead() then
            return
        end
        local player = character:GetPlayer()
        if not player or not player:IsValid() then
            return
        end
        self:Destroy()
        PowerUps[type].handler(character)
        AddPowerUp(player)

        if PowerUps[type].sound then
            PlaySoundP(player, PowerUps[type].sound.file, location, PowerUps[type].sound.volume, 1)
        end

        SpawnFirework(location, PowerUps[type].fireworkColor)
        SpawnFirework(location, PowerUps[type].fireworkColor)
    end)
    trigger:AttachTo(self, AttachmentRule.SnapToTarget, nil, 0, false)
end

function SpawnFirework(location, color)
    local firework = Particle(
        location,
        Rotator(),
        "ts-fireworks::PS_TS_Fireworks_Burst_Palm",
        false,
        true
    )

    firework:SetParameterColor("BlastColor", color)
    firework:SetParameterColor("BurstColor", color)
    firework:SetParameterColor("SparkleColor", color)
    firework:SetParameterColor("FlareColor", color)
    firework:SetParameterColor("TailColor", color)

    firework:SetParameterBool("BlastSmoke", false)
    firework:SetParameterBool("TrailSmoke", false)

    firework:SetParameterFloat("BurstMulti", 2.0)
    firework:SetParameterFloat("SparkleMulti", 2.0)

    firework:SetScale(0.3)

    Timer.SetTimeout(function()
        if firework and firework:IsValid() then
            firework:Destroy()
        end
    end, 15000)
end

function PowerUp:Tick(deltaTime)
    if #Player.GetAll() == 0 then
        return
    end
    self.spin = (self.spin + self.spinSpeed * deltaTime) % 360
    local portalRot = Rotator(0, -self.spin, 0)
    self:RotateTo(portalRot, 1)
end

function TickAllPowerUps(deltaTime)
    for _, powerUp in pairs(PowerUp.GetAll()) do
        powerUp:Tick(deltaTime)
    end
end

function DestroyAllPowerUps()
    for _, powerUp in pairs(PowerUp.GetAll()) do
        powerUp:Destroy()
    end
end

function AddPowerUpParticles(player, type)
    if PowerUps[type].playerParticle == nil then
        return
    end

    local existingParticle = player:GetValue("PU_Particle_" .. type)
    if existingParticle and existingParticle:IsValid() then
        return
    end

    local character = player:GetControlledCharacter()
    if not character or not character:IsValid() then
        return
    end

    local particle = Particle(
        Vector(),
        Rotator(),
        PowerUps[type].playerParticle.asset,
        false,
        true
    )

    particle:AttachTo(character, AttachmentRule.SnapToTarget, "pelvis", 0)
    particle:SetRelativeRotation(PowerUps[type].playerParticle.rotation)
    particle:SetScale(PowerUps[type].playerParticle.scale)
    particle:SetRelativeLocation(Vector(0, 0, 0))

    player:SetValue("PU_Particle_" .. type, particle)
end

function RemovePowerUpParticles(player, type)
    local key = "PU_Particle_" .. type
    local particle = player:GetValue(key)

    if particle and particle:IsValid() then
        particle:Destroy()
    end
end