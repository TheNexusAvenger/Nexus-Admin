--[[
TheNexusAvengeer

Client API for Nexus Admin.
--]]
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
local Messages = require(script:WaitForChild("ClientMessages")).new(EventContainer)
local Registry = require(script:WaitForChild("ClientRegistry")).new(Authorization, Configuration, Messages, Cmdr, EventContainer)
local LogsRegistry = require(script:WaitForChild("ClientLogsRegistry")).new(EventContainer)
local Executor = (require(script:WaitForChild("Common"):WaitForChild("Executor")) :: Types.Executor).new(Cmdr,Registry)
local FeatureFlags = (require(script:WaitForChild("NexusFeatureFlags")) :: Types.NexusFeatureFlagsSource)
local Time = (require(script:WaitForChild("Common"):WaitForChild("Time")) :: Types.Time)

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
    Messages = Messages,
    Registry = Registry,
    LogsRegistry = LogsRegistry,
    Executor = Executor,
    FeatureFlags = FeatureFlags,
    Time = Time,
    Gui = {
        Window = require(script:WaitForChild("UI"):WaitForChild("Window"):WaitForChild("Window")),
        ResizableWindow = require(script:WaitForChild("UI"):WaitForChild("Window"):WaitForChild("ResizableWindow")),
    },
}

--Add the custom Cmdr types.
for _, TypeModule in script:WaitForChild("Common"):WaitForChild("Types"):GetChildren() do
    (require(TypeModule) :: (Types.NexusAdminApiClient) -> ())(API :: any)
end

--[[
Loads the included commands.
--]]
function API:LoadIncludedCommands()
    local Categories = {"Administrative", "BasicCommands", "UsefulFun", "Persistent", "DefaultUtil"}
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
require(script:WaitForChild("UI"):WaitForChild("Messages"))(API, Players.LocalPlayer)
require(script:WaitForChild("UI"):WaitForChild("ChatExecuting"))(API, Players.LocalPlayer)
require(script:WaitForChild("UI"):WaitForChild("Tooltip"))(API, Players.LocalPlayer)

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

function API.CreateGenericListBox(Name,RefreshFunction,OnCloseFunction)
    warn("NexusAdminClientAPI.CreateGenericListBox(Name,RefreshFunction,OnCloseFunction) is deprecated as of V.2.0.0. Please use NexusAdminClientAPI.Gui.Window or NexusAdminClientAPI.Gui.ResizableWindow instead.")
    
    --Create the window.
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = Players.LocalPlayer:FindFirstChild("PlayerGui")

    local ScrollingFrame = Instance.new("ScrollingFrame")
    ScrollingFrame.BackgroundTransparency = 1
    ScrollingFrame.BorderSizePixel = 0
    ScrollingFrame.Size = UDim2.new(1,0,1,0)
    ScrollingFrame.ScrollBarThickness = 10
    ScrollingFrame.CanvasSize = UDim2.new(0,0,0,0)

    local Window = API.Gui.ResizableWindow.new()
    Window.Title = Name
    Window.WindowFrame.Position = UDim2.new(-0.3,0,0,0.3 * Window.WindowFrame.AbsoluteSize.Y)
    ScrollingFrame.Parent = Window.ContentsAdorn
    Window.WindowFrame.Parent = ScreenGui

    --Connect the events.
    Window.OnRefresh = function()
        RefreshFunction(ScrollingFrame)
    end
    Window.OnClose = function()
        --Run the OnClose function.
        if OnCloseFunction then
            spawn(function()
                OnCloseFunction(ScrollingFrame)
            end)
        end

        --Hide and destroy the window.
        Window.WindowFrame:TweenPosition(UDim2.new(-0.3,0,0,Window.WindowFrame.Position.Y.Offset),"In","Back",0.25,false,function()
            Window:Destroy()
            ScreenGui:Destroy()
        end)
    end

    --Run the refresh function and show the window.
    RefreshFunction(ScrollingFrame)
    Window.WindowFrame:TweenPosition(UDim2.new(0,50,0,Window.WindowFrame.Position.Y.Offset),"Out","Back",0.25,false)
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