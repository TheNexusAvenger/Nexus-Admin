--[[
TheNexusAvenger

Adds executing messages from the chat.
--]]
--!strict

local TextChatService = game:GetService("TextChatService")

local Types = require(script.Parent.Parent:WaitForChild("Types"))

return function(API: Types.NexusAdminApiClient, Player: Player): ()
    --[[
    Executes a chat command.
    --]]
    local function ExecuteCommand(Message: string): ()
        if API.FeatureFlags:GetFeatureFlag("AllowChatCommandExecuting") then
            --Run the command.
            local RunMessage = API.Executor:ExecuteCommandWithPrefix(Message, Player, {ExecuteContext = "Chat"})
            if RunMessage ~= "Unknown command." then
                if RunMessage ~= "" then
                    API.Messages:DisplayHint(RunMessage)
                end
            else
                --Get the command.
                local Command = Message
                if string.find(Message, " ") then
                    local StartIndex, _ = string.find(Message, " ")
                    Command = string.sub(Message, 1, (StartIndex :: number) - 1)
                end
                if Command ~= "" then
                    Command = string.lower(Command)
                end

                --Display the message if the prefix is valid.
                for Prefix, _ in (API.Registry :: any).Prefixes do
                    if string.len(Command) >= string.len(Prefix) and string.sub(Command, 1, string.len(Prefix)) == Prefix then
                        API.Messages:DisplayHint(Command.." is not a valid command.")
                        break
                    end
                end
            end
        end
    end

    --Connect the chatted event.
    Player.Chatted:Connect(ExecuteCommand)
    TextChatService.SendingMessage:Connect(function(Message: TextChatMessage)
        if not Message.TextSource or Message.TextSource.UserId ~= Player.UserId then return end
        ExecuteCommand(Message.Text)
    end)
end