Commands = {}

Commands["/reload"] = function(player, args)
    Server.ReloadPackage(Package.GetName())
end

Commands["/kill"] = function(player, args)
    local character = player:GetControlledCharacter()
    if character and character:IsValid() then
        character:ApplyDamage(3, nil, nil, nil, character:GetPlayer(), nil)
    end
end

Commands["/start"] = function(player, args)
    if Game.State == State.Playing then
        PostGame.InitState()
    else
        Game.Timer = 0
    end
end

Commands["/show-ugandan"] = function(player, args)
    if #Ugandan.GetAll() == 0 then
        Chat.BroadcastMessage("Ugandan not found")
        return
    end
    for _, ugandan in pairs(Ugandan.GetAll()) do
        Chat.BroadcastMessage("Ugandan is at: " .. tostring(ugandan:GetLocation()))
    end
end