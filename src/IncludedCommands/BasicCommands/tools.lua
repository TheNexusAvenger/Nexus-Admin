--[[
TheNexusAvenger

Implementation of a command.
--]]

local TOOL_CONTAINERS = {
    game:GetService("Lighting"),
    game:GetService("ReplicatedStorage"),
    game:GetService("ServerStorage"),
    game:GetService("StarterPack"),
}

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local ToolListEnum = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("ToolListEnum"))
local Command = BaseCommand:Extend()


--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("tools","BasicCommands","Opens up a window containing the list of tools usable by :give.")
    ToolListEnum:SetUp(self.API.Registry)

    --Create the remote function.
    local GetToolsInContainers = Instance.new("RemoteFunction")
    GetToolsInContainers.Name = "GetToolsInContainers"
    GetToolsInContainers.Parent = self.API.EventContainer

    function GetToolsInContainers.OnServerInvoke(Player)
        if self.API.Authorization:IsPlayerAuthorized(Player,self.AdminLevel) then
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
            local ToolsList = {}
            for _, Container in TOOL_CONTAINERS do
                table.insert(ToolsList, {Text=Container.Name, Font="SourceSansBold"})
                local ToolsInContainer = ToolsByContainer[Container]
                table.sort(ToolsInContainer, function(a, b) return string.lower(a) < string.lower(b) end)
                if #ToolsInContainer ~= 0 then
                    for _,Tool in pairs(ToolsInContainer) do
                        table.insert(ToolsList, Tool)
                    end
                else
                    table.insert(ToolsList, {Text="(None)", Font="SourceSansItalic"})
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
end



return Command