local Commands = {}

Commands["/reload"] = function(player, args)
    Server.ReloadPackage(Package.GetName())
end

Commands["/kill"] = function(player, args)
    local character = player:GetControlledCharacter()
    if character and character:IsValid() then
        character:ApplyDamage(100000000, nil, nil, nil, character:GetPlayer(), nil)
    end
end

Chat.Subscribe("PlayerSubmit", function(message, player)
    -- Split message into command + arguments
    local parts = {}
    for part in message:gmatch("%S+") do
        table.insert(parts, part)
    end

    local command = parts[1]
    table.remove(parts, 1) -- remaining parts are args

    local handler = Commands[command]
    if handler then
        if Config.EnableCommands then
            handler(player, parts)
        end
    end
end)