--[[
TheNexusAvenger

Sends messages to players.
--]]
--!strict

local ServerMessages = {}
ServerMessages.__index = ServerMessages

export type ServerMessages = {
    DisplayHintEvent: RemoteEvent,
    DisplayMessageEvent: RemoteEvent,
    DisplayNotificationEvent: RemoteEvent,
} & typeof(setmetatable({}, ServerMessages))



--[[
Creates a server messages instance.
--]]
function ServerMessages.new(NexusAdminRemotes: Folder): ServerMessages
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
    return setmetatable({
        DisplayHintEvent = DisplayHintEvent,
        DisplayMessageEvent = DisplayMessageEvent,
        DisplayNotificationEvent = DisplayNotificationEvent,
    }, ServerMessages) :: ServerMessages
end

--[[
Sends a message to a player.
--]]
function ServerMessages.DisplayMessage(self: ServerMessages, Player: Player, TopText: string, Message: string, DisplayTime: number?): ()
    self.DisplayMessageEvent:FireClient(Player, TopText, Message, DisplayTime)
end

--[[
Sends a hint to a player.
--]]
function ServerMessages.DisplayHint(self: ServerMessages, Player: Player, Message: string, DisplayTime: number): ()
    self.DisplayHintEvent:FireClient(Player, Message, DisplayTime)
end

--[[
Sends a notification to a player.
--]]
function ServerMessages.DisplayNotification(self: ServerMessages, Player: Player, TopText: string, Message: string, DisplayTime: number?): ()
    self.DisplayNotificationEvent:FireClient(Player, TopText, Message, DisplayTime)
end



return ServerMessages