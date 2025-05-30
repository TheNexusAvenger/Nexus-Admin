--Client API for Nexus Admin.
--!strict

--Get the containers.
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local EventContainer = ReplicatedStorage:WaitForChild("NexusAdminEvents")
local AdminItemContainer = Workspace:WaitForChild("NexusAdminItemContainer")



--[[
Converts the string indexes to numbers.
--]]
local function ConvertStringIndexesToNumbers(Array: {[any]: any}): any
    local NewArray = {}
    for Key, Value in Array do
        --Convert the value if it is an array.
        if type(Value) == "table" then
            Value = ConvertStringIndexesToNumbers(Value)
        end

        --Add the index.
        NewArray[tonumber(Key) or Key] = Value
    end

    return NewArray
end



--Initialize the resources.
local Types = require(script:WaitForChild("Types"))
local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient")) :: Types.Cmdr
local Configuration = (require(script:WaitForChild("Common"):WaitForChild("Configuration")) :: Types.Configuration).new(ConvertStringIndexesToNumbers(EventContainer:WaitForChild("GetConfiguration"):InvokeServer()))
local Authorization = require(script:WaitForChild("ClientAuthorization")).new(Configuration,EventContainer)
local Filter = require(script:WaitForChild("Common"):WaitForChild("Filter")).new() :: Types.Filter
local Messages = require(script:WaitForChild("ClientMessages")).new(EventContainer) :: Types.MessagesClient
local Registry = require(script:WaitForChild("ClientRegistry")).new(Authorization, Configuration, Messages, Cmdr, EventContainer)
local LogsRegistry = require(script:WaitForChild("ClientLogsRegistry")).new(EventContainer)
local Executor = (require(script:WaitForChild("Common"):WaitForChild("Executor")) :: Types.Executor).new(Cmdr,Registry)
local FeatureFlags = (require(script:WaitForChild("Packages"):WaitForChild("NexusFeatureFlags")) :: Types.NexusFeatureFlagsSource)
local Time = (require(script:WaitForChild("Common"):WaitForChild("Time")) :: Types.Time)
local Window = (require(script:WaitForChild("Window")) :: Types.Window)

--Create the API.
local API = {
    Types = {},
    CommandData = {},
    Version = Configuration.Version,
    VersionNumberId = Configuration.VersionNumberId,
    CmdrVersion = Configuration.CmdrVersion,
    EventContainer = EventContainer,
    AdminItemContainer = AdminItemContainer,

    Cmdr = Cmdr,
    Configuration = Configuration,
    Authorization = Authorization,
    Filter = Filter,
    Messages = Messages,
    Registry = Registry,
    LogsRegistry = LogsRegistry,
    Executor = Executor,
    FeatureFlags = FeatureFlags,
    Time = Time,
    Window = Window,
    Gui = {},
}

--Add the custom Cmdr types.
for _, TypeModule in script:WaitForChild("Common"):WaitForChild("Types"):GetChildren() do
    (require(TypeModule) :: (Types.NexusAdminApiClient) -> ())(API :: any)
end

--[[
Loads the included commands.
--]]
function API:LoadIncludedCommands()
    local Categories = {"Administrative", "BasicCommands", "UsefulFunCommands", "PersistentCommands", "DefaultUtil"}
    for _,Category in Categories do
        --[[
        Loads a module.
        --]]
        local function LoadModule(Module: Instance): ()
            if not Module:IsA("ModuleScript") then return end
            self.Registry:RegisterIncludedCommand(Module, self)
        end

        --Add the scripts.
        local Folder = script:WaitForChild("IncludedCommands"):WaitForChild(Category)
        for _, Module in Folder:GetChildren() do
            LoadModule(Module)
        end

        --Connect adding new scripts.
        Folder.ChildAdded:Connect(LoadModule)
    end
end

--Initialize the optional UI.
require(script:WaitForChild("UI"):WaitForChild("Messages"))(API :: any, Players.LocalPlayer)
require(script:WaitForChild("UI"):WaitForChild("ChatExecuting"))(API :: any, Players.LocalPlayer)
require(script:WaitForChild("UI"):WaitForChild("Tooltip"))(API :: any, Players.LocalPlayer)

--Add the API fetchers.
function _G.NexusAdmin_GetLocalAPI()
    return API
end

function _G.GetNexusAdminClientAPI()
    return API
end

--Add the deprecated methods.
local StaticContainer: ScreenGui = nil
function API.GetAdminGuiContainer()
    warn("NexusAdminClientAPI.GetAdminGuiContainer() is deprecated as of V.2.0.0. ScreenGuis should be created.")
    --Create the GUI.
    if not StaticContainer or not StaticContainer.Parent then
        local NewStaticContainer = Instance.new("ScreenGui")
        NewStaticContainer.Name = "NexusAdminStaticGui"
        NewStaticContainer.Parent = Players.LocalPlayer:FindFirstChild("PlayerGui")
        StaticContainer = NewStaticContainer
    end

    --Return the GUI.
    return StaticContainer
end

function API.GetIntegratedData(Name,Arguments)
    error("NexusAdminClientAPI.GetIntegratedData(Name,Arguments) is removed as of V.2.0.0. The data can be fetched is no longer internal.")
end

function API.GetTextBounds(Text,Font,FontSize,Wrapped,Size,Clipped)
    warn("NexusAdminClientAPI.SendHint(Message,DisplayTime) is deprecated as of V.2.0.0. Please use TextService:GetTextSize(Text,FontSize,Font,Size) instead.")
    return TextService:GetTextSize(Text,FontSize,Font,Vector2.new(Size.X.Offset,Size.Y.Offset))
end

function API.AddTooltipToFrame(Text,Frame)
    warn("NexusAdminClientAPI.AddTooltipToFrame(Text,Frame) is deprecated as of V.2.0.0. Please use NexusAdminClientAPI.Gui:AddTooltipToFrame(Text,Frame) instead.");
    (API.Gui :: any):AddTooltipToFrame(Text,Frame)
end

function API.SendHint(Message,DisplayTime)
    warn("NexusAdminClientAPI.SendHint(Message,DisplayTime) is deprecated as of V.2.0.0. Please use NexusAdminClientAPI.Messages:DisplayHint(Message,DisplayTime) instead.")
    return API.Messages:DisplayHint(Message,DisplayTime)
end

function API.SendMessage(TopText,Message,DisplayTime)
    warn("NexusAdminClientAPI.SendMessage(TopText,Message,DisplayTime) is deprecated as of V.2.0.0. Please use NexusAdminClientAPI.Messages:DisplayMessage(TopText,Message,DisplayTime) instead.")
    return API.Messages:DisplayMessage(TopText,Message,DisplayTime)
end

function API.GetTimeString()
    warn("NexusAdminClientAPI.GetTimeString() is deprecated as of V.2.0.0. Please use NexusAdminClientAPI.Time:GetTimeString() instead.")
    return API.Time:GetTimeString()
end



--Return the API.
return (API :: any) :: Types.NexusAdminApiClient