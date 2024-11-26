--Implementation of a command.
--!strict

local TOOL_CONTAINERS = {
    game:GetService("Lighting"),
    game:GetService("ReplicatedStorage"),
    game:GetService("ServerStorage"),
    game:GetService("StarterPack"),
}

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "tools",
    Category = "BasicCommands",
    Description = "Opens up a window containing the list of tools usable by :give.",
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        local ToolListEnum = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("ToolListEnum"));
        (ToolListEnum :: any):SetUp(Api.Registry)

        --Create the remote function.
        local GetToolsInContainers = IncludedCommandUtil:CreateRemote("RemoteFunction", "GetToolsInContainers") :: RemoteFunction
        function GetToolsInContainers.OnServerInvoke(Player)
            if Api.Authorization:IsPlayerAuthorized(Player, Api.Configuration:GetCommandAdminLevel("BasicCommands", "tools")) then
                --Get the tools for each container.
                local ToolsByContainer = {}
                for _, Container in TOOL_CONTAINERS do
                    ToolsByContainer[Container] = {}
                end
                for _, Tool in ToolListEnum:GetTools({"all"}) do
                    for _, Container in TOOL_CONTAINERS do
                        if not Tool:IsDescendantOf(Container) then continue end
                        table.insert(ToolsByContainer[Container], Tool.Name)
                        break
                    end
                end
    
                --Create the list.
                local ToolsList = {} :: {string | {[string]: any}}
                for _, Container in TOOL_CONTAINERS do
                    table.insert(ToolsList, {Text=Container.Name, Font = Enum.Font.SourceSansBold})
                    local ToolsInContainer = ToolsByContainer[Container]
                    table.sort(ToolsInContainer, function(a, b) return string.lower(a) < string.lower(b) end)
                    if #ToolsInContainer ~= 0 then
                        for _,Tool in ToolsInContainer do
                            table.insert(ToolsList, Tool)
                        end
                    else
                        table.insert(ToolsList, {Text="(None)", Font = Enum.Font.SourceSans})
                    end
                    table.insert(ToolsList, "")
                end
    
                --Return the list.
                table.remove(ToolsList,#ToolsList)
                return ToolsList
            else
                return {"Unauthorized"}
            end
        end
    end,
    ClientRun = function(CommandContext: Types.CmdrCommandContext)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetClientApi()

        --Show the window.
        local Window = Api.Window:CreateWindow("Tools")
        local TextList = Window:AddTextList()
        TextList:EnableSearching()

        local function UpdateText()
            TextList:SetLines({"Loading..."})
            TextList:SetLines((Api.EventContainer:WaitForChild("GetToolsInContainers") :: RemoteFunction):InvokeServer())
        end

        task.spawn(UpdateText)
        Window:EnableRefreshing(UpdateText)
        Window:EnableClosing()
        Window:EnableResizing()
        Window:Show()
    end,
}