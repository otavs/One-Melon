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
            character:SetJumpZVelocity(Config.PowerUpJumpForce)
            local timeLeft = Config.PowerUpJumpDuration
            local timer = Timer.SetInterval(function()
                print(timeLeft)
                if timeLeft == nil or timeLeft <= 0 then
                    character:SetJumpZVelocity(Config.PlayerJumpForce)
                    Timer.ClearInterval(character:GetValue("JumpBoostTimer"))
                    return
                end
                timeLeft = timeLeft - 1
            end, 1000)
            local oldTimer = character:GetValue("JumpBoostTimer")
            if oldTimer then
                Timer.ClearInterval(oldTimer)
            end
            character:SetValue("JumpBoostTimer", timer)
        end
    },
    Speed = {
        image = "speed.png",
        handler = function(character)
            character:SetSpeedMultiplier(Config.PowerUpSpeed)
            local timeLeft = Config.PowerUpSpeedDuration
            local timer = Timer.SetInterval(function()
                print(timeLeft)
                if timeLeft == nil or timeLeft <= 0 then
                    character:SetSpeedMultiplier(Config.PlayerSpeed)
                    Timer.ClearInterval(character:GetValue("SpeedBoostTimer"))
                    return
                end
                timeLeft = timeLeft - 1
            end, 1000)
            local oldTimer = character:GetValue("SpeedBoostTimer")
            if oldTimer then
                Timer.ClearInterval(oldTimer)
            end
            character:SetValue("SpeedBoostTimer", timer)
        end
    },
    Ultimate = {
        image = "ultimate.png",
        handler = function(character)
            local player = character:GetPlayer()
            AddAmmo(player, 1)
        end
    },
}

function PowerUp:Constructor(type, location)
	self.Super:Constructor(location, Rotator(0, 0, 0), "nanos-world::SM_Cube", CollisionType.NoCollision)
    self:SetScale(0.5)
    self:SetMaterialTextureParameter("Texture", "package://" .. Package.GetName() .. "/Client/Textures/" .. PowerUps[type].image)
    self.spin = 0
    self.spinSpeed = 70

    local trigger = Trigger(location, Rotator(), Vector(100), TriggerType.Sphere, false, Color(1, 0, 0),  {"Character"})
    trigger:Subscribe("BeginOverlap", function(trigger, character)
        self:Destroy()
        PowerUps[type].handler(character)
    end)
    trigger:AttachTo(self, AttachmentRule.SnapToTarget, nil, 0, false)
end

function PowerUp:Tick(deltaTime)
  self.spin = (self.spin + self.spinSpeed * deltaTime) % 360
  local portalRot = Rotator(0, -self.spin, 0)
  self:RotateTo(portalRot, 1)
end