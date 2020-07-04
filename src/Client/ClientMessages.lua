--[[
TheNexusAvenger

Sends messages to the local player.
--]]

local NexusObject = require(script.Parent:WaitForChild("NexusInstance"):WaitForChild("NexusObject"))

local ClientMessages = NexusObject:Extend()
ClientMessages:SetClassName("ClientMessages")



--[[
Creates a client messages instance.
--]]
function ClientMessages:__new(NexusAdminRemotes)
    self:InitializeSuper()

    --Create the bindable objects.
    local MessageEvents = NexusAdminRemotes:WaitForChild("MessageEvents")

    local DisplayHintLoopbackEvent = Instance.new("BindableEvent")
    DisplayHintLoopbackEvent.Name = "DisplayHintLoopback"
    DisplayHintLoopbackEvent.Parent = MessageEvents
    self.DisplayHintLoopbackEvent = DisplayHintLoopbackEvent

    local DisplayMessageLoopbackEvent = Instance.new("BindableEvent")
    DisplayMessageLoopbackEvent.Name = "DisplayMessageLoopback"
    DisplayMessageLoopbackEvent.Parent = MessageEvents
    self.DisplayMessageLoopbackEvent = DisplayMessageLoopbackEvent

    --Connect the remote events.
    MessageEvents:WaitForChild("DisplayMessage").OnClientEvent:Connect(function(TopText,Message,DisplayTime)
        self:DisplayMessage(TopText,Message,DisplayTime)
    end)
    MessageEvents:WaitForChild("DisplayHint").OnClientEvent:Connect(function(Message,DisplayTime)
        self:DisplayHint(Message,DisplayTime)
    end)
end

--[[
Sends a message to the local player.
--]]
function ClientMessages:DisplayMessage(TopText,Message,DisplayTime)
    self.DisplayMessageLoopbackEvent:Fire(TopText,Message,DisplayTime)
end

--[[
Sends a hint to the local player.
--]]
function ClientMessages:DisplayHint(Message,DisplayTime)
    self.DisplayHintLoopbackEvent:Fire(Message,DisplayTime)
end



return ClientMessages