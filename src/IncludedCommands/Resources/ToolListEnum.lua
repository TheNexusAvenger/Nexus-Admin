--[[
TheNexusAvenger

Manages the tool enum.
--]]
--!strict

local TOOL_CONTAINERS = {
    game:GetService("Lighting"),
    game:GetService("ReplicatedStorage"),
    game:GetService("ServerStorage"),
    game:GetService("StarterPack"),
}

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

local ToolListEnum = {}
ToolListEnum.ToolsLookup = {}
ToolListEnum.ToolChangedEvents = {}


--[[
Updates the tools lookup map and enum.
--]]
function ToolListEnum:UpdateEnum(): ()
    --Disconnect the changed events.
    for _, Event in self.ToolChangedEvents do
        Event:Disconnect()
    end
    self.ToolChangedEvents = {}

    --Iterate over the tools and create the new lookup table.
    local ToolsLookup = {}
    local ToolNames = {}
    for _, Container in TOOL_CONTAINERS do
        for _, Tool in Container:GetDescendants() do
            if not Tool:IsA("BackpackItem") then continue end
            if not ToolsLookup[Tool.Name] then
                ToolsLookup[Tool.Name] = {}
                table.insert(ToolNames, Tool.Name)
            end
            table.insert(ToolsLookup[Tool.Name], Tool)

            --Connect the tool changing.
            table.insert(self.ToolChangedEvents, Tool.Changed:Connect(function(PropertyName)
                if PropertyName ~= "Parent" and PropertyName ~= "Name" then return end
                self:UpdateEnum()
            end))
        end
    end

    --Register the enum.
    table.sort(ToolNames, function(a, b) return string.lower(a) < string.lower(b) end)
    table.insert(ToolNames, 1, "all")
    self.NexusAdminRegistry:AddEnumType("nexusAdminTool", ToolNames)

    --Create the lookup for all.
    local AllLookup = {}
    for _, ToolList in ToolsLookup do
        for _, Tool in ToolList do
            table.insert(AllLookup, Tool)
        end
    end
    ToolsLookup["all"] = AllLookup
    self.ToolsLookup = ToolsLookup
end

--[[
Returns the tools for the given names.
--]]
function ToolListEnum:GetTools(ToolNames: {string}): {Tool}
    local ToolSet = {}
    local ToolSetLookup = {}
    for _, ToolName in ToolNames do
        if not self.ToolsLookup[ToolName] then continue end
        for _, Tool in self.ToolsLookup[ToolName] do
            if ToolSetLookup[Tool] then continue end
            table.insert(ToolSet, Tool)
            ToolSetLookup[Tool] = true
        end
    end
    return ToolSet
end

--[[
Sets up the enum with Nexus Admin.
--]]
function ToolListEnum:SetUp(NexusAdminRegistry: Types.Registry): ()
    if self.NexusAdminRegistry then return end
    self.NexusAdminRegistry = NexusAdminRegistry

    --Set the initial enum.
    self:UpdateEnum()

    --Connect tools appearing and disappearing.
    for _, Container in TOOL_CONTAINERS do
        Container.DescendantAdded:Connect(function(Tool)
            if not Tool:IsA("BackpackItem") then return end
            self:UpdateEnum()
        end)
    end
end



return ToolListEnum