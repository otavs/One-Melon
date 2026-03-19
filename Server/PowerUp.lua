PowerUp = StaticMesh.Inherit("PowerUp")

PowerUps = {
    Melon = {
        image = "watermelon.png",
        handler = function(character)
            local player = character:GetPlayer()
            AddAmmo(player, 1)
        end
    },
    Jump = {
        image = "jump.png",
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
        handler = function(character)
            local player = character:GetPlayer()
            local bonker = player:GetValue("Bonker")
            if not bonker or not bonker:IsValid() then
                bonker = CreateWeapon("Bonker")
                player:SetValue("Bonker", bonker)
            end
            bonker:SetScale(Config.PowerUpBonkerScale)
            bonker:SetBaseDamage(Config.PowerUpBonkerDamage)
            ActivatePowerUp(player, "Bonker", "Giant Bonker", Config.PowerUpBonkerDuration, function()
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

            --loop 10 times
            for i = 1, 10 do
                local grenade = Grenade(location, Rotator(), "nanos-world::SM_None", "nanos-world::P_Grenade_Special", "nanos-world::A_Explosion_Large", CollisionType.StaticOnly, false)
                grenade:SetScale(100)
                grenade:SetDamage(1000, 1000, 2000, 2000, 1)
                grenade:Explode()
            end
        end
    }
}

function ActivatePowerUp(player, type, name, duration, callback)
    local timeLeft = duration
    Events.CallRemote("PowerUpActivated", player, type, name, timeLeft)
    local key = type .. "PU_Timer"

    local timer = Timer.SetInterval(function()
        if timeLeft == nil or timeLeft <= 0 then
            callback()
            Timer.ClearInterval(player:GetValue(key))
            return
        end
        timeLeft = timeLeft - 1
    end, 1000)
    local oldTimer = player:GetValue(key)
    if oldTimer then
        Timer.ClearInterval(oldTimer)
    end
    player:SetValue(key, timer)
end

function PowerUp:Constructor(type, location)
	self.Super:Constructor(location, Rotator(0, 0, 0), "nanos-world::SM_Cube", CollisionType.NoCollision)
    self:SetScale(0.5)
    self:SetMaterialTextureParameter("Texture", "package://" .. Package.GetName() .. "/Client/Textures/" .. PowerUps[type].image)
    self.spin = 0
    self.spinSpeed = 70

    local trigger = Trigger(location, Rotator(), Vector(100), TriggerType.Sphere, false, Color(1, 0, 0), {"Character"})
    trigger:Subscribe("BeginOverlap", function(trigger, character)
        local player = character:GetPlayer()
        if not player or not player:IsValid() then
            return
        end
        self:Destroy()
        PowerUps[type].handler(character)
    end)
    trigger:AttachTo(self, AttachmentRule.SnapToTarget, nil, 0, false)
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