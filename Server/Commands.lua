Commands = {}

-- Commands["/reload"] = function(player, args)
--     Server.ReloadPackage(Package.GetName())
-- end

-- Commands["/kill"] = function(player, args)
--     local character = player:GetControlledCharacter()
--     if character and character:IsValid() then
--         character:ApplyDamage(3, nil, nil, nil, character:GetPlayer(), nil)
--     end
-- end

Commands["/start"] = function(player, args)
    if Game.State == State.Playing then
        PostGame.InitState()
    else
        Game.Timer = 0
    end
    return false
end