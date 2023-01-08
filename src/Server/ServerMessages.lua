--[[
TheNexusAvenger

Sends messages to players.
--]]
--!strict

local Types = require(script.Parent.Parent:WaitForChild("Types"))

local ServerMessages = {}
ServerMessages.__index = ServerMessages



--[[
Creates a server messages instance.
--]]
function ServerMessages.new(NexusAdminRemotes: Folder): Types.MessagesServer
    --Create the remote objects.
    local MessageEvents = Instance.new("Folder")
    MessageEvents.Name = "MessageEvents"
    MessageEvents.Parent = NexusAdminRemotes

    local DisplayHintEvent = Instance.new("RemoteEvent")
    DisplayHintEvent.Name = "DisplayHint"
    DisplayHintEvent.Parent = MessageEvents

    local DisplayMessageEvent = Instance.new("RemoteEvent")
    DisplayMessageEvent.Name = "DisplayMessage"
    DisplayMessageEvent.Parent = MessageEvents

    local DisplayNotificationEvent = Instance.new("RemoteEvent")
    DisplayNotificationEvent.Name = "DisplayNotification"
    DisplayNotificationEvent.Parent = MessageEvents

    --Create and return the object.
    return (setmetatable({
        DisplayHintEvent = DisplayHintEvent,
        DisplayMessageEvent = DisplayMessageEvent,
        DisplayNotificationEvent = DisplayNotificationEvent,
    }, ServerMessages) :: any) :: Types.MessagesServer
end

--[[
Sends a message to a player.
--]]
function ServerMessages:DisplayMessage(Player: Player, TopText: string, Message: string, DisplayTime: number?): ()
    self.DisplayMessageEvent:FireClient(Player, TopText, Message, DisplayTime)
end

--[[
Sends a hint to a player.
--]]
function ServerMessages:DisplayHint(Player: Player, Message: string, DisplayTime: number): ()
    self.DisplayHintEvent:FireClient(Player, Message, DisplayTime)
end

--[[
Sends a notification to a player.
--]]
function ServerMessages:DisplayNotification(Player: Player, TopText: string, Message: string, DisplayTime: number?): ()
    self.DisplayNotificationEvent:FireClient(Player, TopText, Message, DisplayTime)
end



return (ServerMessages :: any) :: Types.MessagesServer