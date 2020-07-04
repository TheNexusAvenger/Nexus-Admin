--[[
TheNexusAvenger

Sends messages to players.
--]]

local NexusObject = require(script.Parent.Parent:WaitForChild("NexusInstance"):WaitForChild("NexusObject"))

local ServerMessages = NexusObject:Extend()
ServerMessages:SetClassName("ServerMessages")



--[[
Creates a server messages instance.
--]]
function ServerMessages:__new(NexusAdminRemotes)
    self:InitializeSuper()

    --Create the remote objects.
    local MessageEvents = Instance.new("Folder")
    MessageEvents.Name = "MessageEvents"
    MessageEvents.Parent = NexusAdminRemotes

    local DisplayHintEvent = Instance.new("RemoteEvent")
    DisplayHintEvent.Name = "DisplayHint"
    DisplayHintEvent.Parent = MessageEvents
    self.DisplayHintEvent = DisplayHintEvent

    local DisplayMessageEvent = Instance.new("RemoteEvent")
    DisplayMessageEvent.Name = "DisplayMessage"
    DisplayMessageEvent.Parent = MessageEvents
    self.DisplayMessageEvent = DisplayMessageEvent
end

--[[
Sends a message to a player.
--]]
function ServerMessages:DisplayMessage(Player,TopText,Message,DisplayTime)
    self.DisplayMessageEvent:FireClient(Player,TopText,Message,DisplayTime)
end

--[[
Sends a hint to a player.
--]]
function ServerMessages:DisplayHint(Player,Message,DisplayTime)
    self.DisplayHintEvent:FireClient(Player,Message,DisplayTime)
end



return ServerMessages