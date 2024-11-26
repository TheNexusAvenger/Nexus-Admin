--Sends messages to the local player.
--!strict

local ClientMessages = {}
ClientMessages.__index = ClientMessages

export type ClientMessages = {
    DisplayHintLoopbackEvent: BindableEvent,
    DisplayMessageLoopbackEvent: BindableEvent,
    DisplayNotificationLoopbackEvent: BindableEvent,
} & typeof(setmetatable({}, ClientMessages))



--[[
Creates a client messages instance.
--]]
function ClientMessages.new(NexusAdminRemotes: Folder): ClientMessages
    --Create the object.
    local self = setmetatable({}, ClientMessages) :: ClientMessages

    --Create the bindable objects.
    local MessageEvents = NexusAdminRemotes:WaitForChild("MessageEvents")

    local DisplayHintLoopbackEvent = Instance.new("BindableEvent")
    DisplayHintLoopbackEvent.Name = "DisplayHintLoopback"
    DisplayHintLoopbackEvent.Parent = MessageEvents
    self.DisplayHintLoopbackEvent = DisplayHintLoopbackEvent

    local DisplayMessageLoopbackEvent = Instance.new("BindableEvent")
    DisplayMessageLoopbackEvent.Name = "DisplayMessageLoopback"
    DisplayMessageLoopbackEvent.Parent = MessageEvents
    self.DisplayMessageLoopbackEvent = DisplayMessageLoopbackEvent;

    local DisplayNotificationLoopbackEvent = Instance.new("BindableEvent")
    DisplayNotificationLoopbackEvent.Name = "DisplayNotificationLoopback"
    DisplayNotificationLoopbackEvent.Parent = MessageEvents
    self.DisplayNotificationLoopbackEvent = DisplayNotificationLoopbackEvent;

    --Connect the remote events.
    (MessageEvents:WaitForChild("DisplayMessage") :: RemoteEvent).OnClientEvent:Connect(function(TopText: string, Message: string, DisplayTime: number?): ()
        self:DisplayMessage(TopText, Message, DisplayTime)
    end);
    (MessageEvents:WaitForChild("DisplayHint") :: RemoteEvent).OnClientEvent:Connect(function(Message: string, DisplayTime: number?): ()
        self:DisplayHint(Message, DisplayTime)
    end);
    (MessageEvents:WaitForChild("DisplayNotification") :: RemoteEvent).OnClientEvent:Connect(function(TopText: string, Message: string, DisplayTime: number?): ()
        self:DisplayNotification(TopText, Message, DisplayTime)
    end)

    --Return the object.
    return self
end

--[[
Sends a message to the local player.
--]]
function ClientMessages.DisplayMessage(self: ClientMessages, TopText: string, Message: string, DisplayTime: number?): ()
    self.DisplayMessageLoopbackEvent:Fire(TopText, Message, DisplayTime)
end

--[[
Sends a hint to the local player.
--]]
function ClientMessages.DisplayHint(self: ClientMessages, Message: string, DisplayTime: number?)
    self.DisplayHintLoopbackEvent:Fire(Message, DisplayTime)
end

--[[
Sends a notification to the local player.
--]]
function ClientMessages.DisplayNotification(self: ClientMessages, TopText: string, Message: string, DisplayTime: number?)
    self.DisplayNotificationLoopbackEvent:Fire(TopText, Message, DisplayTime)
end



return ClientMessages