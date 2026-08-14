--Adds executing messages from the chat.
--!strict

local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

local Types = require(script.Parent.Parent:WaitForChild("Types"))

return function(API: Types.NexusAdminApiClient, Player: Player): ()
    local CreatedCommands = {}
    local CommandUpdateQueued = false

    local NexusAdminChatCommands = Instance.new("Folder")
    NexusAdminChatCommands.Name = "NexusAdminChatCommands"
    NexusAdminChatCommands.Parent = TextChatService

    --[[
    Updates the TextChatCommand instances.
    --]]
    local function UpdateCommands(): ()
        --Create the commands if chat executing is enabled.
        local PrefixCommands = (API.Registry :: any).PrefixCommands :: {[string]: string}
        local AvailableCommands = {}
        if API.FeatureFlags:GetFeatureFlag("AllowChatCommandExecuting") then
            for PrefixCommand, Command in PrefixCommands do
                --Ignore the command if it registered with no prefix.
                --Prefixes are required for chat executing.
                if PrefixCommand == Command then continue end

                --Ignore the command if the player is not authorized.
                local IsAuthorized = false
                for _, Commands in (API.Registry :: any).CommandsByGroup do
                    for _, CommandData in Commands do
                        if CommandData.Keyword ~= Command and (not CommandData.Aliases or not table.find(CommandData.Aliases, Command)) then continue end
                        if CommandData.AdminLevel and API.Authorization:IsPlayerAuthorized(Player, CommandData.AdminLevel) then
                            IsAuthorized = true
                        end
                        break
                    end
                end
                if not IsAuthorized then continue end

                --Ignore the command if it already exists.
                AvailableCommands[PrefixCommand] = true
                if CreatedCommands[PrefixCommand] then continue end

                --Create the command.
                local ChatCommand = Instance.new("TextChatCommand")
                ChatCommand.PrimaryAlias = PrefixCommand
                ChatCommand.Name = Command
                ChatCommand.Parent = NexusAdminChatCommands
                CreatedCommands[PrefixCommand] = ChatCommand

                ChatCommand.Triggered:Connect(function(_, Message: string)
                    local RunMessage = API.Executor:ExecuteCommandWithPrefix(Message, Player, {ExecuteContext = "Chat"})
                    if RunMessage == "" then return end
                    API.Messages:DisplayHint(RunMessage)
                end)
            end
        end

        --Remove commands that don't exist.
        --This has to be done in 2 steps to avoid modifying a table being iterated over.
        local CommandsToRemove = {}
        for PrefixCommand, ChatCommand in CreatedCommands do
            if AvailableCommands[PrefixCommand] then continue end
            CommandsToRemove[PrefixCommand] = ChatCommand
        end
        for PrefixCommand, ChatCommand in CommandsToRemove do
            ChatCommand:Destroy()
            CreatedCommands[PrefixCommand] = nil
        end
    end

    --[[
    Queues updating the commands the next frame.
    This is intended to reduce frequent updates when first loading commands.
    --]]
    local function QueueUpdateCommands(): ()
        if CommandUpdateQueued then return end
        CommandUpdateQueued = true
        task.defer(function()
            UpdateCommands()
            CommandUpdateQueued = false
        end)
    end

    --Connect changes to the chat commands.
    --This needs to handle the feature flag changing, the admin level changing, and commands being registered.
    API.Authorization.AdminLevelChanged:Connect(function(Player)
        if Player ~= Players.LocalPlayer then return end
        QueueUpdateCommands()
    end)
    API.FeatureFlags:GetFeatureFlagChangedEvent("AllowChatCommandExecuting"):Connect(QueueUpdateCommands);
    (API.Registry :: any).NewCommandRegistered.Event:Connect(QueueUpdateCommands)
    QueueUpdateCommands()
end