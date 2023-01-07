--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "keybind",
    Category = "Administrative",
    Description = "Binds the key with a specified command.",
    Prefix = "!",
    Arguments = {
        {
            Type = "userInput",
            Name = "Key",
            Description = "Key to bind.",
        },
        {
            Type = "string",
            Name = "Command",
            Description = "Command to run.",
        },
    },
    ClientLoad = function(Api: Types.NexusAdminApiClient)
        Api.CommandData.Keybinds = {}
        UserInputService.InputBegan:Connect(function(Input, Processed)
            if Processed then return end
            local Commands = Api.CommandData.Keybinds[Input.KeyCode] or Api.CommandData.Keybinds[Input.UserInputType]
            if Commands then
                for _, Command in Commands do
                    Api.Messages:DisplayHint(Api.Executor:ExecuteCommandWithOrWithoutPrefix(Command, Players.LocalPlayer, {ExecuteContext = "Keybind"}))
                end
            end
        end)
    end,
    ClientRun = function(CommandContext: Types.CmdrCommandContext, Key: Enum.KeyCode, Command: string)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        --Bind the key.
        if not Api.CommandData.Keybinds[Key] then
            Api.CommandData.Keybinds[Key] = {}
        end
        table.insert(Api.CommandData.Keybinds[Key], Util:GetRemainingString(CommandContext.RawText, 2))

        --Return the message.
        return "Key bound."
    end,
}