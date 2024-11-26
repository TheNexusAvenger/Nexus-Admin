--Implementation of a command.
--!strict

local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Logs = require(script.Parent.Parent.Parent:WaitForChild("Common"):WaitForChild("Logs"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))



--[[
Parses the players in a chat.
--]]
local function ParseChatName(Name: string): {Player}
    local ChatPlayers = {}
    for _, UserIdString in string.split(Name, "_") do
        local UserId = tonumber(UserIdString)
        if not UserId then continue end
        local Player = Players:GetPlayerByUserId(UserId)
        if not Player then continue end
        table.insert(ChatPlayers, Player)
    end
    return ChatPlayers
end



return {
    Keyword = {"pchat", "pc"},
    Category = "BasicCommands",
    Description = "Starts a private chat between a players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to start the private chat with.",
        },
    },
    ClientLoad = function(Api: Types.NexusAdminApiClient)
        --Add the function to open chat windows.
        local OpenChatWindows = {} :: {[string]: boolean}
        local ChatLogs = {} :: {[string]: Types.Logs}
        Api.CommandData.OpenPrivateChatWindow = function(ChatName: string): ()
            --Return if the chat is already open.
            if OpenChatWindows[ChatName] then return end

            --Determine the other player.
            local ChatPlayers = ParseChatName(ChatName)
            local OtherPlayer: Player? = ChatPlayers[1]
            for _, Player in ChatPlayers do
                if Player == Players.LocalPlayer then continue end
                OtherPlayer = Player
                break
            end
            if not OtherPlayer then return end

            --Get the text channel.
            local TextChannel = TextChatService:WaitForChild("TextChannels"):WaitForChild(ChatName, 10) :: TextChannel
            if not TextChannel then return end
            if OpenChatWindows[ChatName] then return end
            OpenChatWindows[ChatName] = true

            --Wait for the logs.
            while not ChatLogs[ChatName] do task.wait() end

            --Show the window.
            local Window = Api.Window:CreateWindow(`Chat - {OtherPlayer.DisplayName} ({OtherPlayer.Name})`)
            local TextList = Window:AddTextList()
            TextList:EnableSearching()
            TextList:DisplayLogs(ChatLogs[ChatName], "NewestFirst")
            Window:EnableClosing(function()
                OpenChatWindows[ChatName] = nil
            end)
            Window:EnableResizing()
            Window:Show()

            --Create the chat input.
            local TextSize = Window.TextHeight
            TextList:Move(UDim2.new(1, -10, 1, -10 - (2 * TextSize)))

            local ChatBar = Instance.new("TextBox")
            ChatBar.BackgroundTransparency = 0.5
            ChatBar.Size = UDim2.new(1, -TextSize, 0, 1.2 * TextSize)
            ChatBar.Position = UDim2.new(0, 0.5 * TextSize, 1, -1.5 * TextSize)
            ChatBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            ChatBar.BorderSizePixel = 0
            ChatBar.Text = ""
            ChatBar.Font = Enum.Font.SourceSans
            ChatBar.TextSize = TextSize
            ChatBar.TextColor3 = Color3.fromRGB(255, 255, 255)
            ChatBar.ClearTextOnFocus = false
            ChatBar.ClipsDescendants = true
            ChatBar.TextXAlignment = Enum.TextXAlignment.Left
            ChatBar.Parent = Window.ContentsAdorn

            ChatBar.FocusLost:Connect(function(EnterPressed)
                if not EnterPressed then return end
                local Message = string.match(ChatBar.Text,  "^%s*(.+[^%s])%s*$")
                if Message == nil then return end
                ChatBar.Text = ""
                TextChannel:SendAsync(Message)
            end)
        end

        --Connect new text channels being added.
        local TextChannels = TextChatService:WaitForChild("TextChannels", 10)
        if not TextChannels then return end --TextChatService not enabled.
        TextChannels.ChildAdded:Connect(function(TextChannel)
            if not TextChannel:IsA("TextChannel") then return end
            local TextChannelPlayers = ParseChatName(TextChannel.Name)
            if not table.find(TextChannelPlayers, Players.LocalPlayer) then return end

            --Create the chat log for use in the text list.
            local ChatName = TextChannel.Name
            if not ChatLogs[ChatName] then
                local NewLog = Logs.new()
                TextChannel.OnIncomingMessage = function(Message: TextChatMessage)
                    --Add the message if it was successful.
                    --Logs don't support replacing messages (such as when filtered).
                    if Message.Status ~= Enum.TextChatMessageStatus.Sending then
                        NewLog:Add(`{Message.TextSource.Name} [{Api.Time:GetTimeString()}]: {Message.Text}`)
                    end

                    --Open the chat if it isn't open already.
                    task.spawn(function()
                        Api.CommandData.OpenPrivateChatWindow(TextChannel.Name)
                    end)

                    --Hide the message to prevent showing in the chat.
                    --This is hacky, but there doesn't seem to be a better solution.
                    local NewProperties = Instance.new("TextChatMessageProperties")
                    NewProperties.Text = " "
                    return NewProperties
                end
                ChatLogs[ChatName] = NewLog :: any
            end
        end)
    end,
    ClientRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetClientApi()

        --Return if the chat is not enabled.
        local TextChannels = TextChatService:FindFirstChild("TextChannels")
        if not TextChannels then
            return
        end

        --Create the chat windows.
        for _, Player in Players do
            task.spawn(function()
                Api.CommandData.OpenPrivateChatWindow(`NexusAdminChat_{CommandContext.Executor.UserId}_{Player.UserId}`)
            end)
        end
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player}): string?
        local Util = IncludedCommandUtil.ForContext(CommandContext)

        --Return if the chat is not enabled.
        local TextChannels = TextChatService:FindFirstChild("TextChannels")
        if not TextChannels then
            return "TextChatService is not enabled."
        end

        --Return if the player can't chat.
        --TODO

        --Create the text channel if it doesn't exist.
        for _, Player in Players do
            --Show a message if the users can't chat.
            local Worked, CanChat = pcall(function()
                return TextChatService:CanUsersDirectChatAsync(CommandContext.Executor.UserId, {Player.UserId})
            end)
            if not Worked then
                warn(`Failed to check if {CommandContext.Executor.UserId} can direct chat with {Player.UserId} because "{CanChat}"`)
                continue
            end
            if not CanChat then
                Util:SendError(`You can't direct chat with {Player.DisplayName} ({Player.Name})`)
                continue
            end

            --Create the channel.
            local Player1Id, Player2Id = CommandContext.Executor.UserId, Player.UserId
            local TextChannelName = `NexusAdminChat_{Player1Id}_{Player2Id}`
            if not TextChannels:FindFirstChild(TextChannelName) then
                local NewTextChannel = Instance.new("TextChannel")
                NewTextChannel.Name = TextChannelName
                NewTextChannel.Parent = TextChannels
                NewTextChannel:AddUserAsync(Player1Id)
                if Player1Id ~= Player2Id then
                    NewTextChannel:AddUserAsync(Player2Id)
                end
            end
        end
        return nil
    end
}