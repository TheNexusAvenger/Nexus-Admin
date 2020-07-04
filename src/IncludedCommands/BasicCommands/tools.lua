--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local ToolFilter = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("ToolFilter"))
local Command = BaseCommand:Extend()
Command.Containers = {
    game:GetService("Lighting"),
    game:GetService("ReplicatedStorage"),
    game:GetService("ServerStorage"),
    game:GetService("StarterPack"),
}



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("tools","BasicCommands","Opens up a window containing the list of tools usable by :give.")
    
    --Create the remote function.
    local GetToolsInContainers = Instance.new("RemoteFunction")
    GetToolsInContainers.Name = "GetToolsInContainers"
    GetToolsInContainers.Parent = self.API.EventContainer

    function GetToolsInContainers.OnServerInvoke(Player)
        --Create the list.
        local ToolsList = {}
        for _,Container in pairs(self.Containers) do
            table.insert(ToolsList,{Text=Container.Name,Font="SourceSansBold"})
            local ToolsInContainer = ToolFilter("all",{Container})
            if #ToolsInContainer ~= 0 then
                for _,Tool in pairs(ToolsInContainer) do
                    table.insert(ToolsList,Tool.Name)
                end
            else
                table.insert(ToolsList,{Text="(None)",Font="SourceSansItalic"})
            end
            table.insert(ToolsList,"")
        end

        --Return the list.
        table.remove(ToolsList,#ToolsList)
        return ToolsList
    end
end



return Command